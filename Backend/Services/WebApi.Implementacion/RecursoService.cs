using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class RecursoService : IRecursoService
    {
        private readonly string _connectionString;

        public RecursoService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private static Recurso Mapear(SqlDataReader reader)
        {
            return new Recurso
            {
                RecursoId = DatabaseHelper.ReadInt(reader, "RecursoId"),
                CategoriaId = DatabaseHelper.ReadInt(reader, "CategoriaId"),
                Titulo = DatabaseHelper.ReadString(reader, "Titulo"),
                Descripcion = DatabaseHelper.ReadString(reader, "Descripcion"),
                Tipo = DatabaseHelper.ReadString(reader, "Tipo"),
                URL = reader.IsDBNull(reader.GetOrdinal("URL")) ? null : DatabaseHelper.ReadString(reader, "URL"),
                FechaPublicacion = DatabaseHelper.ReadDateTime(reader, "FechaPublicacion"),
                Estado = DatabaseHelper.ReadString(reader, "Estado")
            };
        }

        public async Task<IEnumerable<Recurso>> ObtenerTodosAsync()
        {
            var lista = new List<Recurso>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RecursoId, CategoriaId, Titulo, Descripcion, Tipo, URL, FechaPublicacion, Estado FROM Recurso", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Recurso?> ObtenerPorIdAsync(int recursoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RecursoId, CategoriaId, Titulo, Descripcion, Tipo, URL, FechaPublicacion, Estado FROM Recurso WHERE RecursoId = @RecursoId", connection);
            command.Parameters.AddWithValue("@RecursoId", recursoId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<IEnumerable<Recurso>> ObtenerActivosAsync()
        {
            var lista = new List<Recurso>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RecursoId, CategoriaId, Titulo, Descripcion, Tipo, URL, FechaPublicacion, Estado FROM Recurso WHERE Estado = 'ACTIVO'", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Recurso>> ObtenerPorCategoriaAsync(int categoriaId)
        {
            var lista = new List<Recurso>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RecursoId, CategoriaId, Titulo, Descripcion, Tipo, URL, FechaPublicacion, Estado FROM Recurso WHERE CategoriaId = @CategoriaId", connection);
            command.Parameters.AddWithValue("@CategoriaId", categoriaId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Recurso>> ObtenerPorTipoAsync(string tipo)
        {
            var lista = new List<Recurso>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RecursoId, CategoriaId, Titulo, Descripcion, Tipo, URL, FechaPublicacion, Estado FROM Recurso WHERE Tipo = @Tipo", connection);
            command.Parameters.AddWithValue("@Tipo", tipo);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Recurso> CrearAsync(Recurso recurso)
        {
            if (recurso.CategoriaId < 1 || recurso.CategoriaId > 7)
                throw new InvalidOperationException("La categoria debe ser una de las 7 categorias oficiales (1-7).");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Recurso (CategoriaId, Titulo, Descripcion, Tipo, URL, FechaPublicacion, Estado) OUTPUT INSERTED.RecursoId VALUES (@CategoriaId, @Titulo, @Descripcion, @Tipo, @URL, @FechaPublicacion, @Estado)", connection);
            command.Parameters.AddWithValue("@CategoriaId", recurso.CategoriaId);
            command.Parameters.AddWithValue("@Titulo", recurso.Titulo);
            command.Parameters.AddWithValue("@Descripcion", recurso.Descripcion);
            command.Parameters.AddWithValue("@Tipo", recurso.Tipo);
            command.Parameters.AddWithValue("@URL", (object?)recurso.URL ?? DBNull.Value);
            command.Parameters.AddWithValue("@FechaPublicacion", recurso.FechaPublicacion);
            command.Parameters.AddWithValue("@Estado", recurso.Estado);
            recurso.RecursoId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return recurso;
        }

        public async Task<Recurso?> ActualizarAsync(Recurso recurso)
        {
            if (recurso.CategoriaId < 1 || recurso.CategoriaId > 7)
                throw new InvalidOperationException("La categoria debe ser una de las 7 categorias oficiales (1-7).");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Recurso SET CategoriaId = @CategoriaId, Titulo = @Titulo, Descripcion = @Descripcion, Tipo = @Tipo, URL = @URL, Estado = @Estado WHERE RecursoId = @RecursoId", connection);
            command.Parameters.AddWithValue("@RecursoId", recurso.RecursoId);
            command.Parameters.AddWithValue("@CategoriaId", recurso.CategoriaId);
            command.Parameters.AddWithValue("@Titulo", recurso.Titulo);
            command.Parameters.AddWithValue("@Descripcion", recurso.Descripcion);
            command.Parameters.AddWithValue("@Tipo", recurso.Tipo);
            command.Parameters.AddWithValue("@URL", (object?)recurso.URL ?? DBNull.Value);
            command.Parameters.AddWithValue("@Estado", recurso.Estado);
            return await command.ExecuteNonQueryAsync() > 0 ? recurso : null;
        }

        public async Task<bool> EliminarAsync(int recursoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Recurso WHERE RecursoId = @RecursoId", connection);
            command.Parameters.AddWithValue("@RecursoId", recursoId);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}