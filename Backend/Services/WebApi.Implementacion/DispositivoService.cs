using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class DispositivoService : IDispositivoService
    {
        private readonly string _connectionString;

        public DispositivoService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<UsuarioDispositivo> RegistrarAsync(UsuarioDispositivo dispositivo)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "MERGE dbo.UsuarioDispositivo AS destino " +
                "USING (SELECT @Token AS Token) AS origen ON destino.Token = origen.Token " +
                "WHEN MATCHED THEN UPDATE SET UsuarioId = @UsuarioId, Plataforma = @Plataforma, " +
                "FechaActualizacion = @FechaActualizacion, Activo = 1 " +
                "WHEN NOT MATCHED THEN INSERT (UsuarioId, Token, Plataforma, FechaRegistro, FechaActualizacion, Activo) " +
                "VALUES (@UsuarioId, @Token, @Plataforma, @FechaRegistro, @FechaActualizacion, 1);", connection);
            command.Parameters.AddWithValue("@UsuarioId", dispositivo.UsuarioId);
            command.Parameters.AddWithValue("@Token", dispositivo.Token);
            command.Parameters.AddWithValue("@Plataforma", dispositivo.Plataforma);
            command.Parameters.AddWithValue("@FechaRegistro", dispositivo.FechaRegistro);
            command.Parameters.AddWithValue("@FechaActualizacion", dispositivo.FechaActualizacion);
            await command.ExecuteNonQueryAsync();
            return dispositivo;
        }

        public async Task<IEnumerable<UsuarioDispositivo>> ObtenerActivosAsync(int usuarioId)
        {
            var lista = new List<UsuarioDispositivo>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT UsuarioDispositivoId, UsuarioId, Token, Plataforma, FechaRegistro, " +
                "FechaActualizacion, Activo FROM dbo.UsuarioDispositivo " +
                "WHERE UsuarioId = @UsuarioId AND Activo = 1", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                lista.Add(new UsuarioDispositivo
                {
                    UsuarioDispositivoId = reader.GetInt32(0),
                    UsuarioId = reader.GetInt32(1),
                    Token = reader.GetString(2),
                    Plataforma = reader.GetString(3),
                    FechaRegistro = reader.GetDateTime(4),
                    FechaActualizacion = reader.GetDateTime(5),
                    Activo = reader.GetBoolean(6)
                });
            }
            return lista;
        }

        public async Task<bool> DesactivarAsync(int usuarioId, string token)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE dbo.UsuarioDispositivo SET Activo = 0, FechaActualizacion = @FechaActualizacion " +
                "WHERE UsuarioId = @UsuarioId AND Token = @Token", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@Token", token);
            command.Parameters.AddWithValue("@FechaActualizacion", DateTime.UtcNow);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}
