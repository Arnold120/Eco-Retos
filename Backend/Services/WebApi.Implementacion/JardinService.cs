using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class JardinService : IJardinService
    {
        private readonly string _connectionString;

        public JardinService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private Jardin Mapear(SqlDataReader reader)
        {
            return new Jardin
            {
                JardinId = DatabaseHelper.ReadInt(reader, "JardinId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                NivelJardin = DatabaseHelper.ReadInt(reader, "NivelJardin"),
                Plantas = DatabaseHelper.ReadInt(reader, "Plantas"),
                Arboles = DatabaseHelper.ReadInt(reader, "Arboles"),
                Flores = DatabaseHelper.ReadInt(reader, "Flores"),
                PuntosJardin = DatabaseHelper.ReadInt(reader, "PuntosJardin")
            };
        }

        public async Task<Jardin?> ObtenerJardinDeUsuarioAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT JardinId, UsuarioId, NivelJardin, Plantas, Arboles, Flores, PuntosJardin FROM Jardin WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Jardin> CrearJardinAsync(Jardin jardin)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Jardin (UsuarioId, NivelJardin, Plantas, Arboles, Flores, PuntosJardin) OUTPUT INSERTED.JardinId VALUES (@UsuarioId, @NivelJardin, @Plantas, @Arboles, @Flores, @PuntosJardin)", connection);
            command.Parameters.AddWithValue("@UsuarioId", jardin.UsuarioId);
            command.Parameters.AddWithValue("@NivelJardin", jardin.NivelJardin);
            command.Parameters.AddWithValue("@Plantas", jardin.Plantas);
            command.Parameters.AddWithValue("@Arboles", jardin.Arboles);
            command.Parameters.AddWithValue("@Flores", jardin.Flores);
            command.Parameters.AddWithValue("@PuntosJardin", jardin.PuntosJardin);
            jardin.JardinId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return jardin;
        }

        public async Task<bool> ActualizarJardinAsync(Jardin jardin)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Jardin SET NivelJardin = @NivelJardin, Plantas = @Plantas, Arboles = @Arboles, Flores = @Flores, PuntosJardin = @PuntosJardin WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", jardin.UsuarioId);
            command.Parameters.AddWithValue("@NivelJardin", jardin.NivelJardin);
            command.Parameters.AddWithValue("@Plantas", jardin.Plantas);
            command.Parameters.AddWithValue("@Arboles", jardin.Arboles);
            command.Parameters.AddWithValue("@Flores", jardin.Flores);
            command.Parameters.AddWithValue("@PuntosJardin", jardin.PuntosJardin);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<IEnumerable<Jardin>> ObtenerRankingJardinesAsync(int cantidad)
        {
            var lista = new List<Jardin>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT TOP ({cantidad}) JardinId, UsuarioId, NivelJardin, Plantas, Arboles, Flores, PuntosJardin FROM Jardin ORDER BY PuntosJardin DESC", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<bool> AgregarPuntosJardinAsync(int usuarioId, int puntos)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE Jardin SET PuntosJardin = PuntosJardin + @Puntos WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@Puntos", puntos);
            return await command.ExecuteNonQueryAsync() > 0;
        }
    }
}
