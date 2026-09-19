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
    public class RachasController : ControllerBase
    {
        private readonly IRachaService _rachaService;
        private readonly IUsuarioService _usuarioService;
        private readonly ILogger<RachasController> _logger;

        public RachasController(
            IRachaService rachaService,
            IUsuarioService usuarioService,
            ILogger<RachasController> logger)
        {
            _rachaService = rachaService;
            _usuarioService = usuarioService;
            _logger = logger;
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<RachaResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerHistorialRachas(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var rachas = await _rachaService.ObtenerHistorialRachasAsync(usuarioId);
            return Ok(rachas.Select(Convertir).ToList());
        }

        [HttpGet("usuario/{usuarioId:int}/actual")]
        public async Task<IActionResult> ObtenerRachaActual(int usuarioId)
        {
            var racha = await _rachaService.ObtenerRachaActualAsync(usuarioId);
            return Ok(new { racha });
        }

        [HttpGet("top/{cantidad:int}")]
        [ProducesResponseType(typeof(IEnumerable<RachaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTopRachas(int cantidad)
        {
            var rachas = await _rachaService.ObtenerTopRachasAsync(cantidad);
            return Ok(rachas.Select(Convertir).ToList());
        }

        [HttpPost]
        [ProducesResponseType(typeof(RachaResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> RegistrarAcceso([FromBody] RegistrarAccesoRequestDto dto)
        {
            if (await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            var racha = await _rachaService.RegistrarAccesoAsync(dto.UsuarioId, DateTime.Now);
            return CreatedAtAction(nameof(ObtenerHistorialRachas), new { usuarioId = dto.UsuarioId }, Convertir(racha));
        }

        private static RachaResponseDto Convertir(Racha racha)
        {
            return new RachaResponseDto
            {
                RachaId = racha.RachaId,
                UsuarioId = racha.UsuarioId,
                FechaAcceso = racha.FechaAcceso,
                NumeroRacha = racha.NumeroRacha
            };
        }
    }
}