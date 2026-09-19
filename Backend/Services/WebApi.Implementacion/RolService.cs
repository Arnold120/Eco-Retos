using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class RolService : IRolService
    {
        private readonly string _connectionString;

        public RolService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private Rol MapearRol(SqlDataReader reader)
        {
            return new Rol
            {
                RolId = DatabaseHelper.ReadInt(reader, "RolId"),
                NombreRol = DatabaseHelper.ReadString(reader, "NombreRol"),
                Descripcion = DatabaseHelper.ReadString(reader, "Descripcion")
            };
        }

        public async Task<IEnumerable<Rol>> ObtenerTodosAsync()
        {
            var lista = new List<Rol>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RolId, NombreRol, Descripcion FROM Rol", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                lista.Add(MapearRol(reader));
            return lista;
        }

        public async Task<Rol?> ObtenerPorIdAsync(int rolId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RolId, NombreRol, Descripcion FROM Rol WHERE RolId = @RolId", connection);
            command.Parameters.AddWithValue("@RolId", rolId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapearRol(reader) : null;
        }

        public async Task<Rol?> ObtenerPorNombreAsync(string nombreRol)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RolId, NombreRol, Descripcion FROM Rol WHERE NombreRol = @NombreRol", connection);
            command.Parameters.AddWithValue("@NombreRol", nombreRol);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapearRol(reader) : null;
        }

        public async Task<Rol> CrearAsync(Rol rol)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Rol (NombreRol, Descripcion) OUTPUT INSERTED.RolId VALUES (@NombreRol, @Descripcion)", connection);
            command.Parameters.AddWithValue("@NombreRol", rol.NombreRol);
            command.Parameters.AddWithValue("@Descripcion", rol.Descripcion);
            rol.RolId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return rol;
        }

        public async Task<Rol?> ActualizarAsync(Rol rol)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Rol SET NombreRol = @NombreRol, Descripcion = @Descripcion WHERE RolId = @RolId", connection);
            command.Parameters.AddWithValue("@RolId", rol.RolId);
            command.Parameters.AddWithValue("@NombreRol", rol.NombreRol);
            command.Parameters.AddWithValue("@Descripcion", rol.Descripcion);
            var rows = await command.ExecuteNonQueryAsync();
            return rows > 0 ? rol : null;
        }

        public async Task<bool> EliminarAsync(int rolId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Rol WHERE RolId = @RolId", connection);
            command.Parameters.AddWithValue("@RolId", rolId);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}
