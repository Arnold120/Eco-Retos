using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class UsuarioRolService : IUsuarioRolService
    {
        private readonly string _connectionString;

        public UsuarioRolService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private UsuarioRol MapearUsuarioRol(SqlDataReader reader)
        {
            return new UsuarioRol
            {
                UsuarioRolId = DatabaseHelper.ReadInt(reader, "UsuarioRolId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                RolId = DatabaseHelper.ReadInt(reader, "RolId")
            };
        }

        public async Task<IEnumerable<UsuarioRol>> ObtenerTodosAsync()
        {
            var lista = new List<UsuarioRol>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioRolId, UsuarioId, RolId FROM UsuarioRol", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                lista.Add(MapearUsuarioRol(reader));
            return lista;
        }

        public async Task<IEnumerable<UsuarioRol>> ObtenerRolesPorUsuarioAsync(int usuarioId)
        {
            var lista = new List<UsuarioRol>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioRolId, UsuarioId, RolId FROM UsuarioRol WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                lista.Add(MapearUsuarioRol(reader));
            return lista;
        }

        public async Task<IEnumerable<UsuarioRol>> ObtenerUsuariosPorRolAsync(int rolId)
        {
            var lista = new List<UsuarioRol>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioRolId, UsuarioId, RolId FROM UsuarioRol WHERE RolId = @RolId", connection);
            command.Parameters.AddWithValue("@RolId", rolId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                lista.Add(MapearUsuarioRol(reader));
            return lista;
        }

        public async Task<UsuarioRol> AsignarRolAsync(UsuarioRol usuarioRol)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO UsuarioRol (UsuarioId, RolId) OUTPUT INSERTED.UsuarioRolId VALUES (@UsuarioId, @RolId)", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioRol.UsuarioId);
            command.Parameters.AddWithValue("@RolId", usuarioRol.RolId);
            usuarioRol.UsuarioRolId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return usuarioRol;
        }

        public async Task<bool> QuitarRolAsync(int usuarioId, int rolId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM UsuarioRol WHERE UsuarioId = @UsuarioId AND RolId = @RolId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@RolId", rolId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<bool> UsuarioTieneRolAsync(int usuarioId, int rolId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM UsuarioRol WHERE UsuarioId = @UsuarioId AND RolId = @RolId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@RolId", rolId);
            return Convert.ToInt32(await command.ExecuteScalarAsync()) > 0;
        }
    }
}
