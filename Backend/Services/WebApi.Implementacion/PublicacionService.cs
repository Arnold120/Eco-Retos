using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class PublicacionService : IPublicacionService
    {
        private readonly string _connectionString;

        private const string Columnas =
            "PublicacionId, UsuarioId, Contenido, Imagen, Tipo, FechaPublicacion, Estado, " +
            "Ubicacion, Categoria, CompartidoDeId, CompartidoEliminado, Visibilidad, Editada, FechaEdicion";


        private const string ClausulaVisibilidad =
            "AND (Visibilidad = 'PUBLICO' " +
            "OR UsuarioId = @Espectador " +
            "OR (Visibilidad = 'SEGUIDORES' AND EXISTS (SELECT 1 FROM Seguimiento s WHERE s.SeguidorId = @Espectador AND s.SeguidoId = Publicacion.UsuarioId)))";

        public PublicacionService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private static Publicacion Mapear(SqlDataReader reader)
        {
            return new Publicacion
            {
                PublicacionId = DatabaseHelper.ReadInt(reader, "PublicacionId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                Contenido = DatabaseHelper.ReadString(reader, "Contenido"),
                Imagen = reader.IsDBNull(reader.GetOrdinal("Imagen")) ? null : DatabaseHelper.ReadString(reader, "Imagen"),
                Tipo = DatabaseHelper.ReadString(reader, "Tipo"),
                FechaPublicacion = DatabaseHelper.ReadDateTime(reader, "FechaPublicacion"),
                Estado = DatabaseHelper.ReadString(reader, "Estado"),
                Ubicacion = reader.IsDBNull(reader.GetOrdinal("Ubicacion")) ? null : DatabaseHelper.ReadString(reader, "Ubicacion"),
                Categoria = reader.IsDBNull(reader.GetOrdinal("Categoria")) ? null : DatabaseHelper.ReadString(reader, "Categoria"),
                CompartidoDeId = DatabaseHelper.ReadNullableInt(reader, "CompartidoDeId"),
                CompartidoEliminado = DatabaseHelper.ReadBool(reader, "CompartidoEliminado"),
                Visibilidad = DatabaseHelper.ReadString(reader, "Visibilidad"),
                Editada = DatabaseHelper.ReadBool(reader, "Editada"),
                FechaEdicion = DatabaseHelper.ReadNullableDateTime(reader, "FechaEdicion")
            };
        }

        public async Task<IEnumerable<Publicacion>> ObtenerTodasAsync()
        {
            var lista = new List<Publicacion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Publicacion WHERE Estado = 'PUBLICADA' AND Visibilidad = 'PUBLICO'", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Publicacion>> ObtenerPublicacionesActivasAsync(int? espectadorId = null)
        {
            var lista = new List<Publicacion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM Publicacion WHERE Estado = 'PUBLICADA' {ClausulaVisibilidad} ORDER BY FechaPublicacion DESC", connection);
            command.Parameters.AddWithValue("@Espectador", (object?)espectadorId ?? DBNull.Value);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Publicacion>> ObtenerRecientesAsync(int cantidad, int? espectadorId = null)
        {
            var lista = new List<Publicacion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT TOP (@Cantidad) {Columnas} FROM Publicacion WHERE Estado = 'PUBLICADA' {ClausulaVisibilidad} ORDER BY FechaPublicacion DESC", connection);
            command.Parameters.AddWithValue("@Cantidad", Math.Clamp(cantidad, 1, 100));
            command.Parameters.AddWithValue("@Espectador", (object?)espectadorId ?? DBNull.Value);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Publicacion>> ObtenerFeedAsync(int pagina, int tamanoPagina, int? autorId, int? seguidosDe, int? espectadorId = null)
        {
            pagina = Math.Max(pagina, 1);
            tamanoPagina = Math.Clamp(tamanoPagina, 1, 50);
            var offset = (pagina - 1) * tamanoPagina;

            var lista = new List<Publicacion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM Publicacion " +
                "WHERE Estado = 'PUBLICADA' " +
                "AND (@AutorId IS NULL OR UsuarioId = @AutorId) " +
                "AND (@SeguidosDe IS NULL OR EXISTS (SELECT 1 FROM Seguimiento s WHERE s.SeguidorId = @SeguidosDe AND s.SeguidoId = Publicacion.UsuarioId)) " +
                $"{ClausulaVisibilidad} " +
                "ORDER BY FechaPublicacion DESC OFFSET @Offset ROWS FETCH NEXT @Tamano ROWS ONLY", connection);
            command.Parameters.AddWithValue("@AutorId", (object?)autorId ?? DBNull.Value);
            command.Parameters.AddWithValue("@SeguidosDe", (object?)seguidosDe ?? DBNull.Value);
            command.Parameters.AddWithValue("@Espectador", (object?)espectadorId ?? DBNull.Value);
            command.Parameters.AddWithValue("@Offset", offset);
            command.Parameters.AddWithValue("@Tamano", tamanoPagina);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Publicacion>> ObtenerPorTipoAsync(string tipo, int? espectadorId = null)
        {
            var lista = new List<Publicacion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM Publicacion WHERE Tipo = @Tipo AND Estado = 'PUBLICADA' {ClausulaVisibilidad} ORDER BY FechaPublicacion DESC", connection);
            command.Parameters.AddWithValue("@Tipo", tipo);
            command.Parameters.AddWithValue("@Espectador", (object?)espectadorId ?? DBNull.Value);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Publicacion>> BuscarAsync(string termino, int limite, int? espectadorId = null)
        {
            limite = Math.Clamp(limite, 1, 50);
            var lista = new List<Publicacion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT TOP (@Limite) {Columnas} FROM Publicacion " +
                "WHERE Estado = 'PUBLICADA' AND Contenido LIKE @Termino " +
                $"{ClausulaVisibilidad} " +
                "ORDER BY FechaPublicacion DESC", connection);
            command.Parameters.AddWithValue("@Termino", $"%{termino.Trim()}%");
            command.Parameters.AddWithValue("@Limite", limite);
            command.Parameters.AddWithValue("@Espectador", (object?)espectadorId ?? DBNull.Value);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Dictionary<int, Publicacion>> ObtenerPorIdsAsync(IEnumerable<int> publicacionIds)
        {
            var resultado = new Dictionary<int, Publicacion>();
            var ids = publicacionIds.Distinct().Take(200).ToList();
            if (ids.Count == 0) return resultado;

            var parametros = string.Join(",", ids.Select((_, i) => $"@Id{i}"));
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Publicacion WHERE PublicacionId IN ({parametros})", connection);
            for (var i = 0; i < ids.Count; i++)
                command.Parameters.AddWithValue($"@Id{i}", ids[i]);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var publicacion = Mapear(reader);
                resultado[publicacion.PublicacionId] = publicacion;
            }
            return resultado;
        }

        public async Task<Publicacion?> ObtenerPorIdAsync(int publicacionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Publicacion WHERE PublicacionId = @PublicacionId", connection);
            command.Parameters.AddWithValue("@PublicacionId", publicacionId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<IEnumerable<Publicacion>> ObtenerPublicacionesDeUsuarioAsync(int usuarioId, int? espectadorId = null)
        {
            var lista = new List<Publicacion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM Publicacion WHERE UsuarioId = @UsuarioId AND Estado = 'PUBLICADA' {ClausulaVisibilidad} ORDER BY FechaPublicacion DESC", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@Espectador", (object?)espectadorId ?? DBNull.Value);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Publicacion>> ObtenerMencionesAsync(int usuarioId, string nombreUsuario, int? espectadorId = null)
        {
            var lista = new List<Publicacion>();
            if (string.IsNullOrWhiteSpace(nombreUsuario))
                return lista;

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM Publicacion " +
                "WHERE Estado = 'PUBLICADA' AND Contenido LIKE @Mencion " +
                $"{ClausulaVisibilidad} " +
                "ORDER BY FechaPublicacion DESC", connection);
            command.Parameters.AddWithValue("@Mencion", $"%@{nombreUsuario.Trim()}%");
            command.Parameters.AddWithValue("@Espectador", (object?)espectadorId ?? DBNull.Value);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Publicacion> CrearAsync(Publicacion publicacion)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Publicacion (UsuarioId, Contenido, Imagen, Tipo, FechaPublicacion, Estado, Ubicacion, Categoria, CompartidoDeId, Visibilidad) " +
                "OUTPUT INSERTED.PublicacionId VALUES (@UsuarioId, @Contenido, @Imagen, @Tipo, @FechaPublicacion, @Estado, @Ubicacion, @Categoria, @CompartidoDeId, @Visibilidad)", connection);
            command.Parameters.AddWithValue("@UsuarioId", publicacion.UsuarioId);
            command.Parameters.AddWithValue("@Contenido", publicacion.Contenido);
            command.Parameters.AddWithValue("@Imagen", (object?)publicacion.Imagen ?? DBNull.Value);
            command.Parameters.AddWithValue("@Tipo", publicacion.Tipo);
            command.Parameters.AddWithValue("@FechaPublicacion", publicacion.FechaPublicacion);
            command.Parameters.AddWithValue("@Estado", publicacion.Estado);
            command.Parameters.AddWithValue("@Ubicacion", (object?)publicacion.Ubicacion ?? DBNull.Value);
            command.Parameters.AddWithValue("@Categoria", (object?)publicacion.Categoria ?? DBNull.Value);
            command.Parameters.AddWithValue("@CompartidoDeId", (object?)publicacion.CompartidoDeId ?? DBNull.Value);
            command.Parameters.AddWithValue("@Visibilidad", NormalizarVisibilidad(publicacion.Visibilidad));
            publicacion.PublicacionId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return publicacion;
        }

        public async Task<Publicacion?> ActualizarAsync(Publicacion publicacion)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Publicacion SET Contenido = @Contenido, Imagen = @Imagen, Tipo = @Tipo, Estado = @Estado, " +
                "Ubicacion = @Ubicacion, Categoria = @Categoria, Visibilidad = @Visibilidad, Editada = @Editada, FechaEdicion = @FechaEdicion " +
                "WHERE PublicacionId = @PublicacionId", connection);
            command.Parameters.AddWithValue("@PublicacionId", publicacion.PublicacionId);
            command.Parameters.AddWithValue("@Contenido", publicacion.Contenido);
            command.Parameters.AddWithValue("@Imagen", (object?)publicacion.Imagen ?? DBNull.Value);
            command.Parameters.AddWithValue("@Tipo", publicacion.Tipo);
            command.Parameters.AddWithValue("@Estado", publicacion.Estado);
            command.Parameters.AddWithValue("@Ubicacion", (object?)publicacion.Ubicacion ?? DBNull.Value);
            command.Parameters.AddWithValue("@Categoria", (object?)publicacion.Categoria ?? DBNull.Value);
            command.Parameters.AddWithValue("@Visibilidad", NormalizarVisibilidad(publicacion.Visibilidad));
            command.Parameters.AddWithValue("@Editada", publicacion.Editada);
            command.Parameters.AddWithValue("@FechaEdicion", (object?)publicacion.FechaEdicion ?? DBNull.Value);
            return await command.ExecuteNonQueryAsync() > 0 ? publicacion : null;
        }

        public async Task<bool> EliminarAsync(int publicacionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();

            try
            {


                using (var marcar = new SqlCommand(
                    "UPDATE Publicacion SET CompartidoEliminado = 1, CompartidoDeId = NULL WHERE CompartidoDeId = @PublicacionId", connection, transaction))
                {
                    marcar.Parameters.AddWithValue("@PublicacionId", publicacionId);
                    await marcar.ExecuteNonQueryAsync();
                }


                using (var reacciones = new SqlCommand(
                    "DELETE FROM Reaccion WHERE PublicacionId = @PublicacionId " +
                    "OR ComentarioId IN (SELECT ComentarioId FROM Comentario WHERE PublicacionId = @PublicacionId)", connection, transaction))
                {
                    reacciones.Parameters.AddWithValue("@PublicacionId", publicacionId);
                    await reacciones.ExecuteNonQueryAsync();
                }



                using (var respuestas = new SqlCommand(
                    "DELETE FROM Comentario WHERE PublicacionId = @PublicacionId AND ComentarioPadreId IS NOT NULL", connection, transaction))
                {
                    respuestas.Parameters.AddWithValue("@PublicacionId", publicacionId);
                    await respuestas.ExecuteNonQueryAsync();
                }

                using (var comentarios = new SqlCommand(
                    "DELETE FROM Comentario WHERE PublicacionId = @PublicacionId", connection, transaction))
                {
                    comentarios.Parameters.AddWithValue("@PublicacionId", publicacionId);
                    await comentarios.ExecuteNonQueryAsync();
                }

                using (var guardados = new SqlCommand(
                    "DELETE FROM Guardado WHERE PublicacionId = @PublicacionId", connection, transaction))
                {
                    guardados.Parameters.AddWithValue("@PublicacionId", publicacionId);
                    await guardados.ExecuteNonQueryAsync();
                }

                using (var multimedia = new SqlCommand(
                    "DELETE FROM PublicacionMultimedia WHERE PublicacionId = @PublicacionId", connection, transaction))
                {
                    multimedia.Parameters.AddWithValue("@PublicacionId", publicacionId);
                    await multimedia.ExecuteNonQueryAsync();
                }

                using (var command = new SqlCommand(
                    "DELETE FROM Publicacion WHERE PublicacionId = @PublicacionId", connection, transaction))
                {
                    command.Parameters.AddWithValue("@PublicacionId", publicacionId);
                    var eliminada = await command.ExecuteNonQueryAsync() > 0;
                    transaction.Commit();
                    return eliminada;
                }
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        private static string NormalizarVisibilidad(string? visibilidad)
        {
            return (visibilidad ?? "PUBLICO").Trim().ToUpperInvariant() switch
            {
                "SEGUIDORES" => "SEGUIDORES",
                "SOLO_YO" => "SOLO_YO",
                _ => "PUBLICO"
            };
        }

        public async Task<Dictionary<int, int>> ContarCompartidosAsync(IEnumerable<int> publicacionIds)
        {
            var resultado = new Dictionary<int, int>();
            var ids = publicacionIds.Distinct().Take(200).ToList();
            if (ids.Count == 0) return resultado;

            var parametros = string.Join(",", ids.Select((_, i) => $"@Id{i}"));
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT CompartidoDeId, COUNT(1) AS Total FROM Publicacion WHERE Estado = 'PUBLICADA' AND CompartidoDeId IN ({parametros}) GROUP BY CompartidoDeId", connection);
            for (var i = 0; i < ids.Count; i++)
                command.Parameters.AddWithValue($"@Id{i}", ids[i]);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                resultado[DatabaseHelper.ReadInt(reader, "CompartidoDeId")] = DatabaseHelper.ReadInt(reader, "Total");
            return resultado;
        }

        public async Task<int> ContarPublicacionesAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Publicacion WHERE UsuarioId = @UsuarioId AND Estado = 'PUBLICADA'", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }
    }
}
