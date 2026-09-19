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
    public class JardinesController : ControllerBase
    {
        private readonly IJardinService _jardinService;
        private readonly IUsuarioService _usuarioService;
        private readonly ILogger<JardinesController> _logger;

        public JardinesController(
            IJardinService jardinService,
            IUsuarioService usuarioService,
            ILogger<JardinesController> logger)
        {
            _jardinService = jardinService;
            _usuarioService = usuarioService;
            _logger = logger;
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(JardinResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerJardinDeUsuario(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var jardin = await _jardinService.ObtenerJardinDeUsuarioAsync(usuarioId);
            if (jardin is null)
                return NotFound(new { mensaje = $"No se encontro un jardin para el usuario {usuarioId}." });
            return Ok(Convertir(jardin));
        }

        [HttpGet("ranking/{cantidad:int}")]
        [ProducesResponseType(typeof(IEnumerable<JardinResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerRankingJardines(int cantidad)
        {
            var jardines = await _jardinService.ObtenerRankingJardinesAsync(cantidad);
            return Ok(jardines.Select(Convertir).ToList());
        }

        [HttpPost("{usuarioId:int}")]
        [ProducesResponseType(typeof(JardinResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> CrearJardin(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            if (await _jardinService.ObtenerJardinDeUsuarioAsync(usuarioId) is not null)
                return Conflict(new { mensaje = "El usuario ya posee un jardin." });

            var jardin = await _jardinService.CrearJardinAsync(new Jardin { UsuarioId = usuarioId });
            return CreatedAtAction(nameof(ObtenerJardinDeUsuario), new { usuarioId }, Convertir(jardin));
        }

        [HttpPut("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(JardinResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ActualizarJardin(int usuarioId, [FromBody] ActualizarJardinRequestDto dto)
        {
            var jardin = await _jardinService.ObtenerJardinDeUsuarioAsync(usuarioId);
            if (jardin is null)
                return NotFound(new { mensaje = $"No se encontro un jardin para el usuario {usuarioId}." });

            jardin.NivelJardin = dto.NivelJardin;
            jardin.Plantas = dto.Plantas;
            jardin.Arboles = dto.Arboles;
            jardin.Flores = dto.Flores;
            jardin.PuntosJardin = dto.PuntosJardin;

            var ok = await _jardinService.ActualizarJardinAsync(jardin);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro un jardin para el usuario {usuarioId}." });

            return Ok(Convertir(jardin));
        }

        [HttpPatch("usuario/{usuarioId:int}/puntos")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> AgregarPuntosJardin(int usuarioId, [FromBody] int puntos)
        {
            var ok = await _jardinService.AgregarPuntosJardinAsync(usuarioId, puntos);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro un jardin para el usuario {usuarioId}." });
            return Ok(new { mensaje = "Puntos agregados al jardin correctamente." });
        }

        private static JardinResponseDto Convertir(Jardin jardin)
        {
            return new JardinResponseDto
            {
                JardinId = jardin.JardinId,
                UsuarioId = jardin.UsuarioId,
                NivelJardin = jardin.NivelJardin,
                Plantas = jardin.Plantas,
                Arboles = jardin.Arboles,
                Flores = jardin.Flores,
                PuntosJardin = jardin.PuntosJardin
            };
        }
    }
}