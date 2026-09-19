using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/intentos-trivia")]
    [Authorize]
    public class IntentosTriviaController : ControllerBase
    {
        private readonly IIntentoTriviaService _intentoTriviaService;
        private readonly IUsuarioService _usuarioService;
        private readonly ITriviaService _triviaService;
        private readonly ILogger<IntentosTriviaController> _logger;

        public IntentosTriviaController(
            IIntentoTriviaService intentoTriviaService,
            IUsuarioService usuarioService,
            ITriviaService triviaService,
            ILogger<IntentosTriviaController> logger)
        {
            _intentoTriviaService = intentoTriviaService;
            _usuarioService = usuarioService;
            _triviaService = triviaService;
            _logger = logger;
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<IntentoTriviaResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerIntentosDeUsuario(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var lista = new List<IntentoTriviaResponseDto>();
            foreach (var intento in await _intentoTriviaService.ObtenerIntentosDeUsuarioAsync(usuarioId))
                lista.Add(await ConvertirAsync(intento));
            return Ok(lista);
        }

        [HttpGet("trivia/{triviaId:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<IntentoTriviaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorTrivia(int triviaId)
        {
            var lista = new List<IntentoTriviaResponseDto>();
            foreach (var intento in await _intentoTriviaService.ObtenerPorTriviaAsync(triviaId))
                lista.Add(await ConvertirAsync(intento));
            return Ok(lista);
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(IntentoTriviaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var intento = await _intentoTriviaService.ObtenerPorIdAsync(id);
            if (intento is null)
                return NotFound(new { mensaje = $"No se encontro el intento con id {id}." });
            return Ok(await ConvertirAsync(intento));
        }

        [HttpGet("usuario/{usuarioId:int}/trivia/{triviaId:int}/mejor")]
        [ProducesResponseType(typeof(int), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerMejorPuntuacion(int usuarioId, int triviaId)
        {
            var puntuacion = await _intentoTriviaService.ObtenerMejorPuntuacionAsync(usuarioId, triviaId);
            if (puntuacion is null)
                return NotFound(new { mensaje = "El usuario no ha realizado intentos en esa trivia." });
            return Ok(new { puntuacion = puntuacion.Value });
        }

        [HttpPost]
        [ProducesResponseType(typeof(IntentoTriviaResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> IniciarIntento([FromBody] IniciarIntentoRequestDto dto)
        {
            if (await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            if (await _triviaService.ObtenerPorIdAsync(dto.TriviaId) is null)
                return NotFound(new { mensaje = $"No se encontro la trivia con id {dto.TriviaId}." });

            var intento = new IntentoTrivia
            {
                UsuarioId = dto.UsuarioId,
                TriviaId = dto.TriviaId,
                Puntuacion = 0,
                FechaInicio = DateTime.Now
            };
            intento = await _intentoTriviaService.IniciarIntentoAsync(intento);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = intento.IntentoId }, await ConvertirAsync(intento));
        }

        [HttpPatch("{id:int}/finalizar")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> FinalizarIntento(int id, [FromBody] FinalizarIntentoRequestDto dto)
        {
            var ok = await _intentoTriviaService.FinalizarIntentoAsync(id, dto.Puntuacion);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el intento con id {id}." });
            return Ok(new { mensaje = "Intento finalizado correctamente." });
        }

        private async Task<IntentoTriviaResponseDto> ConvertirAsync(IntentoTrivia intento)
        {
            var dto = new IntentoTriviaResponseDto
            {
                IntentoId = intento.IntentoId,
                UsuarioId = intento.UsuarioId,
                TriviaId = intento.TriviaId,
                Puntuacion = intento.Puntuacion,
                FechaInicio = intento.FechaInicio,
                FechaFinalizacion = intento.FechaFinalizacion
            };

            var trivia = await _triviaService.ObtenerPorIdAsync(intento.TriviaId);
            if (trivia is not null)
                dto.TituloTrivia = trivia.Titulo;

            return dto;
        }
    }
}