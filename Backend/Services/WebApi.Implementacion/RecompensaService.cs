using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{






    public class RecompensaService : IRecompensaService
    {
        private readonly IMonederoService _monederoService;
        private readonly IProgresoService _progresoService;
        private readonly IUsuarioRetoService _usuarioRetoService;
        private readonly IRetoService _retoService;
        private readonly IUsuarioInsigniaService _usuarioInsigniaService;
        private readonly IInsigniaService _insigniaService;
        private readonly string _connectionString;

        public RecompensaService(
            IMonederoService monederoService,
            IProgresoService progresoService,
            IUsuarioRetoService usuarioRetoService,
            IRetoService retoService,
            IUsuarioInsigniaService usuarioInsigniaService,
            IInsigniaService insigniaService,
            IConfiguration configuration)
        {
            _monederoService = monederoService;
            _progresoService = progresoService;
            _usuarioRetoService = usuarioRetoService;
            _retoService = retoService;
            _usuarioInsigniaService = usuarioInsigniaService;
            _insigniaService = insigniaService;
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<bool> YaReclamadaAsync(int usuarioId, string claveIdempotencia)
        {
            if (string.IsNullOrWhiteSpace(claveIdempotencia)) return false;
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT COUNT(*) FROM RecompensaReclamada WHERE UsuarioId = @UsuarioId AND Clave = @Clave",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            command.Parameters.AddWithValue("@Clave", claveIdempotencia.Trim());
            return Convert.ToInt32(await command.ExecuteScalarAsync()) > 0;
        }

        public async Task<RecompensaResultado> ReclamarAsync(
            int usuarioId,
            string tipo,
            string claveIdempotencia,
            int? categoriaId = null,
            int? puntuacion = null,
            int? totalPreguntas = null,
            int? retoId = null,
            int? insigniaId = null,
            string? descripcion = null)
        {
            if (usuarioId <= 0)
                return Fallo("El usuario es inválido.");

            var tipoNormalizado = (tipo ?? string.Empty).Trim().ToUpperInvariant();
            if (string.IsNullOrWhiteSpace(tipoNormalizado))
                return Fallo("El tipo de recompensa es obligatorio.");
            if (string.IsNullOrWhiteSpace(claveIdempotencia))
                return Fallo("La clave de idempotencia es obligatoria.");
            claveIdempotencia = claveIdempotencia.Trim();
            if (claveIdempotencia.Length > 120)
                return Fallo("La clave de idempotencia no puede superar los 120 caracteres.");


            var calculo = await CalcularRecompensaAsync(
                usuarioId, tipoNormalizado, puntuacion, totalPreguntas, retoId, insigniaId);
            if (!calculo.Exito)
                return Fallo(calculo.Mensaje ?? "No se pudo calcular la recompensa.");
            if (calculo.Experiencia == 0 && calculo.Monedas == 0)
                return Fallo("La recompensa no tiene valor configurado.");

            var descripcionFinal = string.IsNullOrWhiteSpace(descripcion)
                ? calculo.Descripcion
                : descripcion!.Trim();


            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();
            try
            {
                using (var marcar = new SqlCommand(
                    "INSERT INTO RecompensaReclamada (UsuarioId, Clave, Tipo, Fecha) VALUES (@UsuarioId, @Clave, @Tipo, SYSDATETIME())",
                    connection,
                    transaction))
                {
                    marcar.Parameters.AddWithValue("@UsuarioId", usuarioId);
                    marcar.Parameters.AddWithValue("@Clave", claveIdempotencia);
                    marcar.Parameters.AddWithValue("@Tipo", tipoNormalizado);
                    await marcar.ExecuteNonQueryAsync();
                }

                Progreso? progreso = null;
                if (calculo.Experiencia > 0)
                {
                    progreso = await _progresoService.AgregarExperienciaAsync(
                        usuarioId, calculo.Experiencia, connection, transaction);
                }

                var saldo = await LeerSaldoAsync(connection, transaction, usuarioId);
                if (calculo.Monedas > 0)
                {
                    var movimiento = await _monederoService.AgregarMonedasAsync(
                        usuarioId,
                        calculo.Monedas,
                        tipoNormalizado,
                        descripcionFinal,
                        categoriaId,
                        claveIdempotencia: null,
                        conexion: connection,
                        transaccion: transaction);
                    if (!movimiento.Exito)
                    {
                        transaction.Rollback();
                        return Fallo(movimiento.Mensaje ?? "No se pudieron acreditar las monedas.");
                    }
                    saldo = movimiento.Saldo;
                }

                if (progreso is null)
                {
                    progreso = await _progresoService.ObtenerProgresoDeUsuarioAsync(usuarioId);
                }

                transaction.Commit();
                return new RecompensaResultado
                {
                    Exito = true,
                    ExperienciaGanada = calculo.Experiencia,
                    MonedasGanadas = calculo.Monedas,
                    Saldo = saldo,
                    Experiencia = progreso?.Experiencia ?? 0,
                    NivelActual = progreso?.NivelActual ?? 1,
                    PorcentajeProgreso = progreso?.PorcentajeProgreso ?? 0
                };
            }
            catch (SqlException ex) when (ex.Number is 2601 or 2627)
            {
                transaction.Rollback();
                return await ResultadoDuplicadoAsync(usuarioId, tipoNormalizado, claveIdempotencia);
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        private async Task<RecompensaResultado> ResultadoDuplicadoAsync(
            int usuarioId,
            string tipo,
            string clave)
        {
            var progreso = await _progresoService.ObtenerProgresoDeUsuarioAsync(usuarioId);
            var saldo = await _monederoService.ObtenerSaldoAsync(usuarioId);
            return new RecompensaResultado
            {
                Exito = true,
                Duplicado = true,
                Mensaje = $"La recompensa de tipo {tipo} ya fue reclamada.",
                Saldo = saldo,
                Experiencia = progreso?.Experiencia ?? 0,
                NivelActual = progreso?.NivelActual ?? 1,
                PorcentajeProgreso = progreso?.PorcentajeProgreso ?? 0
            };
        }

        private async Task<CalculoRecompensa> CalcularRecompensaAsync(
            int usuarioId,
            string tipo,
            int? puntuacion,
            int? totalPreguntas,
            int? retoId,
            int? insigniaId)
        {
            switch (tipo)
            {
                case "TRIVIA":
                {
                    if (puntuacion is null || totalPreguntas is null)
                        return CalculoRecompensa.Error("La puntuación y el total de preguntas son obligatorios.");
                    if (totalPreguntas < 1 || totalPreguntas > RecompensasConfig.MaximoPreguntasPorTrivia)
                        return CalculoRecompensa.Error($"El total de preguntas debe estar entre 1 y {RecompensasConfig.MaximoPreguntasPorTrivia}.");

                    var puntos = RecompensasConfig.ClampPuntuacion(puntuacion.Value, totalPreguntas.Value);
                    var monedas = RecompensasConfig.MonedasPorPuntuacion(puntos);
                    return new CalculoRecompensa
                    {
                        Exito = true,
                        Experiencia = puntos,
                        Monedas = monedas,
                        Descripcion = $"Trivia completada (+{puntos} XP, +{monedas} Monedas Eco)"
                    };
                }
                case "TRIVIA_SEMANA":
                {
                    return new CalculoRecompensa
                    {
                        Exito = true,
                        Experiencia = RecompensasConfig.XpSemanaCompletada,
                        Monedas = RecompensasConfig.MonedasSemanaCompletada,
                        Descripcion = "Bonus por completar la semana de trivias"
                    };
                }
                case "RETO":
                {
                    if (retoId is null || retoId <= 0)
                        return CalculoRecompensa.Error("El reto es obligatorio.");

                    var participacion = await _usuarioRetoService.ObtenerPorUsuarioYRetoAsync(usuarioId, retoId.Value);
                    if (participacion is null)
                        return CalculoRecompensa.Error("No participas en ese reto.");
                    if (!string.Equals(participacion.Estado, "COMPLETADO", StringComparison.OrdinalIgnoreCase))
                        return CalculoRecompensa.Error("El reto todavía no está completado.");

                    var reto = await _retoService.ObtenerPorIdAsync(retoId.Value);
                    if (reto is null)
                        return CalculoRecompensa.Error("El reto no existe.");

                    return new CalculoRecompensa
                    {
                        Exito = true,
                        Experiencia = reto.ExperienciaRecompensa,
                        Monedas = reto.MonedasRecompensa,
                        Descripcion = $"Reto completado: {reto.Titulo}"
                    };
                }
                case "INSIGNIA":
                {
                    if (insigniaId is null || insigniaId <= 0)
                        return CalculoRecompensa.Error("La insignia es obligatoria.");

                    if (!await _usuarioInsigniaService.UsuarioTieneInsigniaAsync(usuarioId, insigniaId.Value))
                        return CalculoRecompensa.Error("Todavía no has obtenido esa insignia.");

                    var insignia = await _insigniaService.ObtenerPorIdAsync(insigniaId.Value);
                    if (insignia is null)
                        return CalculoRecompensa.Error("La insignia no existe.");

                    return new CalculoRecompensa
                    {
                        Exito = true,
                        Experiencia = 0,
                        Monedas = insignia.MonedasRecompensa,
                        Descripcion = $"Insignia obtenida: {insignia.NombreInsignia}"
                    };
                }
                default:
                    return CalculoRecompensa.Error($"Tipo de recompensa no soportado: {tipo}.");
            }
        }

        private static async Task<int> LeerSaldoAsync(
            SqlConnection connection,
            SqlTransaction transaction,
            int usuarioId)
        {
            using var command = new SqlCommand(
                "SELECT ISNULL((SELECT Saldo FROM Monedero WHERE UsuarioId = @UsuarioId), 0)",
                connection,
                transaction);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        private static RecompensaResultado Fallo(string mensaje)
        {
            return new RecompensaResultado
            {
                Exito = false,
                Duplicado = false,
                Mensaje = mensaje
            };
        }

        private class CalculoRecompensa
        {
            public bool Exito { get; set; }
            public string? Mensaje { get; set; }
            public int Experiencia { get; set; }
            public int Monedas { get; set; }
            public string Descripcion { get; set; } = string.Empty;

            public static CalculoRecompensa Error(string mensaje) =>
                new() { Exito = false, Mensaje = mensaje };
        }
    }
}
