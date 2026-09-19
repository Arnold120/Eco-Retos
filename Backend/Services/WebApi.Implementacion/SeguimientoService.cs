using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;

namespace WebApi.Implementacion
{
    public class SeguimientoService : ISeguimientoService
    {
        private readonly string _connectionString;
        private readonly INotificacionService _notificacionService;
        private readonly IUsuarioService _usuarioService;

        public SeguimientoService(
            IConfiguration configuration,
            INotificacionService notificacionService,
            IUsuarioService usuarioService)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
            _notificacionService = notificacionService;
            _usuarioService = usuarioService;
        }

        public async Task<bool> SeguirAsync(int seguidorId, int seguidoId)
        {
            if (seguidorId == seguidoId || seguidorId <= 0 || seguidoId <= 0) return false;

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand(
                    "IF NOT EXISTS (SELECT 1 FROM Seguimiento WHERE SeguidorId = @SeguidorId AND SeguidoId = @SeguidoId) " +
                    "BEGIN INSERT INTO Seguimiento (SeguidorId, SeguidoId, Fecha) VALUES (@SeguidorId, @SeguidoId, @Fecha) SELECT 1 END " +
                    "ELSE SELECT 0", connection);
                command.Parameters.AddWithValue("@SeguidorId", seguidorId);
                command.Parameters.AddWithValue("@SeguidoId", seguidoId);
                command.Parameters.AddWithValue("@Fecha", DateTime.Now);
                var insertado = Convert.ToInt32(await command.ExecuteScalarAsync() ?? 0) == 1;

                if (insertado)
                {
                    try
                    {
                        var actor = await _usuarioService.ObtenerPorIdAsync(seguidorId);
                        await _notificacionService.CrearInteraccionAsync(
                            seguidoId, seguidorId,
                            $"{actor?.NombreUsuario ?? "Alguien"} comenzó a seguirte",
                            "Ahora aparece en tus seguidores.", "SEGUIMIENTO", "USUARIO", seguidorId);
                    }
                    catch
                    {
                        // La notificacion no debe bloquear el seguimiento.
                    }
                }
            }

            return true;
        }

        public async Task<bool> DejarDeSeguirAsync(int seguidorId, int seguidoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Seguimiento WHERE SeguidorId = @SeguidorId AND SeguidoId = @SeguidoId", connection);
            command.Parameters.AddWithValue("@SeguidorId", seguidorId);
            command.Parameters.AddWithValue("@SeguidoId", seguidoId);
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> EstaSiguiendoAsync(int seguidorId, int seguidoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Seguimiento WHERE SeguidorId = @SeguidorId AND SeguidoId = @SeguidoId", connection);
            command.Parameters.AddWithValue("@SeguidorId", seguidorId);
            command.Parameters.AddWithValue("@SeguidoId", seguidoId);
            return Convert.ToInt32(await command.ExecuteScalarAsync()) > 0;
        }

        public async Task<int> ContarSeguidoresAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Seguimiento WHERE SeguidoId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        public async Task<int> ContarSeguidosAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Seguimiento WHERE SeguidorId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        public async Task<IEnumerable<int>> ObtenerIdsSeguidosAsync(int seguidorId)
        {
            var ids = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT SeguidoId FROM Seguimiento WHERE SeguidorId = @SeguidorId", connection);
            command.Parameters.AddWithValue("@SeguidorId", seguidorId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) ids.Add(DatabaseHelper.ReadInt(reader, "SeguidoId"));
            return ids;
        }

        public async Task<IEnumerable<int>> ObtenerIdsSeguidoresAsync(int usuarioId)
        {
            var ids = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT SeguidorId FROM Seguimiento WHERE SeguidoId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) ids.Add(DatabaseHelper.ReadInt(reader, "SeguidorId"));
            return ids;
        }
    }
}
