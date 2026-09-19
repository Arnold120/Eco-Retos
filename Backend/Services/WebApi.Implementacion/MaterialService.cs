using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class MaterialService : IMaterialService
    {
        private readonly string _connectionString;

        public MaterialService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private static Material Mapear(SqlDataReader reader)
        {
            return new Material
            {
                MaterialId = DatabaseHelper.ReadInt(reader, "MaterialId"),
                NombreMaterial = DatabaseHelper.ReadString(reader, "NombreMaterial"),
                Descripcion = DatabaseHelper.ReadString(reader, "Descripcion"),
                Tipo = DatabaseHelper.ReadString(reader, "Tipo"),
                PrecioMonedas = DatabaseHelper.ReadInt(reader, "PrecioMonedas"),
                CantidadDisponible = DatabaseHelper.ReadInt(reader, "CantidadDisponible"),
                Imagen = reader.IsDBNull(reader.GetOrdinal("Imagen")) ? null : DatabaseHelper.ReadString(reader, "Imagen"),
                Estado = DatabaseHelper.ReadString(reader, "Estado")
            };
        }

        public async Task<IEnumerable<Material>> ObtenerTodosAsync()
        {
            var lista = new List<Material>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT MaterialId, NombreMaterial, Descripcion, Tipo, PrecioMonedas, CantidadDisponible, Imagen, Estado FROM Material", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Material?> ObtenerPorIdAsync(int materialId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT MaterialId, NombreMaterial, Descripcion, Tipo, PrecioMonedas, CantidadDisponible, Imagen, Estado FROM Material WHERE MaterialId = @MaterialId", connection);
            command.Parameters.AddWithValue("@MaterialId", materialId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<IEnumerable<Material>> ObtenerDisponiblesAsync()
        {
            var lista = new List<Material>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT MaterialId, NombreMaterial, Descripcion, Tipo, PrecioMonedas, CantidadDisponible, Imagen, Estado FROM Material WHERE Estado = 'DISPONIBLE' AND CantidadDisponible > 0", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Material>> ObtenerPorTipoAsync(string tipo)
        {
            var lista = new List<Material>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT MaterialId, NombreMaterial, Descripcion, Tipo, PrecioMonedas, CantidadDisponible, Imagen, Estado FROM Material WHERE Tipo = @Tipo", connection);
            command.Parameters.AddWithValue("@Tipo", tipo);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Material> CrearAsync(Material material)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Material (NombreMaterial, Descripcion, Tipo, PrecioMonedas, CantidadDisponible, Imagen, Estado) OUTPUT INSERTED.MaterialId VALUES (@NombreMaterial, @Descripcion, @Tipo, @PrecioMonedas, @CantidadDisponible, @Imagen, @Estado)", connection);
            command.Parameters.AddWithValue("@NombreMaterial", material.NombreMaterial);
            command.Parameters.AddWithValue("@Descripcion", material.Descripcion);
            command.Parameters.AddWithValue("@Tipo", material.Tipo);
            command.Parameters.AddWithValue("@PrecioMonedas", material.PrecioMonedas);
            command.Parameters.AddWithValue("@CantidadDisponible", material.CantidadDisponible);
            command.Parameters.AddWithValue("@Imagen", (object?)material.Imagen ?? DBNull.Value);
            command.Parameters.AddWithValue("@Estado", material.Estado);
            material.MaterialId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return material;
        }

        public async Task<Material?> ActualizarAsync(Material material)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Material SET NombreMaterial = @NombreMaterial, Descripcion = @Descripcion, Tipo = @Tipo, PrecioMonedas = @PrecioMonedas, CantidadDisponible = @CantidadDisponible, Imagen = @Imagen, Estado = @Estado WHERE MaterialId = @MaterialId", connection);
            command.Parameters.AddWithValue("@MaterialId", material.MaterialId);
            command.Parameters.AddWithValue("@NombreMaterial", material.NombreMaterial);
            command.Parameters.AddWithValue("@Descripcion", material.Descripcion);
            command.Parameters.AddWithValue("@Tipo", material.Tipo);
            command.Parameters.AddWithValue("@PrecioMonedas", material.PrecioMonedas);
            command.Parameters.AddWithValue("@CantidadDisponible", material.CantidadDisponible);
            command.Parameters.AddWithValue("@Imagen", (object?)material.Imagen ?? DBNull.Value);
            command.Parameters.AddWithValue("@Estado", material.Estado);
            return await command.ExecuteNonQueryAsync() > 0 ? material : null;
        }

        public async Task<bool> EliminarAsync(int materialId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Material WHERE MaterialId = @MaterialId", connection);
            command.Parameters.AddWithValue("@MaterialId", materialId);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}
