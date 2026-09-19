using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class UsuarioInsigniaService : IUsuarioInsigniaService
    {
        private readonly string _connectionString;

        public UsuarioInsigniaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private UsuarioInsignia Mapear(SqlDataReader reader)
        {
            return new UsuarioInsignia
            {
                UsuarioInsigniaId = DatabaseHelper.ReadInt(reader, "UsuarioInsigniaId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                InsigniaId = DatabaseHelper.ReadInt(reader, "InsigniaId"),
                FechaObtencion = DatabaseHelper.ReadDateTime(reader, "FechaObtencion")
            };
        }

        public async Task<IEnumerable<UsuarioInsignia>> ObtenerTodosAsync()
        {
            var lista = new List<UsuarioInsignia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioInsigniaId, UsuarioId, InsigniaId, FechaObtencion FROM UsuarioInsignia", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<UsuarioInsignia>> ObtenerInsigniasDeUsuarioAsync(int usuarioId)
        {
            var lista = new List<UsuarioInsignia>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioInsigniaId, UsuarioId, InsigniaId, FechaObtencion FROM UsuarioInsignia WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<UsuarioInsignia> OtorgarInsigniaAsync(UsuarioInsignia usuarioInsignia)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO UsuarioInsignia (UsuarioId, InsigniaId, FechaObtencion) OUTPUT INSERTED.UsuarioInsigniaId VALUES (@UsuarioId, @InsigniaId, @FechaObtencion)", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioInsignia.UsuarioId);
            command.Parameters.AddWithValue("@InsigniaId", usuarioInsignia.InsigniaId);
            command.Parameters.AddWithValue("@FechaObtencion", usuarioInsignia.FechaObtencion);
            usuarioInsignia.UsuarioInsigniaId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return usuarioInsignia;
        }

        public async Task<bool> UsuarioTieneInsigniaAsync(int usuarioId, int insigniaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM UsuarioInsignia WHERE UsuarioId = @UsuarioId AND InsigniaId = @InsigniaId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@InsigniaId", insigniaId);
            return Convert.ToInt32(await command.ExecuteScalarAsync()) > 0;
        }

        public async Task<int> ContarInsigniasAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM UsuarioInsignia WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }
    }
}
