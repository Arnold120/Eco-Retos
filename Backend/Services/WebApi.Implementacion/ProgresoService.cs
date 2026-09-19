using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class ProgresoService : IProgresoService
    {
        private readonly string _connectionString;

        public ProgresoService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private const string Columnas =
            "ProgresoId, UsuarioId, Experiencia, RetosCompletados, TriviasCompletadas, " +
            "InsigniasObtenidas, PublicacionesRealizadas, MaterialesObtenidos, NivelActual, PorcentajeProgreso";

        private static Progreso Mapear(SqlDataReader reader)
        {
            return new Progreso
            {
                ProgresoId = DatabaseHelper.ReadInt(reader, "ProgresoId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                Experiencia = DatabaseHelper.ReadInt(reader, "Experiencia"),
                RetosCompletados = DatabaseHelper.ReadInt(reader, "RetosCompletados"),
                TriviasCompletadas = DatabaseHelper.ReadInt(reader, "TriviasCompletadas"),
                InsigniasObtenidas = DatabaseHelper.ReadInt(reader, "InsigniasObtenidas"),
                PublicacionesRealizadas = DatabaseHelper.ReadInt(reader, "PublicacionesRealizadas"),
                MaterialesObtenidos = DatabaseHelper.ReadInt(reader, "MaterialesObtenidos"),
                NivelActual = DatabaseHelper.ReadInt(reader, "NivelActual"),
                PorcentajeProgreso = DatabaseHelper.ReadDecimal(reader, "PorcentajeProgreso")
            };
        }

        public async Task<Progreso?> ObtenerProgresoDeUsuarioAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            // RetosCompletados se calcula desde UsuarioReto (fuente de verdad):
            // el contador almacenado quedaba desincronizado cuando la evidencia
            // se aprobaba por admin o se sincronizaba sin pasar por el móvil.
            using var command = new SqlCommand(
                "SELECT p.ProgresoId, p.UsuarioId, p.Experiencia, " +
                "(SELECT COUNT(*) FROM UsuarioReto ur WHERE ur.UsuarioId = p.UsuarioId AND ur.Estado = 'COMPLETADO') AS RetosCompletados, " +
                "p.TriviasCompletadas, p.InsigniasObtenidas, p.PublicacionesRealizadas, " +
                "p.MaterialesObtenidos, p.NivelActual, p.PorcentajeProgreso " +
                "FROM Progreso p WHERE p.UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Progreso> ObtenerOCrearProgresoAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            await CrearSiNoExisteAsync(connection, null, usuarioId);
            var progreso = await LeerAsync(connection, null, usuarioId);
            return progreso ?? new Progreso { UsuarioId = usuarioId, NivelActual = 1 };
        }

        public async Task<Progreso> CrearProgresoAsync(Progreso progreso)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Progreso (UsuarioId, Experiencia, RetosCompletados, TriviasCompletadas, InsigniasObtenidas, PublicacionesRealizadas, MaterialesObtenidos, NivelActual, PorcentajeProgreso) " +
                "OUTPUT INSERTED.ProgresoId VALUES (@UsuarioId, @Experiencia, @RetosCompletados, @TriviasCompletadas, @InsigniasObtenidas, @PublicacionesRealizadas, @MaterialesObtenidos, @NivelActual, @PorcentajeProgreso)",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", progreso.UsuarioId);
            command.Parameters.AddWithValue("@Experiencia", progreso.Experiencia);
            command.Parameters.AddWithValue("@RetosCompletados", progreso.RetosCompletados);
            command.Parameters.AddWithValue("@TriviasCompletadas", progreso.TriviasCompletadas);
            command.Parameters.AddWithValue("@InsigniasObtenidas", progreso.InsigniasObtenidas);
            command.Parameters.AddWithValue("@PublicacionesRealizadas", progreso.PublicacionesRealizadas);
            command.Parameters.AddWithValue("@MaterialesObtenidos", progreso.MaterialesObtenidos);
            command.Parameters.AddWithValue("@NivelActual", progreso.NivelActual);
            command.Parameters.AddWithValue("@PorcentajeProgreso", progreso.PorcentajeProgreso);
            progreso.ProgresoId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return progreso;
        }

        public async Task<bool> ActualizarProgresoAsync(Progreso progreso)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Progreso SET Experiencia = @Experiencia, RetosCompletados = @RetosCompletados, TriviasCompletadas = @TriviasCompletadas, " +
                "InsigniasObtenidas = @InsigniasObtenidas, PublicacionesRealizadas = @PublicacionesRealizadas, MaterialesObtenidos = @MaterialesObtenidos, " +
                "NivelActual = @NivelActual, PorcentajeProgreso = @PorcentajeProgreso WHERE UsuarioId = @UsuarioId",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", progreso.UsuarioId);
            command.Parameters.AddWithValue("@Experiencia", progreso.Experiencia);
            command.Parameters.AddWithValue("@RetosCompletados", progreso.RetosCompletados);
            command.Parameters.AddWithValue("@TriviasCompletadas", progreso.TriviasCompletadas);
            command.Parameters.AddWithValue("@InsigniasObtenidas", progreso.InsigniasObtenidas);
            command.Parameters.AddWithValue("@PublicacionesRealizadas", progreso.PublicacionesRealizadas);
            command.Parameters.AddWithValue("@MaterialesObtenidos", progreso.MaterialesObtenidos);
            command.Parameters.AddWithValue("@NivelActual", progreso.NivelActual);
            command.Parameters.AddWithValue("@PorcentajeProgreso", progreso.PorcentajeProgreso);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<IEnumerable<Progreso>> ObtenerRankingAsync(int cantidad)
        {
            var lista = new List<Progreso>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT TOP ({cantidad}) {Columnas} FROM Progreso ORDER BY Experiencia DESC, NivelActual DESC",
                connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        /// <summary>
        /// Suma XP y recalcula NivelActual/PorcentajeProgreso de forma atómica.
        /// Puede participar de una transacción externa (recompensas).
        /// </summary>
        public async Task<Progreso> AgregarExperienciaAsync(
            int usuarioId,
            int cantidad,
            SqlConnection? conexion = null,
            SqlTransaction? transaccion = null)
        {
            if (usuarioId <= 0)
                throw new ArgumentOutOfRangeException(nameof(usuarioId), "El usuario es inválido.");
            if (cantidad <= 0)
                throw new ArgumentOutOfRangeException(nameof(cantidad), "La experiencia a agregar debe ser mayor a cero.");

            var esPropia = conexion is null;
            var connection = conexion ?? new SqlConnection(_connectionString);
            var transaction = transaccion;
            if (esPropia)
            {
                await connection.OpenAsync();
                transaction = connection.BeginTransaction();
            }

            try
            {
                await CrearSiNoExisteAsync(connection, transaction, usuarioId);

                using (var sumar = new SqlCommand(
                    "UPDATE Progreso SET Experiencia = Experiencia + @Cantidad WHERE UsuarioId = @UsuarioId",
                    connection,
                    transaction))
                {
                    sumar.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    sumar.Parameters.AddWithValue("@Cantidad", cantidad);
                    await sumar.ExecuteNonQueryAsync();
                }

                var progreso = await LeerAsync(connection, transaction, usuarioId)
                    ?? new Progreso { UsuarioId = usuarioId, NivelActual = 1 };
                var (nivel, porcentaje) = ProgresoCalculator.Calcular(progreso.Experiencia);

                using (var actualizar = new SqlCommand(
                    "UPDATE Progreso SET NivelActual = @Nivel, PorcentajeProgreso = @Porcentaje WHERE UsuarioId = @UsuarioId",
                    connection,
                    transaction))
                {
                    actualizar.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    actualizar.Parameters.AddWithValue("@Nivel", nivel);
                    actualizar.Parameters.AddWithValue("@Porcentaje", porcentaje);
                    await actualizar.ExecuteNonQueryAsync();
                }

                progreso.NivelActual = nivel;
                progreso.PorcentajeProgreso = porcentaje;

                if (esPropia) transaction!.Commit();
                return progreso;
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

        public async Task<bool> IncrementarRetosCompletadosAsync(int usuarioId)
        {
            return await IncrementarAsync(usuarioId, "RetosCompletados");
        }

        public async Task<bool> IncrementarTriviasCompletadasAsync(int usuarioId)
        {
            return await IncrementarAsync(usuarioId, "TriviasCompletadas");
        }

        public async Task<bool> IncrementarInsigniasObtenidasAsync(int usuarioId)
        {
            return await IncrementarAsync(usuarioId, "InsigniasObtenidas");
        }

        public async Task<bool> IncrementarPublicacionesRealizadasAsync(int usuarioId)
        {
            return await IncrementarAsync(usuarioId, "PublicacionesRealizadas");
        }

        public async Task<bool> IncrementarMaterialesObtenidosAsync(int usuarioId)
        {
            return await IncrementarAsync(usuarioId, "MaterialesObtenidos");
        }

        private async Task<bool> IncrementarAsync(int usuarioId, string columna)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"UPDATE Progreso SET {columna} = {columna} + 1 WHERE UsuarioId = @UsuarioId",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        private static async Task CrearSiNoExisteAsync(
            SqlConnection connection,
            SqlTransaction? transaction,
            int usuarioId)
        {
            const string sql =
                "IF NOT EXISTS (SELECT 1 FROM Progreso WHERE UsuarioId = @UsuarioId) " +
                "BEGIN INSERT INTO Progreso (UsuarioId, Experiencia, NivelActual, PorcentajeProgreso) VALUES (@UsuarioId, 0, 1, 0); END";
            using var command = new SqlCommand(sql, connection, transaction);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            await command.ExecuteNonQueryAsync();
        }

        private static async Task<Progreso?> LeerAsync(
            SqlConnection connection,
            SqlTransaction? transaction,
            int usuarioId)
        {
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM Progreso WHERE UsuarioId = @UsuarioId",
                connection,
                transaction);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }
    }
}
