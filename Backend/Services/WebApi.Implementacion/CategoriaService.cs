using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class CategoriaService : ICategoriaService
    {

        private static readonly int[] Oficiales = { 1, 2, 3, 4, 5, 6, 7 };

        private readonly string _connectionString;

        public CategoriaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private static Categoria Mapear(SqlDataReader reader)
        {
            return new Categoria
            {
                CategoriaId = DatabaseHelper.ReadInt(reader, "CategoriaId"),
                NombreCategoria = DatabaseHelper.ReadString(reader, "NombreCategoria"),
                Descripcion = DatabaseHelper.ReadString(reader, "Descripcion")
            };
        }

        public async Task<IEnumerable<Categoria>> ObtenerTodosAsync()
        {
            var lista = new List<Categoria>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT CategoriaId, NombreCategoria, Descripcion FROM Categoria", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Categoria?> ObtenerPorIdAsync(int categoriaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT CategoriaId, NombreCategoria, Descripcion FROM Categoria WHERE CategoriaId = @CategoriaId", connection);
            command.Parameters.AddWithValue("@CategoriaId", categoriaId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Categoria?> ObtenerPorNombreAsync(string nombreCategoria)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT CategoriaId, NombreCategoria, Descripcion FROM Categoria WHERE NombreCategoria = @NombreCategoria", connection);
            command.Parameters.AddWithValue("@NombreCategoria", nombreCategoria);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Categoria> CrearAsync(Categoria categoria)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using (var countCommand = new SqlCommand("SELECT COUNT(1) FROM Categoria", connection))
            {
                var total = Convert.ToInt32(await countCommand.ExecuteScalarAsync());
                if (total >= Oficiales.Length)
                    throw new InvalidOperationException("Solo existen las 7 categorias oficiales del proyecto y no se pueden agregar mas.");
            }

            using var command = new SqlCommand(
                "INSERT INTO Categoria (NombreCategoria, Descripcion) OUTPUT INSERTED.CategoriaId VALUES (@NombreCategoria, @Descripcion)", connection);
            command.Parameters.AddWithValue("@NombreCategoria", categoria.NombreCategoria);
            command.Parameters.AddWithValue("@Descripcion", categoria.Descripcion);
            categoria.CategoriaId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return categoria;
        }

        public async Task<Categoria?> ActualizarAsync(Categoria categoria)
        {
            if (Array.IndexOf(Oficiales, categoria.CategoriaId) >= 0)
                throw new InvalidOperationException("No se puede modificar una categoria oficial (Ids 1-7): la taxonomia del proyecto la fija.");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Categoria SET NombreCategoria = @NombreCategoria, Descripcion = @Descripcion WHERE CategoriaId = @CategoriaId", connection);
            command.Parameters.AddWithValue("@CategoriaId", categoria.CategoriaId);
            command.Parameters.AddWithValue("@NombreCategoria", categoria.NombreCategoria);
            command.Parameters.AddWithValue("@Descripcion", categoria.Descripcion);
            return await command.ExecuteNonQueryAsync() > 0 ? categoria : null;
        }

        public async Task<bool> EliminarAsync(int categoriaId)
        {
            if (Array.IndexOf(Oficiales, categoriaId) >= 0)
                throw new InvalidOperationException("No se puede eliminar una categoria oficial (Ids 1-7).");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();



            foreach (var tabla in new[] { "Reto", "Trivia", "Recurso", "HistorialPuntos" })
            {
                using var check = new SqlCommand($"SELECT COUNT(1) FROM {tabla} WHERE CategoriaId = @CategoriaId", connection);
                check.Parameters.AddWithValue("@CategoriaId", categoriaId);
                var usos = Convert.ToInt32(await check.ExecuteScalarAsync());
                if (usos > 0)
                    throw new InvalidOperationException($"La categoria esta en uso en {usos} elemento(s) de {tabla} y no se puede eliminar.");
            }

            using var command = new SqlCommand("DELETE FROM Categoria WHERE CategoriaId = @CategoriaId", connection);
            command.Parameters.AddWithValue("@CategoriaId", categoriaId);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}