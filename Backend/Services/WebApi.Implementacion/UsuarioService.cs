using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class UsuarioService : IUsuarioService
    {
        private readonly string _connectionString;

        public UsuarioService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private Usuario MapearUsuario(SqlDataReader reader)
        {
            return new Usuario
            {
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                NombreUsuario = DatabaseHelper.ReadString(reader, "NombreUsuario"),
                Correo = DatabaseHelper.ReadString(reader, "Correo"),
                Contrasena = DatabaseHelper.ReadString(reader, "Contrasena"),
                Salt = DatabaseHelper.ReadByteArray(reader, "Salt"),
                Activo = DatabaseHelper.ReadBool(reader, "Activo"),
                FechaRegistro = DatabaseHelper.ReadDateTime(reader, "FechaRegistro")
            };
        }

        public async Task<IEnumerable<Usuario>> ObtenerTodosAsync()
        {
            var lista = new List<Usuario>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioId, NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro FROM Usuario", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                lista.Add(MapearUsuario(reader));
            return lista;
        }

        public async Task<IEnumerable<Usuario>> ObtenerActivosAsync()
        {
            var lista = new List<Usuario>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioId, NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro FROM Usuario WHERE Activo = 1", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                lista.Add(MapearUsuario(reader));
            return lista;
        }

        public async Task<IEnumerable<Usuario>> ObtenerInactivosAsync()
        {
            var lista = new List<Usuario>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioId, NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro FROM Usuario WHERE Activo = 0", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                lista.Add(MapearUsuario(reader));
            return lista;
        }

        public async Task<Usuario?> ObtenerPorIdAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioId, NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro FROM Usuario WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapearUsuario(reader) : null;
        }

        public async Task<Usuario?> ObtenerPorCorreoAsync(string correo)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioId, NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro FROM Usuario WHERE Correo = @Correo", connection);
            command.Parameters.AddWithValue("@Correo", correo);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapearUsuario(reader) : null;
        }

        public async Task<Usuario?> ObtenerPorNombreUsuarioAsync(string nombreUsuario)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT UsuarioId, NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro FROM Usuario WHERE NombreUsuario = @NombreUsuario", connection);
            command.Parameters.AddWithValue("@NombreUsuario", nombreUsuario);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapearUsuario(reader) : null;
        }

        public async Task<Usuario> CrearAsync(Usuario usuario)
        {
            if (string.IsNullOrWhiteSpace(usuario.Contrasena))
                throw new ArgumentException("La contrasena es obligatoria.", nameof(usuario));

            if (usuario.Salt is null || usuario.Salt.Length == 0)
            {
                usuario.Salt = PasswordHasher.GenerateSalt();
                usuario.Contrasena = PasswordHasher.HashPassword(usuario.Contrasena, usuario.Salt);
            }

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Usuario (NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro) OUTPUT INSERTED.UsuarioId VALUES (@NombreUsuario, @Correo, @Contrasena, @Salt, @Activo, @FechaRegistro)", connection);
            command.Parameters.AddWithValue("@NombreUsuario", usuario.NombreUsuario);
            command.Parameters.AddWithValue("@Correo", usuario.Correo);
            command.Parameters.AddWithValue("@Contrasena", usuario.Contrasena);
            command.Parameters.AddWithValue("@Salt", usuario.Salt);
            command.Parameters.AddWithValue("@Activo", usuario.Activo);
            command.Parameters.AddWithValue("@FechaRegistro", usuario.FechaRegistro);
            usuario.UsuarioId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return usuario;
        }

        public async Task<Usuario?> ActualizarAsync(Usuario usuario)
        {
            if (!string.IsNullOrWhiteSpace(usuario.Contrasena) && (usuario.Salt is null || usuario.Salt.Length == 0))
            {
                usuario.Salt = PasswordHasher.GenerateSalt();
                usuario.Contrasena = PasswordHasher.HashPassword(usuario.Contrasena, usuario.Salt);
            }

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Usuario SET NombreUsuario = @NombreUsuario, Correo = @Correo, Contrasena = @Contrasena, Salt = @Salt, Activo = @Activo WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuario.UsuarioId);
            command.Parameters.AddWithValue("@NombreUsuario", usuario.NombreUsuario);
            command.Parameters.AddWithValue("@Correo", usuario.Correo);
            command.Parameters.AddWithValue("@Contrasena", usuario.Contrasena);
            command.Parameters.AddWithValue("@Salt", (object?)usuario.Salt ?? DBNull.Value);
            command.Parameters.AddWithValue("@Activo", usuario.Activo);
            var rows = await command.ExecuteNonQueryAsync();
            return rows > 0 ? usuario : null;
        }

        public async Task<bool> EliminarAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Usuario WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<bool> ActivarAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE Usuario SET Activo = 1 WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<bool> DesactivarAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE Usuario SET Activo = 0 WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<Usuario?> AutenticarAsync(string correo, string contrasena)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT UsuarioId, NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro FROM Usuario WHERE Correo = @Correo", connection);
            command.Parameters.AddWithValue("@Correo", correo);
            using var reader = await command.ExecuteReaderAsync();

            if (!await reader.ReadAsync())
                return null;

            var usuario = MapearUsuario(reader);
            if (!usuario.Activo)
                return null;

            if (usuario.Salt is null || !PasswordHasher.VerifyPassword(contrasena, usuario.Salt, usuario.Contrasena))
                return null;

            return usuario;
        }

        public async Task<bool> CambiarContrasenaAsync(int usuarioId, string contrasenaActual, string nuevaContrasena)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using var selectCmd = new SqlCommand(
                "SELECT Contrasena, Salt FROM Usuario WHERE UsuarioId = @UsuarioId", connection);
            selectCmd.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using (var reader = await selectCmd.ExecuteReaderAsync())
            {
                if (!await reader.ReadAsync())
                    return false;

                var contrasenaAlmacenada = DatabaseHelper.ReadString(reader, "Contrasena");
                var salt = DatabaseHelper.ReadByteArray(reader, "Salt");
                if (salt is null || !PasswordHasher.VerifyPassword(contrasenaActual, salt, contrasenaAlmacenada))
                    return false;
            }

            var nuevoSalt = PasswordHasher.GenerateSalt();
            var nuevoHash = PasswordHasher.HashPassword(nuevaContrasena, nuevoSalt);

            using var updateCmd = new SqlCommand(
                "UPDATE Usuario SET Contrasena = @Contrasena, Salt = @Salt WHERE UsuarioId = @UsuarioId", connection);
            updateCmd.Parameters.AddWithValue("@UsuarioId", usuarioId);
            updateCmd.Parameters.AddWithValue("@Contrasena", nuevoHash);
            updateCmd.Parameters.AddWithValue("@Salt", nuevoSalt);
            return await updateCmd.ExecuteNonQueryAsync() > 0;
        }

        public async Task<bool> ExisteCorreoAsync(string correo)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Usuario WHERE Correo = @Correo", connection);
            command.Parameters.AddWithValue("@Correo", correo);
            return Convert.ToInt32(await command.ExecuteScalarAsync()) > 0;
        }

        public async Task<bool> ExisteNombreUsuarioAsync(string nombreUsuario)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Usuario WHERE NombreUsuario = @NombreUsuario", connection);
            command.Parameters.AddWithValue("@NombreUsuario", nombreUsuario);
            return Convert.ToInt32(await command.ExecuteScalarAsync()) > 0;
        }

        public async Task<Dictionary<int, Usuario>> ObtenerPorIdsAsync(IEnumerable<int> usuarioIds)
        {
            var resultado = new Dictionary<int, Usuario>();
            var ids = usuarioIds.Distinct().Take(500).ToList();
            if (ids.Count == 0) return resultado;

            var parametros = string.Join(",", ids.Select((_, i) => $"@Id{i}"));
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT UsuarioId, NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro FROM Usuario WHERE UsuarioId IN ({parametros})", connection);
            for (var i = 0; i < ids.Count; i++)
                command.Parameters.AddWithValue($"@Id{i}", ids[i]);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var usuario = MapearUsuario(reader);
                resultado[usuario.UsuarioId] = usuario;
            }
            return resultado;
        }

        public async Task<IEnumerable<Usuario>> BuscarAsync(string termino, int limite)
        {
            limite = Math.Clamp(limite, 1, 50);
            var lista = new List<Usuario>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT TOP (@Limite) UsuarioId, NombreUsuario, Correo, Contrasena, Salt, Activo, FechaRegistro " +
                "FROM Usuario WHERE Activo = 1 AND NombreUsuario LIKE @Termino ORDER BY NombreUsuario", connection);
            command.Parameters.AddWithValue("@Termino", $"%{termino.Trim()}%");
            command.Parameters.AddWithValue("@Limite", limite);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(MapearUsuario(reader));
            return lista;
        }

        public async Task<int> ObtenerTotalActivosAsync()
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Usuario WHERE Activo = 1", connection);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        public async Task<int> ObtenerTotalAsync()
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Usuario", connection);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }
    }
}
