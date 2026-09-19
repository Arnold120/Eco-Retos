using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Helpers;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/monedero")]
    [Authorize]
    public class MonederoController : ControllerBase
    {
        private readonly IMonederoService _monederoService;
        private readonly IProgresoService _progresoService;
        private readonly IRecompensaService _recompensaService;
        private readonly ICategoriaService _categoriaService;

        public MonederoController(
            IMonederoService monederoService,
            IProgresoService progresoService,
            IRecompensaService recompensaService,
            ICategoriaService categoriaService)
        {
            _monederoService = monederoService;
            _progresoService = progresoService;
            _recompensaService = recompensaService;
            _categoriaService = categoriaService;
        }

        /// <summary>Saldo de Monedas Eco y resumen de XP del usuario autenticado.</summary>
        [HttpGet("saldo")]
        [ProducesResponseType(typeof(MonederoSaldoResponseDto), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerSaldo()
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized(new { mensaje = "Token inválido o sin usuario." });

            var saldo = await _monederoService.ObtenerSaldoAsync(usuarioId.Value);
            var progreso = await _progresoService.ObtenerOCrearProgresoAsync(usuarioId.Value);

            return Ok(new MonederoSaldoResponseDto
            {
                Saldo = saldo,
                Experiencia = progreso.Experiencia,
                NivelActual = progreso.NivelActual,
                XpEnNivel = progreso.Experiencia % ProgresoCalculator.XpPorNivel,
                XpMaximoNivel = ProgresoCalculator.XpPorNivel,
                PorcentajeProgreso = progreso.PorcentajeProgreso
            });
        }

        /// <summary>Historial de movimientos de monedas del usuario autenticado.</summary>
        [HttpGet("historial")]
        [ProducesResponseType(typeof(IEnumerable<HistorialMonedaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerHistorial([FromQuery] int? cantidad)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized(new { mensaje = "Token inválido o sin usuario." });

            var historial = await _monederoService.ObtenerHistorialAsync(usuarioId.Value, cantidad);
            var resultado = new List<HistorialMonedaResponseDto>();
            foreach (var item in historial)
                resultado.Add(await ConvertirAsync(item));
            return Ok(resultado);
        }

        [HttpGet("historial/por-categoria")]
        [ProducesResponseType(typeof(IEnumerable<CategoriaMonedasResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorCategoria()
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized(new { mensaje = "Token inválido o sin usuario." });

            var grupos = await _monederoService.ObtenerPorCategoriaAsync(usuarioId.Value);
            var resultado = new List<CategoriaMonedasResponseDto>();
            foreach (var grupo in grupos)
            {
                var categoria = grupo.CategoriaId == 0
                    ? null
                    : await _categoriaService.ObtenerPorIdAsync(grupo.CategoriaId);
                resultado.Add(new CategoriaMonedasResponseDto
                {
                    CategoriaId = grupo.CategoriaId,
                    NombreCategoria = categoria?.NombreCategoria ?? "Sin categoría",
                    Total = grupo.Total
                });
            }
            return Ok(resultado);
        }

        /// <summary>
        /// Reclama una recompensa (trivia, reto o insignia). El backend calcula
        /// la XP y las monedas desde su configuración y es idempotente por clave.
        /// </summary>
        [HttpPost("recompensa")]
        [ProducesResponseType(typeof(ReclamarRecompensaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> ReclamarRecompensa([FromBody] ReclamarRecompensaRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized(new { mensaje = "Token inválido o sin usuario." });

            var resultado = await _recompensaService.ReclamarAsync(
                usuarioId.Value,
                dto.Tipo,
                dto.ClaveIdempotencia,
                dto.CategoriaId,
                dto.Puntuacion,
                dto.TotalPreguntas,
                dto.RetoId,
                dto.InsigniaId,
                dto.Descripcion);

            if (!resultado.Exito)
                return BadRequest(new { mensaje = resultado.Mensaje ?? "No se pudo reclamar la recompensa." });

            return Ok(new ReclamarRecompensaResponseDto
            {
                Duplicado = resultado.Duplicado,
                ExperienciaGanada = resultado.ExperienciaGanada,
                MonedasGanadas = resultado.MonedasGanadas,
                Saldo = resultado.Saldo,
                Experiencia = resultado.Experiencia,
                NivelActual = resultado.NivelActual,
                PorcentajeProgreso = resultado.PorcentajeProgreso
            });
        }

        /// <summary>
        /// Gasta Monedas Eco (por ejemplo herramientas del jardín). El backend
        /// valida el saldo de forma atómica y registra el movimiento.
        /// </summary>
        [HttpPost("gastar")]
        [ProducesResponseType(typeof(GastarMonedasResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Gastar([FromBody] GastarMonedasRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized(new { mensaje = "Token inválido o sin usuario." });

            var resultado = await _monederoService.GastarMonedasAsync(
                usuarioId.Value,
                dto.Cantidad,
                dto.Tipo,
                dto.Descripcion,
                dto.CategoriaId,
                dto.ClaveIdempotencia);

            if (!resultado.Exito)
                return BadRequest(new { mensaje = resultado.Mensaje ?? "No se pudo completar el gasto." });

            return Ok(new GastarMonedasResponseDto
            {
                Saldo = resultado.Saldo,
                Cantidad = -dto.Cantidad
            });
        }

        private async Task<HistorialMonedaResponseDto> ConvertirAsync(Modelo.HistorialMoneda item)
        {
            var categoria = item.CategoriaId is null
                ? null
                : await _categoriaService.ObtenerPorIdAsync(item.CategoriaId.Value);
            return new HistorialMonedaResponseDto
            {
                HistorialMonedaId = item.HistorialMonedaId,
                UsuarioId = item.UsuarioId,
                CategoriaId = item.CategoriaId,
                NombreCategoria = categoria?.NombreCategoria ?? string.Empty,
                Cantidad = item.Cantidad,
                Tipo = item.Tipo,
                Descripcion = item.Descripcion,
                SaldoResultante = item.SaldoResultante,
                Fecha = item.Fecha
            };
        }
    }
}
