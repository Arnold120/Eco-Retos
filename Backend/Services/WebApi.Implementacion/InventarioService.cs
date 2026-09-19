using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class InventarioService : IInventarioService
    {
        private readonly string _connectionString;

        public InventarioService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private static Inventario Mapear(SqlDataReader reader)
        {
            return new Inventario
            {
                InventarioId = DatabaseHelper.ReadInt(reader, "InventarioId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                MaterialId = DatabaseHelper.ReadInt(reader, "MaterialId"),
                Cantidad = DatabaseHelper.ReadInt(reader, "Cantidad")
            };
        }

        public async Task<IEnumerable<Inventario>> ObtenerInventarioDeUsuarioAsync(int usuarioId)
        {
            var lista = new List<Inventario>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT InventarioId, UsuarioId, MaterialId, Cantidad FROM Inventario WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Inventario?> ObtenerPorMaterialAsync(int usuarioId, int materialId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT InventarioId, UsuarioId, MaterialId, Cantidad FROM Inventario WHERE UsuarioId = @UsuarioId AND MaterialId = @MaterialId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@MaterialId", materialId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Inventario> AgregarMaterialAsync(Inventario inventario)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Inventario (UsuarioId, MaterialId, Cantidad) OUTPUT INSERTED.InventarioId VALUES (@UsuarioId, @MaterialId, @Cantidad)", connection);
            command.Parameters.AddWithValue("@UsuarioId", inventario.UsuarioId);
            command.Parameters.AddWithValue("@MaterialId", inventario.MaterialId);
            command.Parameters.AddWithValue("@Cantidad", inventario.Cantidad);
            inventario.InventarioId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return inventario;
        }

        public async Task<bool> ActualizarCantidadAsync(int inventarioId, int cantidad)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE Inventario SET Cantidad = @Cantidad WHERE InventarioId = @InventarioId", connection);
            command.Parameters.AddWithValue("@InventarioId", inventarioId);
            command.Parameters.AddWithValue("@Cantidad", cantidad);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<bool> QuitarMaterialAsync(int usuarioId, int materialId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Inventario WHERE UsuarioId = @UsuarioId AND MaterialId = @MaterialId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@MaterialId", materialId);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}