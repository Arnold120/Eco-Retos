using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class OpcionRespuestaService : IOpcionRespuestaService
    {
        private readonly string _connectionString;

        public OpcionRespuestaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private OpcionRespuesta Mapear(SqlDataReader reader)
        {
            return new OpcionRespuesta
            {
                OpcionId = DatabaseHelper.ReadInt(reader, "OpcionId"),
                PreguntaId = DatabaseHelper.ReadInt(reader, "PreguntaId"),
                TextoOpcion = DatabaseHelper.ReadString(reader, "TextoOpcion"),
                EsCorrecta = DatabaseHelper.ReadBool(reader, "EsCorrecta")
            };
        }

        public async Task<IEnumerable<OpcionRespuesta>> ObtenerPorPreguntaAsync(int preguntaId)
        {
            var lista = new List<OpcionRespuesta>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT OpcionId, PreguntaId, TextoOpcion, EsCorrecta FROM OpcionRespuesta WHERE PreguntaId = @PreguntaId", connection);
            command.Parameters.AddWithValue("@PreguntaId", preguntaId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<OpcionRespuesta?> ObtenerPorIdAsync(int opcionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT OpcionId, PreguntaId, TextoOpcion, EsCorrecta FROM OpcionRespuesta WHERE OpcionId = @OpcionId", connection);
            command.Parameters.AddWithValue("@OpcionId", opcionId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<OpcionRespuesta> CrearAsync(OpcionRespuesta opcion)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO OpcionRespuesta (PreguntaId, TextoOpcion, EsCorrecta) OUTPUT INSERTED.OpcionId VALUES (@PreguntaId, @TextoOpcion, @EsCorrecta)", connection);
            command.Parameters.AddWithValue("@PreguntaId", opcion.PreguntaId);
            command.Parameters.AddWithValue("@TextoOpcion", opcion.TextoOpcion);
            command.Parameters.AddWithValue("@EsCorrecta", opcion.EsCorrecta);
            opcion.OpcionId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return opcion;
        }

        public async Task<OpcionRespuesta?> ActualizarAsync(OpcionRespuesta opcion)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE OpcionRespuesta SET PreguntaId = @PreguntaId, TextoOpcion = @TextoOpcion, EsCorrecta = @EsCorrecta WHERE OpcionId = @OpcionId", connection);
            command.Parameters.AddWithValue("@OpcionId", opcion.OpcionId);
            command.Parameters.AddWithValue("@PreguntaId", opcion.PreguntaId);
            command.Parameters.AddWithValue("@TextoOpcion", opcion.TextoOpcion);
            command.Parameters.AddWithValue("@EsCorrecta", opcion.EsCorrecta);
            return await command.ExecuteNonQueryAsync() > 0 ? opcion : null;
        }

        public async Task<bool> EliminarAsync(int opcionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM OpcionRespuesta WHERE OpcionId = @OpcionId", connection);
            command.Parameters.AddWithValue("@OpcionId", opcionId);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}