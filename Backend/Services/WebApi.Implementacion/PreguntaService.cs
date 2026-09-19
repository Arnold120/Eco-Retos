using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class PreguntaService : IPreguntaService
    {
        private readonly string _connectionString;

        public PreguntaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private Pregunta Mapear(SqlDataReader reader)
        {
            return new Pregunta
            {
                PreguntaId = DatabaseHelper.ReadInt(reader, "PreguntaId"),
                TriviaId = DatabaseHelper.ReadInt(reader, "TriviaId"),
                PreguntaTexto = DatabaseHelper.ReadString(reader, "PreguntaTexto"),
                Puntos = DatabaseHelper.ReadInt(reader, "Puntos")
            };
        }

        public async Task<IEnumerable<Pregunta>> ObtenerPorTriviaAsync(int triviaId)
        {
            var lista = new List<Pregunta>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT PreguntaId, TriviaId, PreguntaTexto, Puntos FROM Pregunta WHERE TriviaId = @TriviaId", connection);
            command.Parameters.AddWithValue("@TriviaId", triviaId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Pregunta?> ObtenerPorIdAsync(int preguntaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT PreguntaId, TriviaId, PreguntaTexto, Puntos FROM Pregunta WHERE PreguntaId = @PreguntaId", connection);
            command.Parameters.AddWithValue("@PreguntaId", preguntaId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Pregunta> CrearAsync(Pregunta pregunta)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Pregunta (TriviaId, PreguntaTexto, Puntos) OUTPUT INSERTED.PreguntaId VALUES (@TriviaId, @PreguntaTexto, @Puntos)", connection);
            command.Parameters.AddWithValue("@TriviaId", pregunta.TriviaId);
            command.Parameters.AddWithValue("@PreguntaTexto", pregunta.PreguntaTexto);
            command.Parameters.AddWithValue("@Puntos", pregunta.Puntos);
            pregunta.PreguntaId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return pregunta;
        }

        public async Task<Pregunta?> ActualizarAsync(Pregunta pregunta)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Pregunta SET TriviaId = @TriviaId, PreguntaTexto = @PreguntaTexto, Puntos = @Puntos WHERE PreguntaId = @PreguntaId", connection);
            command.Parameters.AddWithValue("@PreguntaId", pregunta.PreguntaId);
            command.Parameters.AddWithValue("@TriviaId", pregunta.TriviaId);
            command.Parameters.AddWithValue("@PreguntaTexto", pregunta.PreguntaTexto);
            command.Parameters.AddWithValue("@Puntos", pregunta.Puntos);
            return await command.ExecuteNonQueryAsync() > 0 ? pregunta : null;
        }

        public async Task<bool> EliminarAsync(int preguntaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Pregunta WHERE PreguntaId = @PreguntaId", connection);
            command.Parameters.AddWithValue("@PreguntaId", preguntaId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<IEnumerable<Pregunta>> ObtenerConOpcionesAsync(int triviaId)
        {
            var lista = new List<Pregunta>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT PreguntaId, TriviaId, PreguntaTexto, Puntos FROM Pregunta WHERE TriviaId = @TriviaId", connection);
            command.Parameters.AddWithValue("@TriviaId", triviaId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }
    }
}