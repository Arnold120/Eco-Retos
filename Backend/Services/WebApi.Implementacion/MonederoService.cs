using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    /// <summary>
    /// Única puerta de entrada al saldo de Monedas Eco. Garantiza:
    ///  - Saldo nunca negativo (CHECK + UPDATE condicional atómico).
    ///  - Movimiento registrado en HistorialMonedas junto al saldo (transacción).
    ///  - Concurrencia segura (el UPDATE con "Saldo >= @Cantidad" es atómico).
    ///  - Idempotencia opcional por ClaveIdempotencia.
    /// </summary>
    public class MonederoService : IMonederoService
    {
        private readonly string _connectionString;

        public MonederoService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private const string Columnas =
            "HistorialMonedaId, UsuarioId, CategoriaId, Cantidad, Tipo, Descripcion, SaldoResultante, ClaveIdempotencia, Fecha";

        public async Task CrearMonederoAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            await CrearMonederoSiNoExisteAsync(connection, null, usuarioId);
        }

        /// <summary>Crea el monedero si no existe. Puede participar de una transacción.</summary>
        internal static async Task CrearMonederoSiNoExisteAsync(
            SqlConnection connection,
            SqlTransaction? transaction,
            int usuarioId)
        {
            const string sql =
                "IF NOT EXISTS (SELECT 1 FROM Monedero WHERE UsuarioId = @UsuarioId) " +
                "BEGIN INSERT INTO Monedero (UsuarioId, Saldo) VALUES (@UsuarioId, 0); END";
            using var command = new SqlCommand(sql, connection, transaction);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            await command.ExecuteNonQueryAsync();
        }

        public async Task<Monedero?> ObtenerMonederoAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            return await ObtenerMonederoAsync(connection, null, usuarioId);
        }

        private static async Task<Monedero?> ObtenerMonederoAsync(
            SqlConnection connection,
            SqlTransaction? transaction,
            int usuarioId)
        {
            using var command = new SqlCommand(
                "SELECT MonederoId, UsuarioId, Saldo, FechaActualizacion FROM Monedero WHERE UsuarioId = @UsuarioId",
                connection,
                transaction);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new Monedero
            {
                MonederoId = DatabaseHelper.ReadInt(reader, "MonederoId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                Saldo = DatabaseHelper.ReadInt(reader, "Saldo"),
                FechaActualizacion = DatabaseHelper.ReadDateTime(reader, "FechaActualizacion")
            };
        }

        public async Task<int> ObtenerSaldoAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            await CrearMonederoSiNoExisteAsync(connection, null, usuarioId);
            using var command = new SqlCommand(
                "SELECT Saldo FROM Monedero WHERE UsuarioId = @UsuarioId",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        public async Task<IEnumerable<HistorialMoneda>> ObtenerHistorialAsync(int usuarioId, int? cantidad = null)
        {
            var lista = new List<HistorialMoneda>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            var top = cantidad is > 0 ? $"TOP ({cantidad.Value}) " : string.Empty;
            using var command = new SqlCommand(
                $"SELECT {top}{Columnas} FROM HistorialMonedas WHERE UsuarioId = @UsuarioId " +
                "ORDER BY Fecha DESC, HistorialMonedaId DESC",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<CategoriaMonedas>> ObtenerPorCategoriaAsync(int usuarioId)
        {
            var lista = new List<CategoriaMonedas>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT ISNULL(CategoriaId, 0) AS CategoriaId, " +
                "SUM(CASE WHEN Cantidad > 0 THEN Cantidad ELSE 0 END) AS Total " +
                "FROM HistorialMonedas WHERE UsuarioId = @UsuarioId " +
                "GROUP BY CategoriaId ORDER BY CategoriaId",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                lista.Add(new CategoriaMonedas
                {
                    CategoriaId = DatabaseHelper.ReadInt(reader, "CategoriaId"),
                    Total = DatabaseHelper.ReadInt(reader, "Total")
                });
            }
            return lista;
        }

        public Task<MovimientoMonedasResultado> AgregarMonedasAsync(
            int usuarioId,
            int cantidad,
            string tipo,
            string descripcion,
            int? categoriaId = null,
            string? claveIdempotencia = null,
            SqlConnection? conexion = null,
            SqlTransaction? transaccion = null)
        {
            return MoverMonedasAsync(
                usuarioId, cantidad, tipo, descripcion, categoriaId,
                claveIdempotencia, esGasto: false, conexion, transaccion);
        }

        public Task<MovimientoMonedasResultado> GastarMonedasAsync(
            int usuarioId,
            int cantidad,
            string tipo,
            string descripcion,
            int? categoriaId = null,
            string? claveIdempotencia = null,
            SqlConnection? conexion = null,
            SqlTransaction? transaccion = null)
        {
            return MoverMonedasAsync(
                usuarioId, cantidad, tipo, descripcion, categoriaId,
                claveIdempotencia, esGasto: true, conexion, transaccion);
        }

        private async Task<MovimientoMonedasResultado> MoverMonedasAsync(
            int usuarioId,
            int cantidad,
            string tipo,
            string descripcion,
            int? categoriaId,
            string? claveIdempotencia,
            bool esGasto,
            SqlConnection? conexion,
            SqlTransaction? transaccion)
        {
            if (usuarioId <= 0)
                return Fallo("El usuario es inválido.");
            if (cantidad <= 0)
                return Fallo(esGasto
                    ? "El monto a gastar debe ser mayor a cero."
                    : "El monto a agregar debe ser mayor a cero.");
            if (string.IsNullOrWhiteSpace(tipo))
                return Fallo("El tipo de movimiento es obligatorio.");
            if (string.IsNullOrWhiteSpace(descripcion))
                return Fallo("La descripción del movimiento es obligatoria.");

            var esPropia = conexion is null;
            var connection = conexion ?? new SqlConnection(_connectionString);
            SqlTransaction? transaction = transaccion;
            if (esPropia)
            {
                await connection.OpenAsync();
                transaction = connection.BeginTransaction();
            }

            try
            {
                if (!string.IsNullOrWhiteSpace(claveIdempotencia))
                {
                    var existente = await BuscarPorClaveAsync(connection, transaction, usuarioId, claveIdempotencia);
                    if (existente is not null)
                    {
                        if (esPropia) transaction!.Commit();
                        return new MovimientoMonedasResultado
                        {
                            Exito = true,
                            Duplicado = true,
                            Saldo = existente.SaldoResultante,
                            Movimiento = existente,
                            Mensaje = "El movimiento ya estaba registrado."
                        };
                    }
                }

                await CrearMonederoSiNoExisteAsync(connection, transaction, usuarioId);

                int saldo;
                if (esGasto)
                {
                    using var update = new SqlCommand(
                        "UPDATE Monedero SET Saldo = Saldo - @Cantidad, FechaActualizacion = SYSDATETIME() " +
                        "OUTPUT INSERTED.Saldo WHERE UsuarioId = @UsuarioId AND Saldo >= @Cantidad",
                        connection,
                        transaction);
                    update.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    update.Parameters.AddWithValue("@Cantidad", cantidad);
                    var resultado = await update.ExecuteScalarAsync();
                    if (resultado is null || resultado == DBNull.Value)
                    {
                        if (esPropia) transaction!.Rollback();
                        var saldoActual = await LeerSaldoAsync(connection, usuarioId);
                        return Fallo($"Saldo insuficiente. Tienes {saldoActual} Monedas Eco.");
                    }
                    saldo = Convert.ToInt32(resultado);
                }
                else
                {
                    using var update = new SqlCommand(
                        "UPDATE Monedero SET Saldo = Saldo + @Cantidad, FechaActualizacion = SYSDATETIME() " +
                        "OUTPUT INSERTED.Saldo WHERE UsuarioId = @UsuarioId",
                        connection,
                        transaction);
                    update.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    update.Parameters.AddWithValue("@Cantidad", cantidad);
                    saldo = Convert.ToInt32(await update.ExecuteScalarAsync());
                }

                var movimiento = new HistorialMoneda
                {
                    UsuarioId = usuarioId,
                    CategoriaId = categoriaId,
                    Cantidad = esGasto ? -cantidad : cantidad,
                    Tipo = tipo.Trim().ToUpperInvariant(),
                    Descripcion = descripcion.Trim(),
                    SaldoResultante = saldo,
                    ClaveIdempotencia = string.IsNullOrWhiteSpace(claveIdempotencia)
                        ? null
                        : claveIdempotencia.Trim(),
                    Fecha = DateTime.Now
                };

                using (var insert = new SqlCommand(
                    "INSERT INTO HistorialMonedas " +
                    "(UsuarioId, CategoriaId, Cantidad, Tipo, Descripcion, SaldoResultante, ClaveIdempotencia, Fecha) " +
                    "OUTPUT INSERTED.HistorialMonedaId " +
                    "VALUES (@UsuarioId, @CategoriaId, @Cantidad, @Tipo, @Descripcion, @SaldoResultante, @Clave, @Fecha)",
                    connection,
                    transaction))
                {
                    insert.Parameters.AddWithValue("@UsuarioId", movimiento.UsuarioId);
                    insert.Parameters.AddWithValue("@CategoriaId", (object?)movimiento.CategoriaId ?? DBNull.Value);
                    insert.Parameters.AddWithValue("@Cantidad", movimiento.Cantidad);
                    insert.Parameters.AddWithValue("@Tipo", movimiento.Tipo);
                    insert.Parameters.AddWithValue("@Descripcion", movimiento.Descripcion);
                    insert.Parameters.AddWithValue("@SaldoResultante", movimiento.SaldoResultante);
                    insert.Parameters.AddWithValue("@Clave", (object?)movimiento.ClaveIdempotencia ?? DBNull.Value);
                    insert.Parameters.AddWithValue("@Fecha", movimiento.Fecha);
                    movimiento.HistorialMonedaId = Convert.ToInt32(await insert.ExecuteScalarAsync());
                }

                if (esPropia) transaction!.Commit();
                return new MovimientoMonedasResultado
                {
                    Exito = true,
                    Saldo = saldo,
                    Movimiento = movimiento
                };
            }
            catch (SqlException ex) when (ex.Number is 2601 or 2627)
            {
                if (esPropia) transaction?.Rollback();
                var existente = string.IsNullOrWhiteSpace(claveIdempotencia)
                    ? null
                    : await BuscarPorClaveAsync(connection, null, usuarioId, claveIdempotencia);
                return new MovimientoMonedasResultado
                {
                    Exito = true,
                    Duplicado = true,
                    Saldo = existente?.SaldoResultante ?? 0,
                    Movimiento = existente,
                    Mensaje = "El movimiento ya estaba registrado."
                };
            }
            catch
            {
                if (esPropia) transaction?.Rollback();
                throw;
            }
            finally
            {
                if (esPropia)
                {
                    transaction?.Dispose();
                    connection.Dispose();
                }
            }
        }

        private static async Task<int> LeerSaldoAsync(SqlConnection connection, int usuarioId)
        {
            using var command = new SqlCommand(
                "SELECT ISNULL((SELECT Saldo FROM Monedero WHERE UsuarioId = @UsuarioId), 0)",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        private static async Task<HistorialMoneda?> BuscarPorClaveAsync(
            SqlConnection connection,
            SqlTransaction? transaction,
            int usuarioId,
            string clave)
        {
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM HistorialMonedas WHERE UsuarioId = @UsuarioId AND ClaveIdempotencia = @Clave",
                connection,
                transaction);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@Clave", clave);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        private static HistorialMoneda Mapear(SqlDataReader reader)
        {
            return new HistorialMoneda
            {
                HistorialMonedaId = DatabaseHelper.ReadInt(reader, "HistorialMonedaId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                CategoriaId = DatabaseHelper.ReadNullableInt(reader, "CategoriaId"),
                Cantidad = DatabaseHelper.ReadInt(reader, "Cantidad"),
                Tipo = DatabaseHelper.ReadString(reader, "Tipo"),
                Descripcion = DatabaseHelper.ReadString(reader, "Descripcion"),
                SaldoResultante = DatabaseHelper.ReadInt(reader, "SaldoResultante"),
                ClaveIdempotencia = reader.IsDBNull(reader.GetOrdinal("ClaveIdempotencia"))
                    ? null
                    : DatabaseHelper.ReadString(reader, "ClaveIdempotencia"),
                Fecha = DatabaseHelper.ReadDateTime(reader, "Fecha")
            };
        }

        private static MovimientoMonedasResultado Fallo(string mensaje)
        {
            return new MovimientoMonedasResultado
            {
                Exito = false,
                Duplicado = false,
                Mensaje = mensaje
            };
        }
    }
}
