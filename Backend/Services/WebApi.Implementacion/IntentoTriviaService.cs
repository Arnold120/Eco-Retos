using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class IntentoTriviaService : IIntentoTriviaService
    {
        private readonly string _connectionString;
        private readonly IEvaluadorInsigniasService _evaluadorInsignias;

        public IntentoTriviaService(IConfiguration configuration, IEvaluadorInsigniasService evaluadorInsignias)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
            _evaluadorInsignias = evaluadorInsignias;
        }

        private IntentoTrivia Mapear(SqlDataReader reader)
        {
            return new IntentoTrivia
            {
                IntentoId = DatabaseHelper.ReadInt(reader, "IntentoId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                TriviaId = DatabaseHelper.ReadInt(reader, "TriviaId"),
                Puntuacion = DatabaseHelper.ReadInt(reader, "Puntuacion"),
                FechaInicio = DatabaseHelper.ReadDateTime(reader, "FechaInicio"),
                FechaFinalizacion = DatabaseHelper.ReadNullableDateTime(reader, "FechaFinalizacion")
            };
        }

        public async Task<IEnumerable<IntentoTrivia>> ObtenerIntentosDeUsuarioAsync(int usuarioId)
        {
            var lista = new List<IntentoTrivia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT IntentoId, UsuarioId, TriviaId, Puntuacion, FechaInicio, FechaFinalizacion FROM IntentoTrivia WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<IntentoTrivia>> ObtenerPorTriviaAsync(int triviaId)
        {
            var lista = new List<IntentoTrivia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT IntentoId, UsuarioId, TriviaId, Puntuacion, FechaInicio, FechaFinalizacion FROM IntentoTrivia WHERE TriviaId = @TriviaId", connection);
            command.Parameters.AddWithValue("@TriviaId", triviaId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IntentoTrivia?> ObtenerPorIdAsync(int intentoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT IntentoId, UsuarioId, TriviaId, Puntuacion, FechaInicio, FechaFinalizacion FROM IntentoTrivia WHERE IntentoId = @IntentoId", connection);
            command.Parameters.AddWithValue("@IntentoId", intentoId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<IntentoTrivia> IniciarIntentoAsync(IntentoTrivia intento)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO IntentoTrivia (UsuarioId, TriviaId, Puntuacion, FechaInicio, FechaFinalizacion) OUTPUT INSERTED.IntentoId VALUES (@UsuarioId, @TriviaId, @Puntuacion, @FechaInicio, @FechaFinalizacion)", connection);
            command.Parameters.AddWithValue("@UsuarioId", intento.UsuarioId);
            command.Parameters.AddWithValue("@TriviaId", intento.TriviaId);
            command.Parameters.AddWithValue("@Puntuacion", intento.Puntuacion);
            command.Parameters.AddWithValue("@FechaInicio", intento.FechaInicio);
            command.Parameters.AddWithValue("@FechaFinalizacion", (object?)intento.FechaFinalizacion ?? DBNull.Value);
            intento.IntentoId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return intento;
        }

        public async Task<bool> FinalizarIntentoAsync(int intentoId, int puntuacion)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE IntentoTrivia SET Puntuacion = @Puntuacion, FechaFinalizacion = GETDATE() OUTPUT INSERTED.UsuarioId WHERE IntentoId = @IntentoId", connection);
            command.Parameters.AddWithValue("@IntentoId", intentoId);
            command.Parameters.AddWithValue("@Puntuacion", puntuacion);
            var valor = await command.ExecuteScalarAsync();
            if (valor is null || valor == DBNull.Value) return false;

            try { await _evaluadorInsignias.EvaluarYOtorgarAsync(Convert.ToInt32(valor)); }
            catch { }
            return true;
        }

        public async Task<int?> ObtenerMejorPuntuacionAsync(int usuarioId, int triviaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT MAX(Puntuacion) FROM IntentoTrivia WHERE UsuarioId = @UsuarioId AND TriviaId = @TriviaId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@TriviaId", triviaId);
            var result = await command.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? null : (int)result;
        }
    }
}