using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class UsuarioRetoService : IUsuarioRetoService
    {
        private readonly string _connectionString;

        public UsuarioRetoService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private const string Columnas =
            "UsuarioRetoId, UsuarioId, RetoId, Estado, Evidencia, MotivoRechazo, PuntosObtenidos, FechaInicio, FechaCompletado";

        private UsuarioReto Mapear(SqlDataReader reader)
        {
            return new UsuarioReto
            {
                UsuarioRetoId = DatabaseHelper.ReadInt(reader, "UsuarioRetoId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                RetoId = DatabaseHelper.ReadInt(reader, "RetoId"),
                Estado = DatabaseHelper.ReadString(reader, "Estado"),
                Evidencia = reader.IsDBNull(reader.GetOrdinal("Evidencia")) ? null : DatabaseHelper.ReadString(reader, "Evidencia"),
                MotivoRechazo = reader.IsDBNull(reader.GetOrdinal("MotivoRechazo")) ? null : DatabaseHelper.ReadString(reader, "MotivoRechazo"),
                PuntosObtenidos = DatabaseHelper.ReadInt(reader, "PuntosObtenidos"),
                FechaInicio = DatabaseHelper.ReadDateTime(reader, "FechaInicio"),
                FechaCompletado = DatabaseHelper.ReadNullableDateTime(reader, "FechaCompletado")
            };
        }

        public async Task<IEnumerable<UsuarioReto>> ObtenerTodosAsync()
        {
            var lista = new List<UsuarioReto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM UsuarioReto", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        /// <summary>Evidencias enviadas por estudiantes y aún no decididas por un admin.</summary>
        public async Task<IEnumerable<UsuarioReto>> ObtenerEvidenciasPendientesAsync()
        {
            var lista = new List<UsuarioReto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM UsuarioReto " +
                "WHERE Evidencia IS NOT NULL AND LTRIM(RTRIM(Evidencia)) <> '' " +
                "AND Estado NOT IN ('COMPLETADO', 'RECHAZADO')",
                connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        /// <summary>Todas las evidencias enviadas por estudiantes (cualquier estado).</summary>
        public async Task<IEnumerable<UsuarioReto>> ObtenerEvidenciasAsync()
        {
            var lista = new List<UsuarioReto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM UsuarioReto " +
                "WHERE Evidencia IS NOT NULL AND LTRIM(RTRIM(Evidencia)) <> '' " +
                "ORDER BY UsuarioRetoId DESC",
                connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<UsuarioReto>> ObtenerRetosDeUsuarioAsync(int usuarioId)
        {
            var lista = new List<UsuarioReto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM UsuarioReto WHERE UsuarioId = @UsuarioId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<UsuarioReto>> ObtenerActivosDeUsuarioAsync(int usuarioId)
        {
            var lista = new List<UsuarioReto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM UsuarioReto WHERE UsuarioId = @UsuarioId AND Estado IN ('INICIADO', 'EN_PROGRESO', 'EN_REVISION')", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<UsuarioReto>> ObtenerCompletadosDeUsuarioAsync(int usuarioId)
        {
            var lista = new List<UsuarioReto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM UsuarioReto WHERE UsuarioId = @UsuarioId AND Estado = 'COMPLETADO'", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<UsuarioReto?> ObtenerPorIdAsync(int usuarioRetoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM UsuarioReto WHERE UsuarioRetoId = @UsuarioRetoId", connection);
            command.Parameters.AddWithValue("@UsuarioRetoId", usuarioRetoId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<UsuarioReto?> ObtenerPorUsuarioYRetoAsync(int usuarioId, int retoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM UsuarioReto WHERE UsuarioId = @UsuarioId AND RetoId = @RetoId", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@RetoId", retoId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<UsuarioReto> RegistrarParticipacionAsync(UsuarioReto usuarioReto)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO UsuarioReto (UsuarioId, RetoId, Estado, Evidencia, MotivoRechazo, PuntosObtenidos, FechaInicio, FechaCompletado) OUTPUT INSERTED.UsuarioRetoId VALUES (@UsuarioId, @RetoId, @Estado, @Evidencia, @MotivoRechazo, @PuntosObtenidos, @FechaInicio, @FechaCompletado)", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioReto.UsuarioId);
            command.Parameters.AddWithValue("@RetoId", usuarioReto.RetoId);
            command.Parameters.AddWithValue("@Estado", usuarioReto.Estado);
            command.Parameters.AddWithValue("@Evidencia", (object?)usuarioReto.Evidencia ?? DBNull.Value);
            command.Parameters.AddWithValue("@MotivoRechazo", (object?)usuarioReto.MotivoRechazo ?? DBNull.Value);
            command.Parameters.AddWithValue("@PuntosObtenidos", usuarioReto.PuntosObtenidos);
            command.Parameters.AddWithValue("@FechaInicio", usuarioReto.FechaInicio);
            command.Parameters.AddWithValue("@FechaCompletado", (object?)usuarioReto.FechaCompletado ?? DBNull.Value);
            usuarioReto.UsuarioRetoId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return usuarioReto;
        }

        public async Task<bool> ActualizarEstadoAsync(int usuarioRetoId, string estado)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE UsuarioReto SET Estado = @Estado WHERE UsuarioRetoId = @UsuarioRetoId", connection);
            command.Parameters.AddWithValue("@UsuarioRetoId", usuarioRetoId);
            command.Parameters.AddWithValue("@Estado", estado);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<bool> CompletarRetoAsync(int usuarioRetoId, int puntosObtenidos)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("UPDATE UsuarioReto SET Estado = 'COMPLETADO', PuntosObtenidos = @PuntosObtenidos, FechaCompletado = GETDATE() WHERE UsuarioRetoId = @UsuarioRetoId", connection);
            command.Parameters.AddWithValue("@UsuarioRetoId", usuarioRetoId);
            command.Parameters.AddWithValue("@PuntosObtenidos", puntosObtenidos);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        /// <summary>Acepta la evidencia: el reto queda COMPLETADO con sus puntos.</summary>
        public async Task<bool> AprobarEvidenciaAsync(int usuarioRetoId, int puntosObtenidos)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE UsuarioReto SET Estado = 'COMPLETADO', PuntosObtenidos = @PuntosObtenidos, MotivoRechazo = NULL, FechaCompletado = GETDATE() WHERE UsuarioRetoId = @UsuarioRetoId",
                connection);
            command.Parameters.AddWithValue("@UsuarioRetoId", usuarioRetoId);
            command.Parameters.AddWithValue("@PuntosObtenidos", puntosObtenidos);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        /// <summary>Rechaza la evidencia: el estudiante deberá volver a hacerla.</summary>
        public async Task<bool> RechazarEvidenciaAsync(int usuarioRetoId, string motivo)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE UsuarioReto SET Estado = 'RECHAZADO', MotivoRechazo = @Motivo, PuntosObtenidos = 0, FechaCompletado = NULL WHERE UsuarioRetoId = @UsuarioRetoId",
                connection);
            command.Parameters.AddWithValue("@UsuarioRetoId", usuarioRetoId);
            command.Parameters.AddWithValue("@Motivo", motivo);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        public async Task<bool> RegistrarEvidenciaAsync(int usuarioRetoId, string evidencia)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE UsuarioReto SET Evidencia = @Evidencia, Estado = 'EN_REVISION', MotivoRechazo = NULL WHERE UsuarioRetoId = @UsuarioRetoId",
                connection);
            command.Parameters.AddWithValue("@UsuarioRetoId", usuarioRetoId);
            command.Parameters.AddWithValue("@Evidencia", evidencia);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        /// <summary>
        /// Sincronizacion por lotes en UNA conexion y UNA transaccion.
        /// Por cada item: verifica (o crea) el reto por Codigo, asegura la
        /// participacion del usuario y aplica el estado final. Devuelve los
        /// datos ya resueltos para que el controlador no re-consulte por item.
        /// </summary>
        public async Task<IEnumerable<UsuarioRetoSincronizado>> SincronizarParticipacionesAsync(
            int usuarioId,
            IEnumerable<RetoSincronizacion> participaciones)
        {
            var resultados = new List<UsuarioRetoSincronizado>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();
            try
            {
                foreach (var item in participaciones)
                {
                    var codigo = item.Codigo.Trim();
                    var reto = await BuscarRetoPorCodigoAsync(connection, transaction, codigo, item);
                    if (reto is null)
                        reto = await CrearRetoAsync(connection, transaction, item);

                    var usuarioReto = await BuscarUsuarioRetoAsync(connection, transaction, usuarioId, reto.RetoId);
                    if (usuarioReto is null)
                        usuarioReto = await CrearParticipacionAsync(connection, transaction, usuarioId, reto.RetoId);

                    await AplicarEstadoSincronizadoAsync(connection, transaction, usuarioReto, item);

                    resultados.Add(new UsuarioRetoSincronizado
                    {
                        UsuarioReto = usuarioReto,
                        Codigo = reto.Codigo,
                        TituloReto = reto.Titulo,
                        ExperienciaRecompensaReto = reto.ExperienciaRecompensa,
                        MonedasRecompensaReto = reto.MonedasRecompensa
                    });
                }

                transaction.Commit();
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
            return resultados;
        }

        private async Task<Reto?> BuscarRetoPorCodigoAsync(
            SqlConnection connection,
            SqlTransaction transaction,
            string codigo,
            RetoSincronizacion item)
        {
            Reto? reto = null;
            using (var command = new SqlCommand(
                "SELECT RetoId, Codigo, Titulo, ExperienciaRecompensa, MonedasRecompensa FROM Reto WHERE Codigo = @Codigo",
                connection, transaction))
            {
                command.Parameters.AddWithValue("@Codigo", codigo);
                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    reto = new Reto
                    {
                        RetoId = DatabaseHelper.ReadInt(reader, "RetoId"),
                        Codigo = reader.IsDBNull(reader.GetOrdinal("Codigo")) ? null : DatabaseHelper.ReadString(reader, "Codigo"),
                        Titulo = DatabaseHelper.ReadString(reader, "Titulo"),
                        ExperienciaRecompensa = DatabaseHelper.ReadInt(reader, "ExperienciaRecompensa"),
                        MonedasRecompensa = DatabaseHelper.ReadInt(reader, "MonedasRecompensa")
                    };
                }
            }

            if (reto is null) return null;

            // Mantiene las recompensas alineadas con el catálogo local: los
            // retos creados antes del Monedero quedaron con 0 monedas.
            if (reto.ExperienciaRecompensa != item.ExperienciaRecompensa ||
                reto.MonedasRecompensa != item.MonedasRecompensa)
            {
                using var update = new SqlCommand(
                    "UPDATE Reto SET ExperienciaRecompensa = @ExperienciaRecompensa, MonedasRecompensa = @MonedasRecompensa WHERE RetoId = @RetoId",
                    connection, transaction);
                update.Parameters.AddWithValue("@RetoId", reto.RetoId);
                update.Parameters.AddWithValue("@ExperienciaRecompensa", item.ExperienciaRecompensa);
                update.Parameters.AddWithValue("@MonedasRecompensa", item.MonedasRecompensa);
                await update.ExecuteNonQueryAsync();
                reto.ExperienciaRecompensa = item.ExperienciaRecompensa;
                reto.MonedasRecompensa = item.MonedasRecompensa;
            }
            return reto;
        }

        private async Task<Reto> CrearRetoAsync(
            SqlConnection connection,
            SqlTransaction transaction,
            RetoSincronizacion item)
        {
            if (item.CategoriaId < 1 || item.CategoriaId > 7)
                throw new InvalidOperationException("La categoria debe ser una de las 7 categorias oficiales (1-7).");

            using var command = new SqlCommand(
                "INSERT INTO Reto (Codigo, CategoriaId, Titulo, Descripcion, Instrucciones, ExperienciaRecompensa, MonedasRecompensa, Dificultad, FechaInicio, FechaFin, Estado) OUTPUT INSERTED.RetoId VALUES (@Codigo, @CategoriaId, @Titulo, @Descripcion, @Instrucciones, @ExperienciaRecompensa, @MonedasRecompensa, @Dificultad, @FechaInicio, @FechaFin, @Estado)",
                connection, transaction);
            command.Parameters.AddWithValue("@Codigo", item.Codigo.Trim());
            command.Parameters.AddWithValue("@CategoriaId", item.CategoriaId);
            command.Parameters.AddWithValue("@Titulo", item.Titulo.Trim());
            command.Parameters.AddWithValue("@Descripcion", item.Descripcion.Trim());
            command.Parameters.AddWithValue("@Instrucciones", item.Instrucciones.Trim());
            command.Parameters.AddWithValue("@ExperienciaRecompensa", item.ExperienciaRecompensa);
            command.Parameters.AddWithValue("@MonedasRecompensa", item.MonedasRecompensa);
            command.Parameters.AddWithValue("@Dificultad", item.Dificultad.Trim().ToUpper());
            command.Parameters.AddWithValue("@FechaInicio", DateTime.Now);
            command.Parameters.AddWithValue("@FechaFin", DBNull.Value);
            command.Parameters.AddWithValue("@Estado", "ACTIVO");
            return new Reto
            {
                RetoId = Convert.ToInt32(await command.ExecuteScalarAsync()),
                Codigo = item.Codigo.Trim(),
                CategoriaId = item.CategoriaId,
                Titulo = item.Titulo.Trim(),
                Descripcion = item.Descripcion.Trim(),
                ExperienciaRecompensa = item.ExperienciaRecompensa,
                MonedasRecompensa = item.MonedasRecompensa,
                Dificultad = item.Dificultad.Trim().ToUpper()
            };
        }

        private async Task<UsuarioReto?> BuscarUsuarioRetoAsync(
            SqlConnection connection,
            SqlTransaction transaction,
            int usuarioId,
            int retoId)
        {
            using var command = new SqlCommand(
                $"SELECT {Columnas} FROM UsuarioReto WHERE UsuarioId = @UsuarioId AND RetoId = @RetoId",
                connection, transaction);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@RetoId", retoId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        private async Task<UsuarioReto> CrearParticipacionAsync(
            SqlConnection connection,
            SqlTransaction transaction,
            int usuarioId,
            int retoId)
        {
            using var command = new SqlCommand(
                "INSERT INTO UsuarioReto (UsuarioId, RetoId, Estado, Evidencia, MotivoRechazo, PuntosObtenidos, FechaInicio, FechaCompletado) OUTPUT INSERTED.UsuarioRetoId VALUES (@UsuarioId, @RetoId, @Estado, @Evidencia, @MotivoRechazo, @PuntosObtenidos, @FechaInicio, @FechaCompletado)",
                connection, transaction);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@RetoId", retoId);
            command.Parameters.AddWithValue("@Estado", "INICIADO");
            command.Parameters.AddWithValue("@Evidencia", DBNull.Value);
            command.Parameters.AddWithValue("@MotivoRechazo", DBNull.Value);
            command.Parameters.AddWithValue("@PuntosObtenidos", 0);
            command.Parameters.AddWithValue("@FechaInicio", DateTime.Now);
            command.Parameters.AddWithValue("@FechaCompletado", DBNull.Value);
            return new UsuarioReto
            {
                UsuarioRetoId = Convert.ToInt32(await command.ExecuteScalarAsync()),
                UsuarioId = usuarioId,
                RetoId = retoId,
                Estado = "INICIADO",
                PuntosObtenidos = 0,
                FechaInicio = DateTime.Now
            };
        }

        /// <summary>Refleja en la DB el estado final que trae el item sincronizado.</summary>
        private async Task AplicarEstadoSincronizadoAsync(
            SqlConnection connection,
            SqlTransaction transaction,
            UsuarioReto usuarioReto,
            RetoSincronizacion item)
        {
            var estado = item.Estado.Trim().ToUpper();
            if (estado == "EN_REVISION" && !string.IsNullOrWhiteSpace(item.Evidencia))
            {
                using var command = new SqlCommand(
                    "UPDATE UsuarioReto SET Evidencia = @Evidencia, Estado = 'EN_REVISION', MotivoRechazo = NULL WHERE UsuarioRetoId = @UsuarioRetoId",
                    connection, transaction);
                command.Parameters.AddWithValue("@UsuarioRetoId", usuarioReto.UsuarioRetoId);
                command.Parameters.AddWithValue("@Evidencia", item.Evidencia.Trim());
                await command.ExecuteNonQueryAsync();
                usuarioReto.Estado = "EN_REVISION";
                usuarioReto.Evidencia = item.Evidencia.Trim();
                usuarioReto.MotivoRechazo = null;
            }
            else if (estado == "COMPLETADO")
            {
                using var command = new SqlCommand(
                    "UPDATE UsuarioReto SET Estado = 'COMPLETADO', PuntosObtenidos = @PuntosObtenidos, FechaCompletado = GETDATE() WHERE UsuarioRetoId = @UsuarioRetoId",
                    connection, transaction);
                command.Parameters.AddWithValue("@UsuarioRetoId", usuarioReto.UsuarioRetoId);
                command.Parameters.AddWithValue("@PuntosObtenidos", item.PuntosObtenidos);
                await command.ExecuteNonQueryAsync();
                usuarioReto.Estado = "COMPLETADO";
                usuarioReto.PuntosObtenidos = item.PuntosObtenidos;
                usuarioReto.FechaCompletado = DateTime.Now;
            }
            else if (estado == "INICIADO")
            {
                using var command = new SqlCommand(
                    "UPDATE UsuarioReto SET Estado = 'INICIADO' WHERE UsuarioRetoId = @UsuarioRetoId",
                    connection, transaction);
                command.Parameters.AddWithValue("@UsuarioRetoId", usuarioReto.UsuarioRetoId);
                await command.ExecuteNonQueryAsync();
                usuarioReto.Estado = "INICIADO";
            }
        }
    }
}