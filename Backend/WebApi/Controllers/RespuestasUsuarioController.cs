using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/respuestas-usuario")]
    [Authorize]
    public class RespuestasUsuarioController : ControllerBase
    {
        private readonly IRespuestaUsuarioService _respuestaUsuarioService;
        private readonly IIntentoTriviaService _intentoTriviaService;
        private readonly ILogger<RespuestasUsuarioController> _logger;

        public RespuestasUsuarioController(
            IRespuestaUsuarioService respuestaUsuarioService,
            IIntentoTriviaService intentoTriviaService,
            ILogger<RespuestasUsuarioController> logger)
        {
            _respuestaUsuarioService = respuestaUsuarioService;
            _intentoTriviaService = intentoTriviaService;
            _logger = logger;
        }

        [HttpGet("intento/{intentoId:int}")]
        [ProducesResponseType(typeof(IEnumerable<RespuestaUsuarioResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerRespuestasDeIntento(int intentoId)
        {
            if (await _intentoTriviaService.ObtenerPorIdAsync(intentoId) is null)
                return NotFound(new { mensaje = $"No se encontro el intento con id {intentoId}." });

            var respuestas = await _respuestaUsuarioService.ObtenerRespuestasDeIntentoAsync(intentoId);
            return Ok(respuestas.Select(Convertir).ToList());
        }

        [HttpGet("intento/{intentoId:int}/correctas")]
        [ProducesResponseType(typeof(int), StatusCodes.Status200OK)]
        public async Task<IActionResult> ContarCorrectas(int intentoId)
        {
            var correctas = await _respuestaUsuarioService.ContarCorrectasAsync(intentoId);
            return Ok(new { correctas });
        }

        [HttpPost]
        [ProducesResponseType(typeof(RespuestaUsuarioResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> RegistrarRespuesta([FromBody] RegistrarRespuestaRequestDto dto)
        {
            if (await _intentoTriviaService.ObtenerPorIdAsync(dto.IntentoId) is null)
                return NotFound(new { mensaje = $"No se encontro el intento con id {dto.IntentoId}." });

            var respuesta = new RespuestaUsuario
            {
                IntentoId = dto.IntentoId,
                PreguntaId = dto.PreguntaId,
                OpcionId = dto.OpcionId,
                EsCorrecta = dto.EsCorrecta
            };
            respuesta = await _respuestaUsuarioService.RegistrarRespuestaAsync(respuesta);
            return CreatedAtAction(nameof(ObtenerRespuestasDeIntento), new { intentoId = dto.IntentoId }, Convertir(respuesta));
        }

        private static RespuestaUsuarioResponseDto Convertir(RespuestaUsuario respuesta)
        {
            return new RespuestaUsuarioResponseDto
            {
                RespuestaId = respuesta.RespuestaId,
                IntentoId = respuesta.IntentoId,
                PreguntaId = respuesta.PreguntaId,
                OpcionId = respuesta.OpcionId,
                EsCorrecta = respuesta.EsCorrecta
            };
        }
    }
}