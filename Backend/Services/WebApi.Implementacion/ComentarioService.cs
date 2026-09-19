using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class ComentarioService : IComentarioService
    {
        private readonly string _connectionString;
        private readonly IPublicacionService _publicacionService;
        private readonly IUsuarioService _usuarioService;
        private readonly INotificacionService _notificacionService;

        private const string Columnas =
            "ComentarioId, PublicacionId, UsuarioId, ComentarioTexto, FechaComentario, ComentarioPadreId, Editado, Estado";

        private const string FiltroVisible = "(Estado IS NULL OR Estado <> 'OCULTA')";

        public ComentarioService(
            IConfiguration configuration,
            IPublicacionService publicacionService,
            IUsuarioService usuarioService,
            INotificacionService notificacionService)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
            _publicacionService = publicacionService;
            _usuarioService = usuarioService;
            _notificacionService = notificacionService;
        }

        private static Comentario Mapear(SqlDataReader reader)
        {
            return new Comentario
            {
                ComentarioId = DatabaseHelper.ReadInt(reader, "ComentarioId"),
                PublicacionId = DatabaseHelper.ReadInt(reader, "PublicacionId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                ComentarioTexto = DatabaseHelper.ReadString(reader, "ComentarioTexto"),
                FechaComentario = DatabaseHelper.ReadDateTime(reader, "FechaComentario"),
                ComentarioPadreId = DatabaseHelper.ReadNullableInt(reader, "ComentarioPadreId"),
                Editado = DatabaseHelper.ReadBool(reader, "Editado"),
                Estado = reader.IsDBNull(reader.GetOrdinal("Estado")) ? "ACTIVO" : DatabaseHelper.ReadString(reader, "Estado")
            };
        }

        public async Task<IEnumerable<Comentario>> ObtenerComentariosDePublicacionAsync(int publicacionId)
        {
            var lista = new List<Comentario>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Comentario WHERE PublicacionId = @PublicacionId AND {FiltroVisible} ORDER BY FechaComentario ASC", connection);
            command.Parameters.AddWithValue("@PublicacionId", publicacionId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Comentario?> ObtenerPorIdAsync(int comentarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Comentario WHERE ComentarioId = @ComentarioId", connection);
            command.Parameters.AddWithValue("@ComentarioId", comentarioId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Comentario> CrearComentarioAsync(Comentario comentario)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand(
                    "INSERT INTO Comentario (PublicacionId, UsuarioId, ComentarioTexto, FechaComentario, ComentarioPadreId) " +
                    "OUTPUT INSERTED.ComentarioId VALUES (@PublicacionId, @UsuarioId, @ComentarioTexto, @FechaComentario, @ComentarioPadreId)", connection);
                command.Parameters.AddWithValue("@PublicacionId", comentario.PublicacionId);
                command.Parameters.AddWithValue("@UsuarioId", comentario.UsuarioId);
                command.Parameters.AddWithValue("@ComentarioTexto", comentario.ComentarioTexto);
                command.Parameters.AddWithValue("@FechaComentario", comentario.FechaComentario);
                command.Parameters.AddWithValue("@ComentarioPadreId", (object?)comentario.ComentarioPadreId ?? DBNull.Value);
                comentario.ComentarioId = Convert.ToInt32(await command.ExecuteScalarAsync());
            }

            await NotificarComentarioAsync(comentario);
            return comentario;
        }

        private async Task NotificarComentarioAsync(Comentario comentario)
        {
            try
            {
                var actor = await _usuarioService.ObtenerPorIdAsync(comentario.UsuarioId);
                var nombreActor = actor?.NombreUsuario ?? "Alguien";
                var extracto = comentario.ComentarioTexto.Length > 90
                    ? comentario.ComentarioTexto[..90] + "..."
                    : comentario.ComentarioTexto;

                if (comentario.ComentarioPadreId is int padreId)
                {
                    var padre = await ObtenerPorIdAsync(padreId);
                    if (padre is not null)
                    {
                        await _notificacionService.CrearInteraccionAsync(
                            padre.UsuarioId, comentario.UsuarioId,
                            $"{nombreActor} respondió tu comentario",
                            extracto, "RESPUESTA", "PUBLICACION", comentario.PublicacionId);
                    }
                    return;
                }

                var publicacion = await _publicacionService.ObtenerPorIdAsync(comentario.PublicacionId);
                if (publicacion is not null)
                {
                    await _notificacionService.CrearInteraccionAsync(
                        publicacion.UsuarioId, comentario.UsuarioId,
                        $"{nombreActor} comentó tu publicación",
                        extracto, "COMENTARIO", "PUBLICACION", comentario.PublicacionId);
                }
            }
            catch
            {

            }
        }

        public async Task<Comentario?> ActualizarAsync(Comentario comentario)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE Comentario SET ComentarioTexto = @ComentarioTexto, Editado = 1 WHERE ComentarioId = @ComentarioId", connection);
            command.Parameters.AddWithValue("@ComentarioId", comentario.ComentarioId);
            command.Parameters.AddWithValue("@ComentarioTexto", comentario.ComentarioTexto);
            if (await command.ExecuteNonQueryAsync() == 0) return null;
            comentario.Editado = true;
            return comentario;
        }

        public async Task<bool> EliminarAsync(int comentarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();

            try
            {

                using (var reacciones = new SqlCommand(
                    "DELETE FROM Reaccion WHERE ComentarioId = @ComentarioId " +
                    "OR ComentarioId IN (SELECT ComentarioId FROM Comentario WHERE ComentarioPadreId = @ComentarioId)", connection, transaction))
                {
                    reacciones.Parameters.AddWithValue("@ComentarioId", comentarioId);
                    await reacciones.ExecuteNonQueryAsync();
                }


                using (var respuestas = new SqlCommand(
                    "DELETE FROM Comentario WHERE ComentarioPadreId = @ComentarioId", connection, transaction))
                {
                    respuestas.Parameters.AddWithValue("@ComentarioId", comentarioId);
                    await respuestas.ExecuteNonQueryAsync();
                }

                using (var command = new SqlCommand(
                    "DELETE FROM Comentario WHERE ComentarioId = @ComentarioId", connection, transaction))
                {
                    command.Parameters.AddWithValue("@ComentarioId", comentarioId);
                    var eliminado = await command.ExecuteNonQueryAsync() > 0;
                    transaction.Commit();
                    return eliminado;
                }
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<int> ContarComentariosAsync(int publicacionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT COUNT(1) FROM Comentario WHERE PublicacionId = @PublicacionId AND {FiltroVisible}", connection);
            command.Parameters.AddWithValue("@PublicacionId", publicacionId);
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
                $"SELECT PublicacionId, COUNT(1) AS Total FROM Comentario WHERE PublicacionId IN ({parametros}) AND Estado <> 'OCULTA' GROUP BY PublicacionId", connection);
            for (var i = 0; i < ids.Count; i++)
                command.Parameters.AddWithValue($"@Id{i}", ids[i]);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                resultado[DatabaseHelper.ReadInt(reader, "PublicacionId")] = DatabaseHelper.ReadInt(reader, "Total");
            return resultado;
        }
    }
}
