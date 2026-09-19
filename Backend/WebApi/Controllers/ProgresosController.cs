using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ProgresosController : ControllerBase
    {
        private readonly IProgresoService _progresoService;
        private readonly IUsuarioService _usuarioService;
        private readonly ILogger<ProgresosController> _logger;

        public ProgresosController(
            IProgresoService progresoService,
            IUsuarioService usuarioService,
            ILogger<ProgresosController> logger)
        {
            _progresoService = progresoService;
            _usuarioService = usuarioService;
            _logger = logger;
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(ProgresoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerProgresoDeUsuario(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var progreso = await _progresoService.ObtenerProgresoDeUsuarioAsync(usuarioId);
            if (progreso is null)
                return NotFound(new { mensaje = $"No se encontro progreso para el usuario {usuarioId}." });
            return Ok(Convertir(progreso));
        }

        [HttpGet("ranking/{cantidad:int}")]
        [ProducesResponseType(typeof(IEnumerable<ProgresoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerRanking(int cantidad)
        {
            var progresos = await _progresoService.ObtenerRankingAsync(cantidad);
            return Ok(progresos.Select(Convertir).ToList());
        }

        [HttpPost("{usuarioId:int}")]
        [ProducesResponseType(typeof(ProgresoResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> CrearProgreso(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            if (await _progresoService.ObtenerProgresoDeUsuarioAsync(usuarioId) is not null)
                return Conflict(new { mensaje = "El usuario ya posee un progreso." });

            var progreso = await _progresoService.CrearProgresoAsync(new Progreso { UsuarioId = usuarioId });
            return CreatedAtAction(nameof(ObtenerProgresoDeUsuario), new { usuarioId }, Convertir(progreso));
        }

        [HttpPatch("usuario/{usuarioId:int}/retos")]
        public async Task<IActionResult> IncrementarRetosCompletados(int usuarioId)
        {
            var ok = await _progresoService.IncrementarRetosCompletadosAsync(usuarioId);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el progreso del usuario {usuarioId}." });
            return Ok(new { mensaje = "Progreso actualizado correctamente." });
        }

        [HttpPatch("usuario/{usuarioId:int}/trivias")]
        public async Task<IActionResult> IncrementarTriviasCompletadas(int usuarioId)
        {
            var ok = await _progresoService.IncrementarTriviasCompletadasAsync(usuarioId);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el progreso del usuario {usuarioId}." });
            return Ok(new { mensaje = "Progreso actualizado correctamente." });
        }

        [HttpPatch("usuario/{usuarioId:int}/insignias")]
        public async Task<IActionResult> IncrementarInsigniasObtenidas(int usuarioId)
        {
            var ok = await _progresoService.IncrementarInsigniasObtenidasAsync(usuarioId);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el progreso del usuario {usuarioId}." });
            return Ok(new { mensaje = "Progreso actualizado correctamente." });
        }

        [HttpPatch("usuario/{usuarioId:int}/publicaciones")]
        public async Task<IActionResult> IncrementarPublicacionesRealizadas(int usuarioId)
        {
            var ok = await _progresoService.IncrementarPublicacionesRealizadasAsync(usuarioId);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el progreso del usuario {usuarioId}." });
            return Ok(new { mensaje = "Progreso actualizado correctamente." });
        }

        [HttpPatch("usuario/{usuarioId:int}/materiales")]
        public async Task<IActionResult> IncrementarMaterialesObtenidos(int usuarioId)
        {
            var ok = await _progresoService.IncrementarMaterialesObtenidosAsync(usuarioId);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el progreso del usuario {usuarioId}." });
            return Ok(new { mensaje = "Progreso actualizado correctamente." });
        }

        private static ProgresoResponseDto Convertir(Progreso progreso)
        {
            return new ProgresoResponseDto
            {
                ProgresoId = progreso.ProgresoId,
                UsuarioId = progreso.UsuarioId,
                Experiencia = progreso.Experiencia,
                RetosCompletados = progreso.RetosCompletados,
                TriviasCompletadas = progreso.TriviasCompletadas,
                InsigniasObtenidas = progreso.InsigniasObtenidas,
                PublicacionesRealizadas = progreso.PublicacionesRealizadas,
                MaterialesObtenidos = progreso.MaterialesObtenidos,
                NivelActual = progreso.NivelActual,
                PorcentajeProgreso = progreso.PorcentajeProgreso
            };
        }
    }
}