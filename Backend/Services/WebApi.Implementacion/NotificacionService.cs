using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class NotificacionService : INotificacionService
    {
        private readonly string _connectionString;
        private readonly IFirebaseNotificationService _firebaseNotificationService;
        private readonly ILogger<NotificacionService> _logger;

        private const string Columnas =
            "NotificacionId, UsuarioId, Titulo, Mensaje, Tipo, Leida, Fecha, ReferenciaTipo, ReferenciaId, ActorUsuarioId";

        public NotificacionService(
            IConfiguration configuration,
            IFirebaseNotificationService firebaseNotificationService,
            ILogger<NotificacionService> logger)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
            _firebaseNotificationService = firebaseNotificationService;
            _logger = logger;
        }

        private static Notificacion Mapear(SqlDataReader reader)
        {
            return new Notificacion
            {
                NotificacionId = DatabaseHelper.ReadInt(reader, "NotificacionId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                Titulo = DatabaseHelper.ReadString(reader, "Titulo"),
                Mensaje = DatabaseHelper.ReadString(reader, "Mensaje"),
                Tipo = DatabaseHelper.ReadString(reader, "Tipo"),
                Leida = DatabaseHelper.ReadBool(reader, "Leida"),
                Fecha = DatabaseHelper.ReadDateTime(reader, "Fecha"),
                ReferenciaTipo = reader.IsDBNull(reader.GetOrdinal("ReferenciaTipo")) ? null : DatabaseHelper.ReadString(reader, "ReferenciaTipo"),
                ReferenciaId = DatabaseHelper.ReadNullableInt(reader, "ReferenciaId"),
                ActorUsuarioId = DatabaseHelper.ReadNullableInt(reader, "ActorUsuarioId")
            };
        }

        public async Task<IEnumerable<Notificacion>> ObtenerNotificacionesDeUsuarioAsync(int usuarioId)
        {
            var lista = new List<Notificacion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Notificacion WHERE UsuarioId = @UsuarioId ORDER BY Fecha DESC", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Notificacion>> ObtenerNoLeidasAsync(int usuarioId)
        {
            var lista = new List<Notificacion>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Notificacion WHERE UsuarioId = @UsuarioId AND Leida = 0 ORDER BY Fecha DESC", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Notificacion?> ObtenerPorIdAsync(int notificacionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Notificacion WHERE NotificacionId = @NotificacionId", connection);
            command.Parameters.AddWithValue("@NotificacionId", notificacionId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Notificacion> CrearNotificacionAsync(Notificacion notificacion)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO Notificacion (UsuarioId, Titulo, Mensaje, Tipo, Leida, Fecha, ReferenciaTipo, ReferenciaId, ActorUsuarioId) " +
                "OUTPUT INSERTED.NotificacionId VALUES (@UsuarioId, @Titulo, @Mensaje, @Tipo, @Leida, @Fecha, @ReferenciaTipo, @ReferenciaId, @ActorUsuarioId)", connection);
            command.Parameters.AddWithValue("@UsuarioId", notificacion.UsuarioId);
            command.Parameters.AddWithValue("@Titulo", notificacion.Titulo);
            command.Parameters.AddWithValue("@Mensaje", notificacion.Mensaje);
            command.Parameters.AddWithValue("@Tipo", notificacion.Tipo);
            command.Parameters.AddWithValue("@Leida", notificacion.Leida);
            command.Parameters.AddWithValue("@Fecha", notificacion.Fecha);
            command.Parameters.AddWithValue("@ReferenciaTipo", (object?)notificacion.ReferenciaTipo ?? DBNull.Value);
            command.Parameters.AddWithValue("@ReferenciaId", (object?)notificacion.ReferenciaId ?? DBNull.Value);
            command.Parameters.AddWithValue("@ActorUsuarioId", (object?)notificacion.ActorUsuarioId ?? DBNull.Value);
            notificacion.NotificacionId = Convert.ToInt32(await command.ExecuteScalarAsync());
            try
            {
                await _firebaseNotificationService.EnviarAsync(notificacion);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "No se pudo enviar la notificación push {NotificacionId}.",
                    notificacion.NotificacionId);
            }
            return notificacion;
        }

        public async Task CrearInteraccionAsync(
            int destinatarioId,
            int actorUsuarioId,
            string titulo,
            string mensaje,
            string tipo,
            string? referenciaTipo,
            int? referenciaId)
        {
            if (destinatarioId <= 0 || destinatarioId == actorUsuarioId) return;

            await CrearNotificacionAsync(new Notificacion
            {
                UsuarioId = destinatarioId,
                Titulo = titulo,
                Mensaje = mensaje,
                Tipo = tipo,
                Leida = false,
                Fecha = DateTime.Now,
                ReferenciaTipo = referenciaTipo,
                ReferenciaId = referenciaId,
                ActorUsuarioId = actorUsuarioId
            });
        }

        public async Task<bool> MarcarComoLeidaAsync(int notificacionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE Notificacion SET Leida = 1 WHERE NotificacionId = @NotificacionId", connection);
            command.Parameters.AddWithValue("@NotificacionId", notificacionId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<bool> MarcarTodasComoLeidasAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE Notificacion SET Leida = 1 WHERE UsuarioId = @UsuarioId AND Leida = 0", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            await command.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<int> ContarNoLeidasAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Notificacion WHERE UsuarioId = @UsuarioId AND Leida = 0", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        public async Task<bool> EliminarAsync(int notificacionId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Notificacion WHERE NotificacionId = @NotificacionId", connection);
            command.Parameters.AddWithValue("@NotificacionId", notificacionId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<bool> EliminarTodasAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Notificacion WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            await command.ExecuteNonQueryAsync();
            return true;
        }
    }
}
