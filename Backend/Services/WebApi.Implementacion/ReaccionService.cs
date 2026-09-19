using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;

namespace WebApi.Implementacion
{
    public class ReaccionService : IReaccionService
    {
        private readonly string _connectionString;
        private readonly INotificacionService _notificacionService;
        private readonly IUsuarioService _usuarioService;

        public ReaccionService(
            IConfiguration configuration,
            INotificacionService notificacionService,
            IUsuarioService usuarioService)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
            _notificacionService = notificacionService;
            _usuarioService = usuarioService;
        }

        public async Task<(bool Activa, string Tipo, int Total)> AlternarAsync(int usuarioId, int? publicacionId, int? comentarioId, string tipo)
        {
            if ((publicacionId is null) == (comentarioId is null))
                throw new ArgumentException("Debe indicar exactamente una publicacion o un comentario.");

            tipo = string.IsNullOrWhiteSpace(tipo) ? "ME_GUSTA" : tipo.Trim().ToUpperInvariant();
            if (tipo.Length > 20) tipo = tipo[..20];

            bool activa;
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                var propietarioId = await ObtenerPropietarioAsync(connection, publicacionId, comentarioId);

                var existe = false;
                using (var check = new SqlCommand(
                    publicacionId is not null
                        ? "SELECT COUNT(1) FROM Reaccion WHERE PublicacionId = @Id AND UsuarioId = @UsuarioId"
                        : "SELECT COUNT(1) FROM Reaccion WHERE ComentarioId = @Id AND UsuarioId = @UsuarioId", connection))
                {
                    check.Parameters.AddWithValue("@Id", (object?)publicacionId ?? comentarioId!);
                    check.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    existe = Convert.ToInt32(await check.ExecuteScalarAsync()) > 0;
                }

                if (existe)
                {
                    using var delete = new SqlCommand(
                        publicacionId is not null
                            ? "DELETE FROM Reaccion WHERE PublicacionId = @Id AND UsuarioId = @UsuarioId"
                            : "DELETE FROM Reaccion WHERE ComentarioId = @Id AND UsuarioId = @UsuarioId", connection);
                    delete.Parameters.AddWithValue("@Id", (object?)publicacionId ?? comentarioId!);
                    delete.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    await delete.ExecuteNonQueryAsync();
                    activa = false;
                }
                else
                {
                    using var insert = new SqlCommand(
                        "INSERT INTO Reaccion (PublicacionId, ComentarioId, UsuarioId, Tipo, Fecha) VALUES (@PublicacionId, @ComentarioId, @UsuarioId, @Tipo, @Fecha)", connection);
                    insert.Parameters.AddWithValue("@PublicacionId", (object?)publicacionId ?? DBNull.Value);
                    insert.Parameters.AddWithValue("@ComentarioId", (object?)comentarioId ?? DBNull.Value);
                    insert.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    insert.Parameters.AddWithValue("@Tipo", tipo);
                    insert.Parameters.AddWithValue("@Fecha", DateTime.Now);
                    await insert.ExecuteNonQueryAsync();
                    activa = true;

                    if (propietarioId is int dueno && dueno != usuarioId)
                    {
                        try
                        {
                            var actor = await _usuarioService.ObtenerPorIdAsync(usuarioId);
                            var nombre = actor?.NombreUsuario ?? "Alguien";
                            await _notificacionService.CrearInteraccionAsync(
                                dueno, usuarioId,
                                publicacionId is not null ? $"{nombre} reaccionó a tu publicación" : $"{nombre} reaccionó a tu comentario",
                                publicacionId is not null ? "Le dio me gusta a tu publicación." : "Le dio me gusta a tu comentario.",
                                "ME_GUSTA",
                                publicacionId is not null ? "PUBLICACION" : "COMENTARIO",
                                publicacionId ?? comentarioId);
                        }
                        catch
                        {

                        }
                    }
                }
            }

            var total = publicacionId is not null
                ? await ContarPorPublicacionAsync(publicacionId.Value)
                : await ContarPorComentarioAsync(comentarioId!.Value);

            return (activa, tipo, total);
        }

        private static async Task<int?> ObtenerPropietarioAsync(SqlConnection connection, int? publicacionId, int? comentarioId)
        {
            using var command = new SqlCommand(
                publicacionId is not null
                    ? "SELECT UsuarioId FROM Publicacion WHERE PublicacionId = @Id"
                    : "SELECT UsuarioId FROM Comentario WHERE ComentarioId = @Id", connection);
            command.Parameters.AddWithValue("@Id", (object?)publicacionId ?? comentarioId!);
            var result = await command.ExecuteScalarAsync();
            return result is null or DBNull ? null : Convert.ToInt32(result);
        }

        public async Task<int> ContarPorPublicacionAsync(int publicacionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Reaccion WHERE PublicacionId = @Id", connection);
            command.Parameters.AddWithValue("@Id", publicacionId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        public async Task<int> ContarPorComentarioAsync(int comentarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Reaccion WHERE ComentarioId = @Id", connection);
            command.Parameters.AddWithValue("@Id", comentarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        public async Task<Dictionary<int, int>> ContarPorPublicacionesAsync(IEnumerable<int> publicacionIds)
        {
            var resultado = new Dictionary<int, int>();
            var ids = publicacionIds.Distinct().Take(200).ToList();
            if (ids.Count == 0) return resultado;

            var parametros = string.Join(",", ids.Select((_, i) => $"@Id{i}"));
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT PublicacionId, COUNT(1) AS Total FROM Reaccion WHERE PublicacionId IN ({parametros}) GROUP BY PublicacionId", connection);
            for (var i = 0; i < ids.Count; i++)
                command.Parameters.AddWithValue($"@Id{i}", ids[i]);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                resultado[DatabaseHelper.ReadInt(reader, "PublicacionId")] = DatabaseHelper.ReadInt(reader, "Total");
            return resultado;
        }

        public async Task<Dictionary<int, int>> ContarPorComentariosAsync(IEnumerable<int> comentarioIds)
        {
            var resultado = new Dictionary<int, int>();
            var ids = comentarioIds.Distinct().Take(500).ToList();
            if (ids.Count == 0) return resultado;

            var parametros = string.Join(",", ids.Select((_, i) => $"@Id{i}"));
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT ComentarioId, COUNT(1) AS Total FROM Reaccion WHERE ComentarioId IN ({parametros}) GROUP BY ComentarioId", connection);
            for (var i = 0; i < ids.Count; i++)
                command.Parameters.AddWithValue($"@Id{i}", ids[i]);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                resultado[DatabaseHelper.ReadInt(reader, "ComentarioId")] = DatabaseHelper.ReadInt(reader, "Total");
            return resultado;
        }

        public async Task<IEnumerable<int>> ObtenerPublicacionesReaccionadasAsync(int usuarioId)
        {
            var ids = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT PublicacionId FROM Reaccion WHERE UsuarioId = @UsuarioId AND PublicacionId IS NOT NULL", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) ids.Add(DatabaseHelper.ReadInt(reader, "PublicacionId"));
            return ids;
        }

        public async Task<IEnumerable<int>> ObtenerComentariosReaccionadosAsync(int usuarioId)
        {
            var ids = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT ComentarioId FROM Reaccion WHERE UsuarioId = @UsuarioId AND ComentarioId IS NOT NULL", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) ids.Add(DatabaseHelper.ReadInt(reader, "ComentarioId"));
            return ids;
        }
    }
}
