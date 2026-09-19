using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;

namespace WebApi.Implementacion
{
    public class GuardadoService : IGuardadoService
    {
        private readonly string _connectionString;

        public GuardadoService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<bool> AlternarAsync(int usuarioId, int publicacionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using (var existe = new SqlCommand("SELECT COUNT(1) FROM Guardado WHERE UsuarioId = @UsuarioId AND PublicacionId = @PublicacionId", connection))
            {
                existe.Parameters.AddWithValue("@UsuarioId", usuarioId);
                existe.Parameters.AddWithValue("@PublicacionId", publicacionId);
                if (Convert.ToInt32(await existe.ExecuteScalarAsync()) > 0)
                {
                    using var delete = new SqlCommand("DELETE FROM Guardado WHERE UsuarioId = @UsuarioId AND PublicacionId = @PublicacionId", connection);
                    delete.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    delete.Parameters.AddWithValue("@PublicacionId", publicacionId);
                    await delete.ExecuteNonQueryAsync();
                    return false;
                }
            }

            using var insert = new SqlCommand("INSERT INTO Guardado (UsuarioId, PublicacionId, Fecha) VALUES (@UsuarioId, @PublicacionId, @Fecha)", connection);
            insert.Parameters.AddWithValue("@UsuarioId", usuarioId);
            insert.Parameters.AddWithValue("@PublicacionId", publicacionId);
            insert.Parameters.AddWithValue("@Fecha", DateTime.Now);
            await insert.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<IEnumerable<int>> ObtenerIdsGuardadosAsync(int usuarioId)
        {
            var ids = new List<int>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT PublicacionId FROM Guardado WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) ids.Add(DatabaseHelper.ReadInt(reader, "PublicacionId"));
            return ids;
        }
    }
}
