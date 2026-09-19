using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/usuarios-insignias")]
    [Authorize]
    public class UsuariosInsigniasController : ControllerBase
    {
        private readonly IUsuarioInsigniaService _usuarioInsigniaService;
        private readonly IInsigniaService _insigniaService;
        private readonly IUsuarioService _usuarioService;
        private readonly ILogger<UsuariosInsigniasController> _logger;

        public UsuariosInsigniasController(
            IUsuarioInsigniaService usuarioInsigniaService,
            IInsigniaService insigniaService,
            IUsuarioService usuarioService,
            ILogger<UsuariosInsigniasController> logger)
        {
            _usuarioInsigniaService = usuarioInsigniaService;
            _insigniaService = insigniaService;
            _usuarioService = usuarioService;
            _logger = logger;
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioInsigniaResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerInsigniasDeUsuario(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var lista = new List<UsuarioInsigniaResponseDto>();
            foreach (var ui in await _usuarioInsigniaService.ObtenerInsigniasDeUsuarioAsync(usuarioId))
                lista.Add(await ConvertirAsync(ui));
            return Ok(lista);
        }

        [HttpGet("usuario/{usuarioId:int}/total")]
        public async Task<IActionResult> ContarInsignias(int usuarioId)
        {
            var total = await _usuarioInsigniaService.ContarInsigniasAsync(usuarioId);
            return Ok(new { total });
        }

        [HttpGet("usuario/{usuarioId:int}/insignia/{insigniaId:int}")]
        public async Task<IActionResult> UsuarioTieneInsignia(int usuarioId, int insigniaId)
        {
            var tiene = await _usuarioInsigniaService.UsuarioTieneInsigniaAsync(usuarioId, insigniaId);
            return Ok(new { tiene });
        }

        [HttpGet]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioInsigniaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodos()
        {
            var lista = new List<UsuarioInsigniaResponseDto>();
            foreach (var ui in await _usuarioInsigniaService.ObtenerTodosAsync())
                lista.Add(await ConvertirAsync(ui));
            return Ok(lista);
        }

        [HttpPost]
        [ProducesResponseType(typeof(UsuarioInsigniaResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> OtorgarInsignia([FromBody] OtorgarInsigniaRequestDto dto)
        {
            if (await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            if (await _insigniaService.ObtenerPorIdAsync(dto.InsigniaId) is null)
                return NotFound(new { mensaje = $"No se encontro la insignia con id {dto.InsigniaId}." });

            if (await _usuarioInsigniaService.UsuarioTieneInsigniaAsync(dto.UsuarioId, dto.InsigniaId))
                return Conflict(new { mensaje = "El usuario ya posee esa insignia." });

            var usuarioInsignia = new UsuarioInsignia
            {
                UsuarioId = dto.UsuarioId,
                InsigniaId = dto.InsigniaId,
                FechaObtencion = DateTime.Now
            };
            usuarioInsignia = await _usuarioInsigniaService.OtorgarInsigniaAsync(usuarioInsignia);
            return CreatedAtAction(nameof(ObtenerInsigniasDeUsuario), new { usuarioId = dto.UsuarioId }, await ConvertirAsync(usuarioInsignia));
        }

        private async Task<UsuarioInsigniaResponseDto> ConvertirAsync(UsuarioInsignia usuarioInsignia)
        {
            var dto = new UsuarioInsigniaResponseDto
            {
                UsuarioInsigniaId = usuarioInsignia.UsuarioInsigniaId,
                UsuarioId = usuarioInsignia.UsuarioId,
                InsigniaId = usuarioInsignia.InsigniaId,
                FechaObtencion = usuarioInsignia.FechaObtencion
            };

            var insignia = await _insigniaService.ObtenerPorIdAsync(usuarioInsignia.InsigniaId);
            if (insignia is not null)
                dto.NombreInsignia = insignia.NombreInsignia;

            return dto;
        }
    }
}