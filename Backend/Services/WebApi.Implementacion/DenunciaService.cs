using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class DenunciaService : IDenunciaService
    {
        private readonly string _connectionString;

        public DenunciaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<Denuncia> CrearAsync(Denuncia denuncia)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Denuncia (UsuarioId, PublicacionId, ComentarioId, Motivo, Descripcion, Estado, Fecha) " +
                "OUTPUT INSERTED.DenunciaId VALUES (@UsuarioId, @PublicacionId, @ComentarioId, @Motivo, @Descripcion, 'PENDIENTE', @Fecha)", connection);
            command.Parameters.AddWithValue("@UsuarioId", denuncia.UsuarioId);
            command.Parameters.AddWithValue("@PublicacionId", (object?)denuncia.PublicacionId ?? DBNull.Value);
            command.Parameters.AddWithValue("@ComentarioId", (object?)denuncia.ComentarioId ?? DBNull.Value);
            command.Parameters.AddWithValue("@Motivo", denuncia.Motivo);
            command.Parameters.AddWithValue("@Descripcion", (object?)denuncia.Descripcion ?? DBNull.Value);
            command.Parameters.AddWithValue("@Fecha", DateTime.Now);
            denuncia.DenunciaId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return denuncia;
        }

        public async Task<bool> ExisteDenunciaAsync(int usuarioId, int? publicacionId, int? comentarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT COUNT(1) FROM Denuncia WHERE UsuarioId = @UsuarioId " +
                "AND ((@PublicacionId IS NULL AND PublicacionId IS NULL) OR PublicacionId = @PublicacionId) " +
                "AND ((@ComentarioId IS NULL AND ComentarioId IS NULL) OR ComentarioId = @ComentarioId)", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@PublicacionId", (object?)publicacionId ?? DBNull.Value);
            command.Parameters.AddWithValue("@ComentarioId", (object?)comentarioId ?? DBNull.Value);
            return Convert.ToInt32(await command.ExecuteScalarAsync()) > 0;
        }
    }
}
