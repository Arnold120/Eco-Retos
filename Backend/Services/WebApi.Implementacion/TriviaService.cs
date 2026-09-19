using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class TriviaService : ITriviaService
    {
        private readonly string _connectionString;

        public TriviaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private Trivia Mapear(SqlDataReader reader)
        {
            return new Trivia
            {
                TriviaId = DatabaseHelper.ReadInt(reader, "TriviaId"),
                CategoriaId = DatabaseHelper.ReadInt(reader, "CategoriaId"),
                Titulo = DatabaseHelper.ReadString(reader, "Titulo"),
                Descripcion = DatabaseHelper.ReadString(reader, "Descripcion"),
                Dificultad = DatabaseHelper.ReadString(reader, "Dificultad"),
                PuntosMaximos = DatabaseHelper.ReadInt(reader, "PuntosMaximos"),
                Estado = DatabaseHelper.ReadString(reader, "Estado")
            };
        }

        public async Task<IEnumerable<Trivia>> ObtenerTodosAsync()
        {
            var lista = new List<Trivia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT TriviaId, CategoriaId, Titulo, Descripcion, Dificultad, PuntosMaximos, Estado FROM Trivia", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Trivia?> ObtenerPorIdAsync(int triviaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT TriviaId, CategoriaId, Titulo, Descripcion, Dificultad, PuntosMaximos, Estado FROM Trivia WHERE TriviaId = @TriviaId", connection);
            command.Parameters.AddWithValue("@TriviaId", triviaId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<IEnumerable<Trivia>> ObtenerActivasAsync()
        {
            var lista = new List<Trivia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT TriviaId, CategoriaId, Titulo, Descripcion, Dificultad, PuntosMaximos, Estado FROM Trivia WHERE Estado = 'ACTIVA'", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Trivia>> ObtenerPorCategoriaAsync(int categoriaId)
        {
            var lista = new List<Trivia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT TriviaId, CategoriaId, Titulo, Descripcion, Dificultad, PuntosMaximos, Estado FROM Trivia WHERE CategoriaId = @CategoriaId", connection);
            command.Parameters.AddWithValue("@CategoriaId", categoriaId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Trivia>> ObtenerPorDificultadAsync(string dificultad)
        {
            var lista = new List<Trivia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT TriviaId, CategoriaId, Titulo, Descripcion, Dificultad, PuntosMaximos, Estado FROM Trivia WHERE Dificultad = @Dificultad", connection);
            command.Parameters.AddWithValue("@Dificultad", dificultad);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Trivia> CrearAsync(Trivia trivia)
        {
            if (trivia.CategoriaId < 1 || trivia.CategoriaId > 7)
                throw new InvalidOperationException("La categoria debe ser una de las 7 categorias oficiales (1-7).");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Trivia (CategoriaId, Titulo, Descripcion, Dificultad, PuntosMaximos, Estado) OUTPUT INSERTED.TriviaId VALUES (@CategoriaId, @Titulo, @Descripcion, @Dificultad, @PuntosMaximos, @Estado)", connection);
            command.Parameters.AddWithValue("@CategoriaId", trivia.CategoriaId);
            command.Parameters.AddWithValue("@Titulo", trivia.Titulo);
            command.Parameters.AddWithValue("@Descripcion", trivia.Descripcion);
            command.Parameters.AddWithValue("@Dificultad", trivia.Dificultad);
            command.Parameters.AddWithValue("@PuntosMaximos", trivia.PuntosMaximos);
            command.Parameters.AddWithValue("@Estado", trivia.Estado);
            trivia.TriviaId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return trivia;
        }

        public async Task<Trivia?> ActualizarAsync(Trivia trivia)
        {
            if (trivia.CategoriaId < 1 || trivia.CategoriaId > 7)
                throw new InvalidOperationException("La categoria debe ser una de las 7 categorias oficiales (1-7).");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Trivia SET CategoriaId = @CategoriaId, Titulo = @Titulo, Descripcion = @Descripcion, Dificultad = @Dificultad, PuntosMaximos = @PuntosMaximos, Estado = @Estado WHERE TriviaId = @TriviaId", connection);
            command.Parameters.AddWithValue("@TriviaId", trivia.TriviaId);
            command.Parameters.AddWithValue("@CategoriaId", trivia.CategoriaId);
            command.Parameters.AddWithValue("@Titulo", trivia.Titulo);
            command.Parameters.AddWithValue("@Descripcion", trivia.Descripcion);
            command.Parameters.AddWithValue("@Dificultad", trivia.Dificultad);
            command.Parameters.AddWithValue("@PuntosMaximos", trivia.PuntosMaximos);
            command.Parameters.AddWithValue("@Estado", trivia.Estado);
            return await command.ExecuteNonQueryAsync() > 0 ? trivia : null;
        }

        public async Task<bool> EliminarAsync(int triviaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Trivia WHERE TriviaId = @TriviaId", connection);
            command.Parameters.AddWithValue("@TriviaId", triviaId);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}