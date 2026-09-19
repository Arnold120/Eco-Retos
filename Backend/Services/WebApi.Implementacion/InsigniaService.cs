using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class InsigniaService : IInsigniaService
    {
        private readonly string _connectionString;

        public InsigniaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private static Insignia Mapear(SqlDataReader reader)
        {
            return new Insignia
            {
                InsigniaId = DatabaseHelper.ReadInt(reader, "InsigniaId"),
                NombreInsignia = DatabaseHelper.ReadString(reader, "NombreInsignia"),
                Descripcion = DatabaseHelper.ReadString(reader, "Descripcion"),
                Requisito = DatabaseHelper.ReadString(reader, "Requisito"),
                Imagen = reader.IsDBNull(reader.GetOrdinal("Imagen")) ? null : DatabaseHelper.ReadString(reader, "Imagen"),
                MonedasRecompensa = DatabaseHelper.ReadInt(reader, "MonedasRecompensa")
            };
        }

        public async Task<IEnumerable<Insignia>> ObtenerTodasAsync()
        {
            var lista = new List<Insignia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT InsigniaId, NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa FROM Insignia", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Insignia?> ObtenerPorIdAsync(int insigniaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT InsigniaId, NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa FROM Insignia WHERE InsigniaId = @InsigniaId", connection);
            command.Parameters.AddWithValue("@InsigniaId", insigniaId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Insignia?> ObtenerPorNombreAsync(string nombreInsignia)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT InsigniaId, NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa FROM Insignia WHERE NombreInsignia = @NombreInsignia", connection);
            command.Parameters.AddWithValue("@NombreInsignia", nombreInsignia);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Insignia> CrearAsync(Insignia insignia)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) OUTPUT INSERTED.InsigniaId VALUES (@NombreInsignia, @Descripcion, @Requisito, @Imagen, @MonedasRecompensa)", connection);
            command.Parameters.AddWithValue("@NombreInsignia", insignia.NombreInsignia);
            command.Parameters.AddWithValue("@Descripcion", insignia.Descripcion);
            command.Parameters.AddWithValue("@Requisito", insignia.Requisito);
            command.Parameters.AddWithValue("@Imagen", (object?)insignia.Imagen ?? DBNull.Value);
            command.Parameters.AddWithValue("@MonedasRecompensa", insignia.MonedasRecompensa);
            insignia.InsigniaId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return insignia;
        }

        public async Task<Insignia?> ActualizarAsync(Insignia insignia)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Insignia SET NombreInsignia = @NombreInsignia, Descripcion = @Descripcion, Requisito = @Requisito, Imagen = @Imagen, MonedasRecompensa = @MonedasRecompensa WHERE InsigniaId = @InsigniaId", connection);
            command.Parameters.AddWithValue("@InsigniaId", insignia.InsigniaId);
            command.Parameters.AddWithValue("@NombreInsignia", insignia.NombreInsignia);
            command.Parameters.AddWithValue("@Descripcion", insignia.Descripcion);
            command.Parameters.AddWithValue("@Requisito", insignia.Requisito);
            command.Parameters.AddWithValue("@Imagen", (object?)insignia.Imagen ?? DBNull.Value);
            command.Parameters.AddWithValue("@MonedasRecompensa", insignia.MonedasRecompensa);
            return await command.ExecuteNonQueryAsync() > 0 ? insignia : null;
        }

        public async Task<bool> EliminarAsync(int insigniaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Insignia WHERE InsigniaId = @InsigniaId", connection);
            command.Parameters.AddWithValue("@InsigniaId", insigniaId);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}
