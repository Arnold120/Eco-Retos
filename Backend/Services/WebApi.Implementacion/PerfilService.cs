using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class PerfilService : IPerfilService
    {
        private readonly string _connectionString;

        public PerfilService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private Perfil MapearPerfil(SqlDataReader reader)
        {
            return new Perfil
            {
                PerfilId = DatabaseHelper.ReadInt(reader, "PerfilId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                Nombre = DatabaseHelper.ReadString(reader, "Nombre"),
                Apellido = DatabaseHelper.ReadString(reader, "Apellido"),
                Carnet = DatabaseHelper.ReadString(reader, "Carnet"),
                CentroEducativo = DatabaseHelper.ReadString(reader, "CentroEducativo"),
                Grado = DatabaseHelper.ReadString(reader, "Grado"),
                FotoPerfil = reader.IsDBNull(reader.GetOrdinal("FotoPerfil")) ? null : DatabaseHelper.ReadString(reader, "FotoPerfil")
            };
        }

        public async Task<Perfil?> ObtenerPerfilPorUsuarioAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT PerfilId, UsuarioId, Nombre, Apellido, Carnet, CentroEducativo, Grado, FotoPerfil FROM Perfil WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapearPerfil(reader) : null;
        }

        public async Task<Perfil?> ObtenerPorIdAsync(int perfilId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT PerfilId, UsuarioId, Nombre, Apellido, Carnet, CentroEducativo, Grado, FotoPerfil FROM Perfil WHERE PerfilId = @PerfilId", connection);
            command.Parameters.AddWithValue("@PerfilId", perfilId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapearPerfil(reader) : null;
        }

        public async Task<Perfil> CrearAsync(Perfil perfil)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Perfil (UsuarioId, Nombre, Apellido, Carnet, CentroEducativo, Grado, FotoPerfil) OUTPUT INSERTED.PerfilId VALUES (@UsuarioId, @Nombre, @Apellido, @Carnet, @CentroEducativo, @Grado, @FotoPerfil)", connection);
            command.Parameters.AddWithValue("@UsuarioId", perfil.UsuarioId);
            command.Parameters.AddWithValue("@Nombre", perfil.Nombre);
            command.Parameters.AddWithValue("@Apellido", perfil.Apellido);
            command.Parameters.AddWithValue("@Carnet", perfil.Carnet);
            command.Parameters.AddWithValue("@CentroEducativo", perfil.CentroEducativo);
            command.Parameters.AddWithValue("@Grado", perfil.Grado);
            command.Parameters.AddWithValue("@FotoPerfil", (object?)perfil.FotoPerfil ?? DBNull.Value);
            perfil.PerfilId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return perfil;
        }

        public async Task<Perfil?> ActualizarAsync(Perfil perfil)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Perfil SET Nombre = @Nombre, Apellido = @Apellido, Carnet = @Carnet, CentroEducativo = @CentroEducativo, Grado = @Grado, FotoPerfil = @FotoPerfil WHERE PerfilId = @PerfilId", connection);
            command.Parameters.AddWithValue("@PerfilId", perfil.PerfilId);
            command.Parameters.AddWithValue("@Nombre", perfil.Nombre);
            command.Parameters.AddWithValue("@Apellido", perfil.Apellido);
            command.Parameters.AddWithValue("@Carnet", perfil.Carnet);
            command.Parameters.AddWithValue("@CentroEducativo", perfil.CentroEducativo);
            command.Parameters.AddWithValue("@Grado", perfil.Grado);
            command.Parameters.AddWithValue("@FotoPerfil", (object?)perfil.FotoPerfil ?? DBNull.Value);
            var rows = await command.ExecuteNonQueryAsync();
            return rows > 0 ? perfil : null;
        }

        public async Task<bool> EliminarAsync(int perfilId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Perfil WHERE PerfilId = @PerfilId", connection);
            command.Parameters.AddWithValue("@PerfilId", perfilId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<IEnumerable<Perfil>> ObtenerPorCentroEducativoAsync(string centroEducativo)
        {
            var lista = new List<Perfil>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT PerfilId, UsuarioId, Nombre, Apellido, Carnet, CentroEducativo, Grado, FotoPerfil FROM Perfil WHERE CentroEducativo = @CentroEducativo", connection);
            command.Parameters.AddWithValue("@CentroEducativo", centroEducativo);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                lista.Add(MapearPerfil(reader));
            return lista;
        }

        public async Task<Dictionary<int, Perfil>> ObtenerPorUsuariosAsync(IEnumerable<int> usuarioIds)
        {
            var resultado = new Dictionary<int, Perfil>();
            var ids = usuarioIds.Distinct().Take(500).ToList();
            if (ids.Count == 0) return resultado;

            var parametros = string.Join(",", ids.Select((_, i) => $"@Id{i}"));
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT PerfilId, UsuarioId, Nombre, Apellido, Carnet, CentroEducativo, Grado, FotoPerfil FROM Perfil WHERE UsuarioId IN ({parametros})", connection);
            for (var i = 0; i < ids.Count; i++)
                command.Parameters.AddWithValue($"@Id{i}", ids[i]);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var perfil = MapearPerfil(reader);
                resultado[perfil.UsuarioId] = perfil;
            }
            return resultado;
        }
    }
}
