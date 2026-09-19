using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class AuditoriaService : IAuditoriaService
    {
        private readonly string _connectionString;

        public AuditoriaService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        public async Task RegistrarAsync(
            int? actorUsuarioId,
            string actorTipo,
            string accion,
            string entidadTipo,
            int? entidadId,
            string? estadoAnterior,
            string? estadoNuevo,
            string? motivo,
            string? metadataJson = null)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO SupportAuditLog (ActorUsuarioId, ActorTipo, Accion, EntidadTipo, EntidadId, EstadoAnterior, EstadoNuevo, Motivo, MetadataJson, Fecha) " +
                "VALUES (@ActorUsuarioId, @ActorTipo, @Accion, @EntidadTipo, @EntidadId, @EstadoAnterior, @EstadoNuevo, @Motivo, @MetadataJson, @Fecha)", connection);
            command.Parameters.AddWithValue("@ActorUsuarioId", (object?)actorUsuarioId ?? DBNull.Value);
            command.Parameters.AddWithValue("@ActorTipo", actorTipo);
            command.Parameters.AddWithValue("@Accion", accion);
            command.Parameters.AddWithValue("@EntidadTipo", entidadTipo);
            command.Parameters.AddWithValue("@EntidadId", (object?)entidadId ?? DBNull.Value);
            command.Parameters.AddWithValue("@EstadoAnterior", (object?)estadoAnterior ?? DBNull.Value);
            command.Parameters.AddWithValue("@EstadoNuevo", (object?)estadoNuevo ?? DBNull.Value);
            command.Parameters.AddWithValue("@Motivo", (object?)motivo ?? DBNull.Value);
            command.Parameters.AddWithValue("@MetadataJson", (object?)metadataJson ?? DBNull.Value);
            command.Parameters.AddWithValue("@Fecha", DateTime.Now);
            await command.ExecuteNonQueryAsync();
        }

        public async Task<IEnumerable<SupportAuditLog>> ObtenerAsync(string? entidadTipo = null, int limite = 300)
        {
            var lista = new List<SupportAuditLog>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT TOP (@Limite) a.AuditLogId, a.ActorUsuarioId, a.ActorTipo, a.Accion, a.EntidadTipo, a.EntidadId, " +
                "a.EstadoAnterior, a.EstadoNuevo, a.Motivo, a.MetadataJson, a.Fecha, u.NombreUsuario AS ActorNombre " +
                "FROM SupportAuditLog a LEFT JOIN Usuario u ON u.UsuarioId = a.ActorUsuarioId " +
                "WHERE (@EntidadTipo IS NULL OR a.EntidadTipo = @EntidadTipo) ORDER BY a.Fecha DESC", connection);
            command.Parameters.AddWithValue("@Limite", Math.Clamp(limite, 1, 1000));
            command.Parameters.AddWithValue("@EntidadTipo", (object?)entidadTipo ?? DBNull.Value);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                lista.Add(new SupportAuditLog
                {
                    AuditLogId = reader.GetInt64(reader.GetOrdinal("AuditLogId")),
                    ActorUsuarioId = DatabaseHelper.ReadNullableInt(reader, "ActorUsuarioId"),
                    ActorTipo = DatabaseHelper.ReadString(reader, "ActorTipo"),
                    Accion = DatabaseHelper.ReadString(reader, "Accion"),
                    EntidadTipo = DatabaseHelper.ReadString(reader, "EntidadTipo"),
                    EntidadId = DatabaseHelper.ReadNullableInt(reader, "EntidadId"),
                    EstadoAnterior = reader.IsDBNull(reader.GetOrdinal("EstadoAnterior")) ? null : DatabaseHelper.ReadString(reader, "EstadoAnterior"),
                    EstadoNuevo = reader.IsDBNull(reader.GetOrdinal("EstadoNuevo")) ? null : DatabaseHelper.ReadString(reader, "EstadoNuevo"),
                    Motivo = reader.IsDBNull(reader.GetOrdinal("Motivo")) ? null : DatabaseHelper.ReadString(reader, "Motivo"),
                    MetadataJson = reader.IsDBNull(reader.GetOrdinal("MetadataJson")) ? null : DatabaseHelper.ReadString(reader, "MetadataJson"),
                    Fecha = DatabaseHelper.ReadDateTime(reader, "Fecha"),
                    ActorNombre = reader.IsDBNull(reader.GetOrdinal("ActorNombre")) ? null : DatabaseHelper.ReadString(reader, "ActorNombre")
                });
            }
            return lista;
        }
    }
}
