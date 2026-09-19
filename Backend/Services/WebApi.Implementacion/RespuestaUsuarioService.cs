using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class RespuestaUsuarioService : IRespuestaUsuarioService
    {
        private readonly string _connectionString;

        public RespuestaUsuarioService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private RespuestaUsuario Mapear(SqlDataReader reader)
        {
            return new RespuestaUsuario
            {
                RespuestaId = DatabaseHelper.ReadInt(reader, "RespuestaId"),
                IntentoId = DatabaseHelper.ReadInt(reader, "IntentoId"),
                PreguntaId = DatabaseHelper.ReadInt(reader, "PreguntaId"),
                OpcionId = DatabaseHelper.ReadInt(reader, "OpcionId"),
                EsCorrecta = DatabaseHelper.ReadBool(reader, "EsCorrecta")
            };
        }

        public async Task<IEnumerable<RespuestaUsuario>> ObtenerRespuestasDeIntentoAsync(int intentoId)
        {
            var lista = new List<RespuestaUsuario>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RespuestaId, IntentoId, PreguntaId, OpcionId, EsCorrecta FROM RespuestaUsuario WHERE IntentoId = @IntentoId", connection);
            command.Parameters.AddWithValue("@IntentoId", intentoId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<RespuestaUsuario> RegistrarRespuestaAsync(RespuestaUsuario respuesta)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO RespuestaUsuario (IntentoId, PreguntaId, OpcionId, EsCorrecta) OUTPUT INSERTED.RespuestaId VALUES (@IntentoId, @PreguntaId, @OpcionId, @EsCorrecta)", connection);
            command.Parameters.AddWithValue("@IntentoId", respuesta.IntentoId);
            command.Parameters.AddWithValue("@PreguntaId", respuesta.PreguntaId);
            command.Parameters.AddWithValue("@OpcionId", respuesta.OpcionId);
            command.Parameters.AddWithValue("@EsCorrecta", respuesta.EsCorrecta);
            respuesta.RespuestaId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return respuesta;
        }

        public async Task<int> ContarCorrectasAsync(int intentoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM RespuestaUsuario WHERE IntentoId = @IntentoId AND EsCorrecta = 1", connection);
            command.Parameters.AddWithValue("@IntentoId", intentoId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }
    }
}