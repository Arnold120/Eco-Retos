using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class CalificacionService : ICalificacionService
    {
        private readonly string _connectionString;

        public CalificacionService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<List<CalificacionOpinion>> ObtenerOpinionesAsync(int usuarioCalificadoId, int limite = 50, int offset = 0)
        {
            var lista = new List<CalificacionOpinion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT c.UsuarioCalificadorId AS UsuarioId, u.NombreUsuario, p.FotoPerfil, c.Calificacion, c.Comentario, c.Fecha " +
                "FROM CalificacionPerfil c " +
                "JOIN Usuario u ON u.UsuarioId = c.UsuarioCalificadorId " +
                "LEFT JOIN Perfil p ON p.UsuarioId = c.UsuarioCalificadorId " +
                "WHERE c.UsuarioCalificadoId = @UsuarioCalificadoId " +
                "ORDER BY c.Fecha DESC " +
                "OFFSET @Offset ROWS FETCH NEXT @Limite ROWS ONLY", connection);
            command.Parameters.AddWithValue("@UsuarioCalificadoId", usuarioCalificadoId);
            command.Parameters.AddWithValue("@Offset", Math.Max(offset, 0));
            command.Parameters.AddWithValue("@Limite", Math.Clamp(limite, 1, 100));
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                lista.Add(new CalificacionOpinion
                {
                    UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                    NombreUsuario = DatabaseHelper.ReadString(reader, "NombreUsuario"),
                    FotoPerfil = reader.IsDBNull(reader.GetOrdinal("FotoPerfil")) ? null : DatabaseHelper.ReadString(reader, "FotoPerfil"),
                    Calificacion = DatabaseHelper.ReadInt(reader, "Calificacion"),
                    Comentario = reader.IsDBNull(reader.GetOrdinal("Comentario")) ? null : DatabaseHelper.ReadString(reader, "Comentario"),
                    Fecha = DatabaseHelper.ReadDateTime(reader, "Fecha")
                });
            }
            return lista;
        }

        public async Task<(decimal Promedio, int Total)> ObtenerResumenAsync(int usuarioCalificadoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT COUNT(1) AS Total, AVG(CAST(Calificacion AS DECIMAL(10, 2))) AS Promedio " +
                "FROM CalificacionPerfil WHERE UsuarioCalificadoId = @UsuarioCalificadoId", connection);
            command.Parameters.AddWithValue("@UsuarioCalificadoId", usuarioCalificadoId);
            using var reader = await command.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return (0, 0);
            var total = DatabaseHelper.ReadInt(reader, "Total");
            var promedio = reader.IsDBNull(reader.GetOrdinal("Promedio")) ? 0m : reader.GetDecimal(reader.GetOrdinal("Promedio"));
            return (promedio, total);
        }

        public async Task<int?> ObtenerCalificacionPropiaAsync(int espectadorId, int usuarioCalificadoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT Calificacion FROM CalificacionPerfil " +
                "WHERE UsuarioCalificadoId = @UsuarioCalificadoId AND UsuarioCalificadorId = @EspectadorId", connection);
            command.Parameters.AddWithValue("@UsuarioCalificadoId", usuarioCalificadoId);
            command.Parameters.AddWithValue("@EspectadorId", espectadorId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? DatabaseHelper.ReadInt(reader, "Calificacion") : null;
        }

        public async Task<bool> GuardarAsync(int espectadorId, int usuarioCalificadoId, int calificacion, string? comentario)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "IF EXISTS (SELECT 1 FROM CalificacionPerfil WHERE UsuarioCalificadoId = @UsuarioCalificadoId AND UsuarioCalificadorId = @EspectadorId) " +
                "BEGIN " +
                "UPDATE CalificacionPerfil SET Calificacion = @Calificacion, Comentario = @Comentario, Fecha = @Fecha " +
                "WHERE UsuarioCalificadoId = @UsuarioCalificadoId AND UsuarioCalificadorId = @EspectadorId " +
                "END " +
                "ELSE " +
                "BEGIN " +
                "INSERT INTO CalificacionPerfil (UsuarioCalificadoId, UsuarioCalificadorId, Calificacion, Comentario, Fecha) " +
                "VALUES (@UsuarioCalificadoId, @EspectadorId, @Calificacion, @Comentario, @Fecha) " +
                "END", connection);
            command.Parameters.AddWithValue("@UsuarioCalificadoId", usuarioCalificadoId);
            command.Parameters.AddWithValue("@EspectadorId", espectadorId);
            command.Parameters.AddWithValue("@Calificacion", Math.Clamp(calificacion, 1, 5));
            command.Parameters.AddWithValue("@Comentario", (object?)(comentario?.Trim() ?? string.Empty) == string.Empty ? DBNull.Value : (object?)comentario?.Trim());
            command.Parameters.AddWithValue("@Fecha", DateTime.Now);
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> EliminarAsync(int espectadorId, int usuarioCalificadoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "DELETE FROM CalificacionPerfil WHERE UsuarioCalificadoId = @UsuarioCalificadoId AND UsuarioCalificadorId = @EspectadorId", connection);
            command.Parameters.AddWithValue("@UsuarioCalificadoId", usuarioCalificadoId);
            command.Parameters.AddWithValue("@EspectadorId", espectadorId);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}