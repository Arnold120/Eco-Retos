using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class MensajeService : IMensajeService
    {
        private readonly string _connectionString;
        private readonly INotificacionService _notificacionService;

        public MensajeService(IConfiguration configuration, INotificacionService notificacionService)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
            _notificacionService = notificacionService;
        }

        private static Mensaje MapearMensaje(SqlDataReader reader)
        {
            return new Mensaje
            {
                MensajeId = DatabaseHelper.ReadInt(reader, "MensajeId"),
                ConversacionId = DatabaseHelper.ReadInt(reader, "ConversacionId"),
                RemitenteId = DatabaseHelper.ReadInt(reader, "RemitenteId"),
                Contenido = DatabaseHelper.ReadString(reader, "Contenido"),
                Fecha = DatabaseHelper.ReadDateTime(reader, "Fecha"),
                Leido = DatabaseHelper.ReadBool(reader, "Leido"),
                Tipo = reader.IsDBNull(reader.GetOrdinal("Tipo"))
                    ? "TEXTO"
                    : DatabaseHelper.ReadString(reader, "Tipo"),
                ArchivoUrl = reader.IsDBNull(reader.GetOrdinal("ArchivoUrl"))
                    ? null
                    : DatabaseHelper.ReadString(reader, "ArchivoUrl"),
                PublicacionId = DatabaseHelper.ReadNullableInt(reader, "PublicacionId"),
                RespuestaAId = DatabaseHelper.ReadNullableInt(reader, "RespuestaAId"),
                Editado = !reader.IsDBNull(reader.GetOrdinal("Editado")) && DatabaseHelper.ReadBool(reader, "Editado"),
                EliminadoParaTodos = !reader.IsDBNull(reader.GetOrdinal("EliminadoParaTodos")) && DatabaseHelper.ReadBool(reader, "EliminadoParaTodos")
            };
        }

        public async Task<IEnumerable<ConversacionResumen>> ObtenerConversacionesAsync(int usuarioId)
        {
            var lista = new List<ConversacionResumen>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            const string sql = @"
SELECT c.ConversacionId, c.FechaCreacion, c.FechaUltimoMensaje,
       u.UsuarioId, u.NombreUsuario, u.Correo, u.Activo, u.FechaRegistro,
       (SELECT TOP 1 m.Contenido FROM Mensaje m WHERE m.ConversacionId = c.ConversacionId
         AND m.EliminadoParaTodos = 0
         AND NOT (m.RemitenteId = @UsuarioId AND m.EliminadoParaRemitente = 1)
         AND NOT (m.RemitenteId <> @UsuarioId AND m.EliminadoParaDestinatario = 1)
         ORDER BY m.Fecha DESC, m.MensajeId DESC) AS UltimoMensaje,
       (SELECT COUNT(1) FROM Mensaje m2 WHERE m2.ConversacionId = c.ConversacionId
         AND m2.RemitenteId <> @UsuarioId AND m2.Leido = 0
         AND m2.EliminadoParaTodos = 0 AND m2.EliminadoParaDestinatario = 0) AS NoLeidos
FROM Conversacion c
JOIN ConversacionParticipante cp  ON cp.ConversacionId = c.ConversacionId AND cp.UsuarioId = @UsuarioId
JOIN ConversacionParticipante cp2 ON cp2.ConversacionId = c.ConversacionId AND cp2.UsuarioId <> @UsuarioId
JOIN Usuario u ON u.UsuarioId = cp2.UsuarioId
ORDER BY ISNULL(c.FechaUltimoMensaje, c.FechaCreacion) DESC";

            using var command = new SqlCommand(sql, connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                lista.Add(new ConversacionResumen
                {
                    Conversacion = new Conversacion
                    {
                        ConversacionId = DatabaseHelper.ReadInt(reader, "ConversacionId"),
                        FechaCreacion = DatabaseHelper.ReadDateTime(reader, "FechaCreacion"),
                        FechaUltimoMensaje = DatabaseHelper.ReadNullableDateTime(reader, "FechaUltimoMensaje")
                    },
                    OtroUsuario = new Usuario
                    {
                        UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                        NombreUsuario = DatabaseHelper.ReadString(reader, "NombreUsuario"),
                        Correo = DatabaseHelper.ReadString(reader, "Correo"),
                        Activo = DatabaseHelper.ReadBool(reader, "Activo"),
                        FechaRegistro = DatabaseHelper.ReadDateTime(reader, "FechaRegistro")
                    },
                    UltimoMensaje = reader.IsDBNull(reader.GetOrdinal("UltimoMensaje")) ? null : DatabaseHelper.ReadString(reader, "UltimoMensaje"),
                    FechaUltimoMensaje = DatabaseHelper.ReadNullableDateTime(reader, "FechaUltimoMensaje"),
                    NoLeidos = DatabaseHelper.ReadInt(reader, "NoLeidos")
                });
            }
            return lista;
        }

        public async Task<int> ObtenerOCrearConversacionAsync(int usuarioA, int usuarioB)
        {
            if (usuarioA == usuarioB || usuarioA <= 0 || usuarioB <= 0)
                throw new ArgumentException("Participantes invalidos.");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using (var buscar = new SqlCommand(
                "SELECT TOP 1 c.ConversacionId FROM Conversacion c " +
                "JOIN ConversacionParticipante p1 ON p1.ConversacionId = c.ConversacionId AND p1.UsuarioId = @A " +
                "JOIN ConversacionParticipante p2 ON p2.ConversacionId = c.ConversacionId AND p2.UsuarioId = @B " +
                "ORDER BY c.ConversacionId ASC", connection))
            {
                buscar.Parameters.AddWithValue("@A", usuarioA);
                buscar.Parameters.AddWithValue("@B", usuarioB);
                var existente = await buscar.ExecuteScalarAsync();
                if (existente is not null and not DBNull)
                    return Convert.ToInt32(existente);
            }

            using var transaction = connection.BeginTransaction();
            try
            {
                int conversacionId;
                using (var crear = new SqlCommand("INSERT INTO Conversacion (FechaCreacion) OUTPUT INSERTED.ConversacionId VALUES (@Fecha)", connection, transaction))
                {
                    crear.Parameters.AddWithValue("@Fecha", DateTime.Now);
                    conversacionId = Convert.ToInt32(await crear.ExecuteScalarAsync());
                }

                foreach (var usuarioId in new[] { usuarioA, usuarioB })
                {
                    using var insertar = new SqlCommand("INSERT INTO ConversacionParticipante (ConversacionId, UsuarioId) VALUES (@ConversacionId, @UsuarioId)", connection, transaction);
                    insertar.Parameters.AddWithValue("@ConversacionId", conversacionId);
                    insertar.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    await insertar.ExecuteNonQueryAsync();
                }

                transaction.Commit();
                return conversacionId;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<bool> EsParticipanteAsync(int conversacionId, int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM ConversacionParticipante WHERE ConversacionId = @ConversacionId AND UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@ConversacionId", conversacionId);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync()) > 0;
        }

        public async Task<IEnumerable<Mensaje>> ObtenerMensajesAsync(int conversacionId, int usuarioId, int? antesDeMensajeId, int limite)
        {
            limite = Math.Clamp(limite, 1, 100);
            var lista = new List<Mensaje>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT * FROM (" +
                "  SELECT TOP (@Limite) MensajeId, ConversacionId, RemitenteId, Contenido, Fecha, Leido, " +
                "         Tipo, ArchivoUrl, PublicacionId, RespuestaAId, Editado, EliminadoParaTodos " +
                "  FROM Mensaje WHERE ConversacionId = @ConversacionId " +
                "    AND EliminadoParaTodos = 0 " +
                "    AND NOT (RemitenteId = @UsuarioId AND EliminadoParaRemitente = 1) " +
                "    AND NOT (RemitenteId <> @UsuarioId AND EliminadoParaDestinatario = 1) " +
                "    AND (@AntesDe IS NULL OR MensajeId < @AntesDe) " +
                "  ORDER BY Fecha DESC, MensajeId DESC" +
                ") t ORDER BY t.Fecha ASC, t.MensajeId ASC", connection);
            command.Parameters.AddWithValue("@ConversacionId", conversacionId);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@Limite", limite);
            command.Parameters.AddWithValue("@AntesDe", (object?)antesDeMensajeId ?? DBNull.Value);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(MapearMensaje(reader));
            return lista;
        }

        public async Task<Mensaje> EnviarMensajeAsync(
            int conversacionId,
            int remitenteId,
            string contenido,
            string? tipo = null,
            string? archivoUrl = null,
            int? publicacionId = null,
            int? respuestaAId = null)
        {
            contenido = (contenido ?? string.Empty).Trim();
            archivoUrl = string.IsNullOrWhiteSpace(archivoUrl) ? null : archivoUrl.Trim();
            if (contenido.Length == 0 && archivoUrl is null && publicacionId is null)
                throw new ArgumentException("El mensaje esta vacio.");
            if (contenido.Length > 2000) contenido = contenido[..2000];

            var tipoNormalizado = (tipo ?? "TEXTO").Trim().ToUpperInvariant();
            if (tipoNormalizado is not ("TEXTO" or "IMAGEN" or "VIDEO" or "PUBLICACION"))
                tipoNormalizado = "TEXTO";

            var mensaje = new Mensaje
            {
                ConversacionId = conversacionId,
                RemitenteId = remitenteId,
                Contenido = contenido,
                Fecha = DateTime.Now,
                Leido = false,
                Tipo = tipoNormalizado,
                ArchivoUrl = archivoUrl,
                PublicacionId = publicacionId,
                RespuestaAId = respuestaAId
            };

            var destinatarioId = await ObtenerOtroParticipanteAsync(conversacionId, remitenteId);
            var noLeidosPrevios = destinatarioId is null
                ? 0
                : await ContarNoLeidosDeRemitenteAsync(conversacionId, remitenteId);

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var transaction = connection.BeginTransaction();
                try
                {
                    using (var insert = new SqlCommand(
                        "INSERT INTO Mensaje (ConversacionId, RemitenteId, Contenido, Fecha, Leido, Tipo, ArchivoUrl, PublicacionId, RespuestaAId) " +
                        "OUTPUT INSERTED.MensajeId VALUES (@ConversacionId, @RemitenteId, @Contenido, @Fecha, 0, @Tipo, @ArchivoUrl, @PublicacionId, @RespuestaAId)", connection, transaction))
                    {
                        insert.Parameters.AddWithValue("@ConversacionId", conversacionId);
                        insert.Parameters.AddWithValue("@RemitenteId", remitenteId);
                        insert.Parameters.AddWithValue("@Contenido", contenido);
                        insert.Parameters.AddWithValue("@Fecha", mensaje.Fecha);
                        insert.Parameters.AddWithValue("@Tipo", tipoNormalizado);
                        insert.Parameters.AddWithValue("@ArchivoUrl", (object?)archivoUrl ?? DBNull.Value);
                        insert.Parameters.AddWithValue("@PublicacionId", (object?)publicacionId ?? DBNull.Value);
                        insert.Parameters.AddWithValue("@RespuestaAId", (object?)respuestaAId ?? DBNull.Value);
                        mensaje.MensajeId = Convert.ToInt32(await insert.ExecuteScalarAsync());
                    }

                    using (var actualizar = new SqlCommand("UPDATE Conversacion SET FechaUltimoMensaje = @Fecha WHERE ConversacionId = @ConversacionId", connection, transaction))
                    {
                        actualizar.Parameters.AddWithValue("@Fecha", mensaje.Fecha);
                        actualizar.Parameters.AddWithValue("@ConversacionId", conversacionId);
                        await actualizar.ExecuteNonQueryAsync();
                    }

                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }

            if (destinatarioId is int destinatario && noLeidosPrevios == 0)
            {
                try
                {
                    var actor = await ObtenerNombreUsuarioAsync(remitenteId);
                    var resumen = contenido.Length > 0
                        ? (contenido.Length > 90 ? contenido[..90] + "..." : contenido)
                        : tipoNormalizado switch
                        {
                            "IMAGEN" => "Te envió una foto",
                            "VIDEO" => "Te envió un video",
                            "PUBLICACION" => "Te compartió una publicación",
                            _ => "Te envió un mensaje"
                        };
                    await _notificacionService.CrearInteraccionAsync(
                        destinatario, remitenteId,
                        $"{actor} te envió un mensaje",
                        resumen,
                        "MENSAJE", "CONVERSACION", conversacionId);
                }
                catch
                {

                }
            }

            return mensaje;
        }

        public async Task<Mensaje?> EditarMensajeAsync(int conversacionId, int mensajeId, int usuarioId, string contenido)
        {
            contenido = (contenido ?? string.Empty).Trim();
            if (contenido.Length == 0) throw new ArgumentException("El mensaje esta vacio.");
            if (contenido.Length > 2000) contenido = contenido[..2000];

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Mensaje SET Contenido = @Contenido, Editado = 1 " +
                "OUTPUT INSERTED.MensajeId, INSERTED.ConversacionId, INSERTED.RemitenteId, INSERTED.Contenido, INSERTED.Fecha, INSERTED.Leido, " +
                "INSERTED.Tipo, INSERTED.ArchivoUrl, INSERTED.PublicacionId, INSERTED.RespuestaAId, INSERTED.Editado, INSERTED.EliminadoParaTodos " +
                "WHERE MensajeId = @MensajeId AND ConversacionId = @ConversacionId AND RemitenteId = @UsuarioId " +
                "AND EliminadoParaTodos = 0 AND Fecha >= @Limite", connection);
            command.Parameters.AddWithValue("@Contenido", contenido);
            command.Parameters.AddWithValue("@MensajeId", mensajeId);
            command.Parameters.AddWithValue("@ConversacionId", conversacionId);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@Limite", DateTime.Now.AddHours(-2));
            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync()) return MapearMensaje(reader);
            return null;
        }

        public async Task<bool> EliminarMensajeAsync(int conversacionId, int mensajeId, int usuarioId, bool paraTodos)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            if (paraTodos)
            {
                using var command = new SqlCommand(
                    "UPDATE Mensaje SET EliminadoParaTodos = 1 " +
                    "WHERE MensajeId = @MensajeId AND ConversacionId = @ConversacionId AND RemitenteId = @UsuarioId " +
                    "AND EliminadoParaTodos = 0 AND Fecha >= @Limite", connection);
                command.Parameters.AddWithValue("@MensajeId", mensajeId);
                command.Parameters.AddWithValue("@ConversacionId", conversacionId);
                command.Parameters.AddWithValue("@UsuarioId", usuarioId);
                command.Parameters.AddWithValue("@Limite", DateTime.Now.AddHours(-2));
                return await command.ExecuteNonQueryAsync() > 0;
            }

            using var comando = new SqlCommand(
                "UPDATE Mensaje SET " +
                "EliminadoParaRemitente = CASE WHEN RemitenteId = @UsuarioId THEN 1 ELSE EliminadoParaRemitente END, " +
                "EliminadoParaDestinatario = CASE WHEN RemitenteId <> @UsuarioId THEN 1 ELSE EliminadoParaDestinatario END " +
                "WHERE MensajeId = @MensajeId AND ConversacionId = @ConversacionId AND EliminadoParaTodos = 0", connection);
            comando.Parameters.AddWithValue("@MensajeId", mensajeId);
            comando.Parameters.AddWithValue("@ConversacionId", conversacionId);
            comando.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return await comando.ExecuteNonQueryAsync() > 0;
        }

        private async Task<int> ContarNoLeidosDeRemitenteAsync(int conversacionId, int remitenteId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM Mensaje WHERE ConversacionId = @ConversacionId AND RemitenteId = @RemitenteId AND Leido = 0", connection);
            command.Parameters.AddWithValue("@ConversacionId", conversacionId);
            command.Parameters.AddWithValue("@RemitenteId", remitenteId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        private async Task<string> ObtenerNombreUsuarioAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT NombreUsuario FROM Usuario WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return (await command.ExecuteScalarAsync())?.ToString() ?? "Alguien";
        }

        public async Task<bool> MarcarLeidosAsync(int conversacionId, int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();
            try
            {
                using (var command = new SqlCommand("UPDATE Mensaje SET Leido = 1 WHERE ConversacionId = @ConversacionId AND RemitenteId <> @UsuarioId AND Leido = 0", connection, transaction))
                {
                    command.Parameters.AddWithValue("@ConversacionId", conversacionId);
                    command.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    await command.ExecuteNonQueryAsync();
                }

                using (var command = new SqlCommand("UPDATE ConversacionParticipante SET FechaUltimoLeido = @Fecha WHERE ConversacionId = @ConversacionId AND UsuarioId = @UsuarioId", connection, transaction))
                {
                    command.Parameters.AddWithValue("@Fecha", DateTime.Now);
                    command.Parameters.AddWithValue("@ConversacionId", conversacionId);
                    command.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    await command.ExecuteNonQueryAsync();
                }

                transaction.Commit();
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
            return true;
        }

        public async Task<int> ContarNoLeidosAsync(int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT COUNT(1) FROM Mensaje m " +
                "JOIN ConversacionParticipante cp ON cp.ConversacionId = m.ConversacionId AND cp.UsuarioId = @UsuarioId " +
                "WHERE m.RemitenteId <> @UsuarioId AND m.Leido = 0 " +
                "AND m.EliminadoParaTodos = 0 AND m.EliminadoParaDestinatario = 0", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        public async Task<int?> ObtenerOtroParticipanteAsync(int conversacionId, int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT TOP 1 UsuarioId FROM ConversacionParticipante WHERE ConversacionId = @ConversacionId AND UsuarioId <> @UsuarioId", connection);
            command.Parameters.AddWithValue("@ConversacionId", conversacionId);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            var result = await command.ExecuteScalarAsync();
            return result is null or DBNull ? null : Convert.ToInt32(result);
        }
    }
}
