using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class MultimediaService : IMultimediaService
    {
        private readonly string _connectionString;

        public MultimediaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private static PublicacionMultimedia Mapear(SqlDataReader reader)
        {
            return new PublicacionMultimedia
            {
                MultimediaId = DatabaseHelper.ReadInt(reader, "MultimediaId"),
                PublicacionId = DatabaseHelper.ReadInt(reader, "PublicacionId"),
                Url = DatabaseHelper.ReadString(reader, "Url"),
                Tipo = DatabaseHelper.ReadString(reader, "Tipo"),
                Duracion = reader.IsDBNull(reader.GetOrdinal("Duracion")) ? null : DatabaseHelper.ReadString(reader, "Duracion"),
                Poster = reader.IsDBNull(reader.GetOrdinal("Poster")) ? null : DatabaseHelper.ReadString(reader, "Poster"),
                Orden = DatabaseHelper.ReadInt(reader, "Orden"),
                FechaCreacion = DatabaseHelper.ReadDateTime(reader, "FechaCreacion")
            };
        }

        public async Task<IEnumerable<PublicacionMultimedia>> ObtenerPorPublicacionAsync(int publicacionId)
        {
            var lista = new List<PublicacionMultimedia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT MultimediaId, PublicacionId, Url, Tipo, Duracion, Poster, Orden, FechaCreacion FROM PublicacionMultimedia WHERE PublicacionId = @PublicacionId ORDER BY Orden", connection);
            command.Parameters.AddWithValue("@PublicacionId", publicacionId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Dictionary<int, List<PublicacionMultimedia>>> ObtenerPorPublicacionesAsync(IEnumerable<int> publicacionIds)
        {
            var resultado = new Dictionary<int, List<PublicacionMultimedia>>();
            var ids = publicacionIds.Distinct().Take(200).ToList();
            if (ids.Count == 0) return resultado;

            var parametros = string.Join(",", ids.Select((_, i) => $"@Id{i}"));
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT MultimediaId, PublicacionId, Url, Tipo, Duracion, Poster, Orden, FechaCreacion FROM PublicacionMultimedia WHERE PublicacionId IN ({parametros}) ORDER BY PublicacionId, Orden", connection);
            for (var i = 0; i < ids.Count; i++)
                command.Parameters.AddWithValue($"@Id{i}", ids[i]);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var item = Mapear(reader);
                if (!resultado.TryGetValue(item.PublicacionId, out var lista))
                {
                    lista = new List<PublicacionMultimedia>();
                    resultado[item.PublicacionId] = lista;
                }
                lista.Add(item);
            }
            return resultado;
        }

        public async Task ReemplazarAsync(int publicacionId, IEnumerable<PublicacionMultimedia> items)
        {
            var lista = items
                .Where(i => !string.IsNullOrWhiteSpace(i.Url))
                .Select((i, index) => new PublicacionMultimedia
                {
                    PublicacionId = publicacionId,
                    Url = i.Url.Trim(),
                    Tipo = string.Equals(i.Tipo, "video", StringComparison.OrdinalIgnoreCase) ? "video" : "imagen",
                    Duracion = i.Duracion,
                    Poster = i.Poster,
                    Orden = index,
                    FechaCreacion = DateTime.Now
                })
                .Take(10)
                .ToList();

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();

            try
            {
                using (var delete = new SqlCommand("DELETE FROM PublicacionMultimedia WHERE PublicacionId = @PublicacionId", connection, transaction))
                {
                    delete.Parameters.AddWithValue("@PublicacionId", publicacionId);
                    await delete.ExecuteNonQueryAsync();
                }

                foreach (var item in lista)
                {
                    using var insert = new SqlCommand(
                        "INSERT INTO PublicacionMultimedia (PublicacionId, Url, Tipo, Duracion, Poster, Orden, FechaCreacion) VALUES (@PublicacionId, @Url, @Tipo, @Duracion, @Poster, @Orden, @FechaCreacion)",
                        connection, transaction);
                    insert.Parameters.AddWithValue("@PublicacionId", item.PublicacionId);
                    insert.Parameters.AddWithValue("@Url", item.Url);
                    insert.Parameters.AddWithValue("@Tipo", item.Tipo);
                    insert.Parameters.AddWithValue("@Duracion", (object?)item.Duracion ?? DBNull.Value);
                    insert.Parameters.AddWithValue("@Poster", (object?)item.Poster ?? DBNull.Value);
                    insert.Parameters.AddWithValue("@Orden", item.Orden);
                    insert.Parameters.AddWithValue("@FechaCreacion", item.FechaCreacion);
                    await insert.ExecuteNonQueryAsync();
                }

                transaction.Commit();
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }
    }
}

