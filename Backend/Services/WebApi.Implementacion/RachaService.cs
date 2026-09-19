using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class RachaService : IRachaService
    {
        private readonly string _connectionString;

        public RachaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private Racha Mapear(SqlDataReader reader)
        {
            return new Racha
            {
                RachaId = DatabaseHelper.ReadInt(reader, "RachaId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                FechaAcceso = DatabaseHelper.ReadDateTime(reader, "FechaAcceso"),
                NumeroRacha = DatabaseHelper.ReadInt(reader, "NumeroRacha")
            };
        }

        public async Task<IEnumerable<Racha>> ObtenerHistorialRachasAsync(int usuarioId)
        {
            var lista = new List<Racha>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT RachaId, UsuarioId, FechaAcceso, NumeroRacha FROM Racha WHERE UsuarioId = @UsuarioId ORDER BY FechaAcceso DESC", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<int> ObtenerRachaActualAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT ISNULL(MAX(NumeroRacha), 0) FROM Racha WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        public async Task<Racha> RegistrarAccesoAsync(int usuarioId, DateTime fechaAcceso)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            var fechaSolo = fechaAcceso.Date;
            using var checkCmd = new SqlCommand("SELECT NumeroRacha FROM Racha WHERE UsuarioId = @UsuarioId AND FechaAcceso = @FechaAcceso", connection);
            checkCmd.Parameters.AddWithValue("@UsuarioId", usuarioId);
            checkCmd.Parameters.AddWithValue("@FechaAcceso", fechaSolo);
            var existente = await checkCmd.ExecuteScalarAsync();
            if (existente != null) return new Racha { UsuarioId = usuarioId, FechaAcceso = fechaSolo, NumeroRacha = (int)existente };

            using var prevCmd = new SqlCommand("SELECT TOP 1 NumeroRacha, FechaAcceso FROM Racha WHERE UsuarioId = @UsuarioId ORDER BY FechaAcceso DESC", connection);
            prevCmd.Parameters.AddWithValue("@UsuarioId", usuarioId);
            int nuevaRacha = 1;
            using (var prevReader = await prevCmd.ExecuteReaderAsync())
            {
                if (await prevReader.ReadAsync())
                {
                    var ultimaFecha = DatabaseHelper.ReadDateTime(prevReader, "FechaAcceso");
                    var ultimoNumero = DatabaseHelper.ReadInt(prevReader, "NumeroRacha");
                    if ((fechaSolo - ultimaFecha.Date).Days == 1)
                        nuevaRacha = ultimoNumero + 1;
                }
            }

            using var command = new SqlCommand(
                "INSERT INTO Racha (UsuarioId, FechaAcceso, NumeroRacha) OUTPUT INSERTED.RachaId VALUES (@UsuarioId, @FechaAcceso, @NumeroRacha)", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@FechaAcceso", fechaSolo);
            command.Parameters.AddWithValue("@NumeroRacha", nuevaRacha);
            var rachaId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return new Racha { RachaId = rachaId, UsuarioId = usuarioId, FechaAcceso = fechaSolo, NumeroRacha = nuevaRacha };
        }

        public async Task<bool> ActualizarRachaAsync(Racha racha)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE Racha SET NumeroRacha = @NumeroRacha WHERE RachaId = @RachaId", connection);
            command.Parameters.AddWithValue("@RachaId", racha.RachaId);
            command.Parameters.AddWithValue("@NumeroRacha", racha.NumeroRacha);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<IEnumerable<Racha>> ObtenerTopRachasAsync(int cantidad)
        {
            var lista = new List<Racha>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT TOP ({cantidad}) r.RachaId, r.UsuarioId, r.FechaAcceso, r.NumeroRacha FROM Racha r INNER JOIN (SELECT UsuarioId, MAX(NumeroRacha) AS MaxRacha FROM Racha GROUP BY UsuarioId) m ON r.UsuarioId = m.UsuarioId AND r.NumeroRacha = m.MaxRacha ORDER BY r.NumeroRacha DESC", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }
    }
}
