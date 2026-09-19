using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class CompraService : ICompraService
    {
        private readonly string _connectionString;
        private readonly IMonederoService _monederoService;

        public CompraService(IConfiguration configuration, IMonederoService monederoService)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
            _monederoService = monederoService;
        }

        private const string Columnas = "CompraId, UsuarioId, TotalMonedas, FechaCompra, ClaveIdempotencia";

        private static Compra Mapear(SqlDataReader reader)
        {
            return new Compra
            {
                CompraId = DatabaseHelper.ReadInt(reader, "CompraId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                TotalMonedas = DatabaseHelper.ReadInt(reader, "TotalMonedas"),
                FechaCompra = DatabaseHelper.ReadDateTime(reader, "FechaCompra"),
                ClaveIdempotencia = reader.IsDBNull(reader.GetOrdinal("ClaveIdempotencia"))
                    ? null
                    : DatabaseHelper.ReadString(reader, "ClaveIdempotencia")
            };
        }

        public async Task<IEnumerable<Compra>> ObtenerComprasDeUsuarioAsync(int usuarioId)
        {
            var lista = new List<Compra>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Compra WHERE UsuarioId = @UsuarioId ORDER BY FechaCompra DESC", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Compra?> ObtenerPorIdAsync(int compraId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Compra WHERE CompraId = @CompraId", connection);
            command.Parameters.AddWithValue("@CompraId", compraId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Compra?> ObtenerPorClaveIdempotenciaAsync(int usuarioId, string claveIdempotencia)
        {
            if (string.IsNullOrWhiteSpace(claveIdempotencia)) return null;
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM Compra WHERE UsuarioId = @UsuarioId AND ClaveIdempotencia = @Clave",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@Clave", claveIdempotencia.Trim());
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        /// <summary>Método legado (sin transacción). Usar CrearCompraCompletaAsync.</summary>
        public async Task<Compra> CrearCompraAsync(Compra compra)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Compra (UsuarioId, TotalMonedas, FechaCompra, ClaveIdempotencia) OUTPUT INSERTED.CompraId " +
                "VALUES (@UsuarioId, @TotalMonedas, @FechaCompra, @Clave)",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", compra.UsuarioId);
            command.Parameters.AddWithValue("@TotalMonedas", compra.TotalMonedas);
            command.Parameters.AddWithValue("@FechaCompra", compra.FechaCompra);
            command.Parameters.AddWithValue("@Clave", (object?)compra.ClaveIdempotencia ?? DBNull.Value);
            compra.CompraId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return compra;
        }

        public async Task<IEnumerable<Compra>> ObtenerRecientesAsync(int usuarioId, int cantidad)
        {
            var lista = new List<Compra>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT TOP ({cantidad}) {Columnas} FROM Compra WHERE UsuarioId = @UsuarioId ORDER BY FechaCompra DESC", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<CompraCompletaResultado> CrearCompraCompletaAsync(
            int usuarioId,
            IEnumerable<DetalleCompraSolicitado> detalles,
            string? claveIdempotencia)
        {
            if (usuarioId <= 0)
                return Fallo("El usuario es inválido.");

            var solicitados = (detalles ?? Enumerable.Empty<DetalleCompraSolicitado>())
                .Where(d => d.Cantidad > 0)
                .GroupBy(d => d.MaterialId)
                .Select(g => new DetalleCompraSolicitado
                {
                    MaterialId = g.Key,
                    Cantidad = g.Sum(x => x.Cantidad)
                })
                .ToList();

            if (solicitados.Count == 0)
                return Fallo("La compra debe incluir al menos un material.");
            if (solicitados.Any(d => d.MaterialId <= 0))
                return Fallo("Hay un material inválido en la compra.");
            if (solicitados.Count > 50)
                return Fallo("La compra no puede tener más de 50 materiales distintos.");

            if (!string.IsNullOrWhiteSpace(claveIdempotencia))
            {
                var previa = await ObtenerPorClaveIdempotenciaAsync(usuarioId, claveIdempotencia);
                if (previa is not null)
                    return await DuplicadaAsync(usuarioId, previa);
            }

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();
            try
            {
                // 1) Bloquear materiales y leer precios/stock reales del catálogo.
                var materiales = new Dictionary<int, Material>();
                var nombresParametros = new List<string>();
                using (var command = new SqlCommand(
                    "SELECT MaterialId, NombreMaterial, Descripcion, Tipo, PrecioMonedas, CantidadDisponible, Imagen, Estado " +
                    "FROM Material WITH (UPDLOCK, ROWLOCK) WHERE MaterialId IN (" +
                    string.Join(", ", solicitados.Select((_, i) => $"@M{i}")) + ")",
                    connection,
                    transaction))
                {
                    for (var i = 0; i < solicitados.Count; i++)
                    {
                        command.Parameters.AddWithValue($"@M{i}", solicitados[i].MaterialId);
                    }
                    using var reader = await command.ExecuteReaderAsync();
                    while (await reader.ReadAsync())
                    {
                        var material = new Material
                        {
                            MaterialId = DatabaseHelper.ReadInt(reader, "MaterialId"),
                            NombreMaterial = DatabaseHelper.ReadString(reader, "NombreMaterial"),
                            Descripcion = DatabaseHelper.ReadString(reader, "Descripcion"),
                            Tipo = DatabaseHelper.ReadString(reader, "Tipo"),
                            PrecioMonedas = DatabaseHelper.ReadInt(reader, "PrecioMonedas"),
                            CantidadDisponible = DatabaseHelper.ReadInt(reader, "CantidadDisponible"),
                            Imagen = reader.IsDBNull(reader.GetOrdinal("Imagen")) ? null : DatabaseHelper.ReadString(reader, "Imagen"),
                            Estado = DatabaseHelper.ReadString(reader, "Estado")
                        };
                        materiales[material.MaterialId] = material;
                    }
                }

                foreach (var item in solicitados)
                {
                    if (!materiales.TryGetValue(item.MaterialId, out var material))
                        return FalloConRollback(transaction, $"No se encontró el material {item.MaterialId}.");
                    if (!string.Equals(material.Estado, "DISPONIBLE", StringComparison.OrdinalIgnoreCase))
                        return FalloConRollback(transaction, $"El material '{material.NombreMaterial}' no está disponible.");
                    if (material.CantidadDisponible < item.Cantidad)
                        return FalloConRollback(transaction, $"No hay suficiente stock de '{material.NombreMaterial}'.");
                }

                var total = solicitados.Sum(item => materiales[item.MaterialId].PrecioMonedas * item.Cantidad);
                if (total <= 0)
                    return FalloConRollback(transaction, "El total de la compra debe ser mayor a cero.");

                // 2) Cobrar con el Monedero (valida saldo de forma atómica).
                var cobro = await _monederoService.GastarMonedasAsync(
                    usuarioId,
                    total,
                    "COMPRA",
                    $"Compra de {solicitados.Count} material(es) por {total} Monedas Eco",
                    categoriaId: null,
                    claveIdempotencia: null,
                    conexion: connection,
                    transaccion: transaction);
                if (!cobro.Exito)
                    return FalloConRollback(transaction, cobro.Mensaje ?? "Saldo insuficiente.");

                // 3) Crear la compra y sus detalles.
                var compra = new Compra
                {
                    UsuarioId = usuarioId,
                    TotalMonedas = total,
                    FechaCompra = DateTime.Now,
                    ClaveIdempotencia = string.IsNullOrWhiteSpace(claveIdempotencia)
                        ? null
                        : claveIdempotencia.Trim()
                };
                using (var insertCompra = new SqlCommand(
                    "INSERT INTO Compra (UsuarioId, TotalMonedas, FechaCompra, ClaveIdempotencia) OUTPUT INSERTED.CompraId " +
                    "VALUES (@UsuarioId, @TotalMonedas, @FechaCompra, @Clave)",
                    connection,
                    transaction))
                {
                    insertCompra.Parameters.AddWithValue("@UsuarioId", compra.UsuarioId);
                    insertCompra.Parameters.AddWithValue("@TotalMonedas", compra.TotalMonedas);
                    insertCompra.Parameters.AddWithValue("@FechaCompra", compra.FechaCompra);
                    insertCompra.Parameters.AddWithValue("@Clave", (object?)compra.ClaveIdempotencia ?? DBNull.Value);
                    compra.CompraId = Convert.ToInt32(await insertCompra.ExecuteScalarAsync());
                }

                var detallesCreados = new List<DetalleCompra>();
                foreach (var item in solicitados)
                {
                    var material = materiales[item.MaterialId];
                    var detalle = new DetalleCompra
                    {
                        CompraId = compra.CompraId,
                        MaterialId = material.MaterialId,
                        Cantidad = item.Cantidad,
                        PrecioUnitarioMonedas = material.PrecioMonedas
                    };
                    using (var insertDetalle = new SqlCommand(
                        "INSERT INTO DetalleCompra (CompraId, MaterialId, Cantidad, PrecioUnitarioMonedas) OUTPUT INSERTED.DetalleCompraId " +
                        "VALUES (@CompraId, @MaterialId, @Cantidad, @Precio)",
                        connection,
                        transaction))
                    {
                        insertDetalle.Parameters.AddWithValue("@CompraId", detalle.CompraId);
                        insertDetalle.Parameters.AddWithValue("@MaterialId", detalle.MaterialId);
                        insertDetalle.Parameters.AddWithValue("@Cantidad", detalle.Cantidad);
                        insertDetalle.Parameters.AddWithValue("@Precio", detalle.PrecioUnitarioMonedas);
                        detalle.DetalleCompraId = Convert.ToInt32(await insertDetalle.ExecuteScalarAsync());
                    }
                    detallesCreados.Add(detalle);

                    // 4) Inventario (upsert dentro de la misma transacción).
                    using (var actualizarInventario = new SqlCommand(
                        "UPDATE Inventario SET Cantidad = Cantidad + @Cantidad OUTPUT INSERTED.InventarioId " +
                        "WHERE UsuarioId = @UsuarioId AND MaterialId = @MaterialId",
                        connection,
                        transaction))
                    {
                        actualizarInventario.Parameters.AddWithValue("@UsuarioId", usuarioId);
                        actualizarInventario.Parameters.AddWithValue("@MaterialId", material.MaterialId);
                        actualizarInventario.Parameters.AddWithValue("@Cantidad", item.Cantidad);
                        var inventarioId = await actualizarInventario.ExecuteScalarAsync();
                        if (inventarioId is null || inventarioId == DBNull.Value)
                        {
                            using var insertInventario = new SqlCommand(
                                "INSERT INTO Inventario (UsuarioId, MaterialId, Cantidad) VALUES (@UsuarioId, @MaterialId, @Cantidad)",
                                connection,
                                transaction);
                            insertInventario.Parameters.AddWithValue("@UsuarioId", usuarioId);
                            insertInventario.Parameters.AddWithValue("@MaterialId", material.MaterialId);
                            insertInventario.Parameters.AddWithValue("@Cantidad", item.Cantidad);
                            await insertInventario.ExecuteNonQueryAsync();
                        }
                    }

                    // 5) Descontar stock del catálogo.
                    using (var descontar = new SqlCommand(
                        "UPDATE Material SET CantidadDisponible = CantidadDisponible - @Cantidad " +
                        "WHERE MaterialId = @MaterialId AND CantidadDisponible >= @Cantidad",
                        connection,
                        transaction))
                    {
                        descontar.Parameters.AddWithValue("@MaterialId", material.MaterialId);
                        descontar.Parameters.AddWithValue("@Cantidad", item.Cantidad);
                        if (await descontar.ExecuteNonQueryAsync() == 0)
                            return FalloConRollback(transaction, $"No hay suficiente stock de '{material.NombreMaterial}'.");
                    }
                }

                // 6) Contador de progreso (materiales obtenidos).
                using (var progreso = new SqlCommand(
                    "UPDATE Progreso SET MaterialesObtenidos = MaterialesObtenidos + @Total WHERE UsuarioId = @UsuarioId",
                    connection,
                    transaction))
                {
                    progreso.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    progreso.Parameters.AddWithValue("@Total", solicitados.Sum(x => x.Cantidad));
                    await progreso.ExecuteNonQueryAsync();
                }

                transaction.Commit();
                return new CompraCompletaResultado
                {
                    Exito = true,
                    Saldo = cobro.Saldo,
                    Compra = compra,
                    Detalles = detallesCreados
                };
            }
            catch (SqlException ex) when (ex.Number is 2601 or 2627)
            {
                transaction.Rollback();
                var previa = string.IsNullOrWhiteSpace(claveIdempotencia)
                    ? null
                    : await ObtenerPorClaveIdempotenciaAsync(usuarioId, claveIdempotencia!);
                if (previa is not null) return await DuplicadaAsync(usuarioId, previa);
                throw;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        private static CompraCompletaResultado Fallo(string mensaje)
        {
            return new CompraCompletaResultado { Exito = false, Mensaje = mensaje };
        }

        private static CompraCompletaResultado FalloConRollback(SqlTransaction transaction, string mensaje)
        {
            transaction.Rollback();
            return Fallo(mensaje);
        }

        private async Task<CompraCompletaResultado> DuplicadaAsync(int usuarioId, Compra compra)
        {
            return new CompraCompletaResultado
            {
                Exito = true,
                Saldo = await _monederoService.ObtenerSaldoAsync(usuarioId),
                Compra = compra,
                Mensaje = "La compra ya había sido registrada."
            };
        }
    }
}
