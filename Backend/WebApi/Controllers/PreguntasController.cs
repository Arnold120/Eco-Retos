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
    public class PreguntasController : ControllerBase
    {
        private readonly IPreguntaService _preguntaService;
        private readonly ITriviaService _triviaService;
        private readonly IOpcionRespuestaService _opcionRespuestaService;
        private readonly ILogger<PreguntasController> _logger;

        public PreguntasController(
            IPreguntaService preguntaService,
            ITriviaService triviaService,
            IOpcionRespuestaService opcionRespuestaService,
            ILogger<PreguntasController> logger)
        {
            _preguntaService = preguntaService;
            _triviaService = triviaService;
            _opcionRespuestaService = opcionRespuestaService;
            _logger = logger;
        }

        [HttpGet("trivia/{triviaId:int}")]
        [ProducesResponseType(typeof(IEnumerable<PreguntaResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorTrivia(int triviaId)
        {
            if (await _triviaService.ObtenerPorIdAsync(triviaId) is null)
                return NotFound(new { mensaje = $"No se encontro la trivia con id {triviaId}." });

            var preguntas = await _preguntaService.ObtenerPorTriviaAsync(triviaId);
            return Ok((await ConvertirListaAsync(preguntas)).ToList());
        }

        [HttpGet("trivia/{triviaId:int}/con-opciones")]
        [ProducesResponseType(typeof(IEnumerable<PreguntaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerConOpciones(int triviaId)
        {
            var preguntas = await _preguntaService.ObtenerConOpcionesAsync(triviaId);
            return Ok((await ConvertirListaAsync(preguntas)).ToList());
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(PreguntaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var pregunta = await _preguntaService.ObtenerPorIdAsync(id);
            if (pregunta is null)
                return NotFound(new { mensaje = $"No se encontro la pregunta con id {id}." });
            return Ok(await ConvertirAsync(pregunta));
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(PreguntaResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Crear([FromBody] CrearPreguntaRequestDto dto)
        {
            if (await _triviaService.ObtenerPorIdAsync(dto.TriviaId) is null)
                return NotFound(new { mensaje = $"No se encontro la trivia con id {dto.TriviaId}." });

            var pregunta = new Pregunta
            {
                TriviaId = dto.TriviaId,
                PreguntaTexto = dto.PreguntaTexto.Trim(),
                Puntos = dto.Puntos
            };
            pregunta = await _preguntaService.CrearAsync(pregunta);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = pregunta.PreguntaId }, await ConvertirAsync(pregunta));
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(PreguntaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarPreguntaRequestDto dto)
        {
            var pregunta = await _preguntaService.ObtenerPorIdAsync(id);
            if (pregunta is null)
                return NotFound(new { mensaje = $"No se encontro la pregunta con id {id}." });

            if (dto.TriviaId != pregunta.TriviaId && await _triviaService.ObtenerPorIdAsync(dto.TriviaId) is null)
                return NotFound(new { mensaje = $"No se encontro la trivia con id {dto.TriviaId}." });

            pregunta.TriviaId = dto.TriviaId;
            pregunta.PreguntaTexto = dto.PreguntaTexto.Trim();
            pregunta.Puntos = dto.Puntos;

            var actualizado = await _preguntaService.ActualizarAsync(pregunta);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro la pregunta con id {id}." });

            return Ok(await ConvertirAsync(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _preguntaService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la pregunta con id {id}." });
            return NoContent();
        }

        private async Task<IEnumerable<PreguntaResponseDto>> ConvertirListaAsync(IEnumerable<Pregunta> preguntas)
        {
            var lista = new List<PreguntaResponseDto>();
            foreach (var pregunta in preguntas)
                lista.Add(await ConvertirAsync(pregunta));
            return lista;
        }

        private async Task<PreguntaResponseDto> ConvertirAsync(Pregunta pregunta)
        {
            var dto = new PreguntaResponseDto
            {
                PreguntaId = pregunta.PreguntaId,
                TriviaId = pregunta.TriviaId,
                PreguntaTexto = pregunta.PreguntaTexto,
                Puntos = pregunta.Puntos,
                Opciones = new List<OpcionRespuestaDto>()
            };

            foreach (var opcion in await _opcionRespuestaService.ObtenerPorPreguntaAsync(pregunta.PreguntaId))
            {
                dto.Opciones.Add(new OpcionRespuestaDto
                {
                    OpcionId = opcion.OpcionId,
                    PreguntaId = opcion.PreguntaId,
                    TextoOpcion = opcion.TextoOpcion,
                    EsCorrecta = opcion.EsCorrecta
                });
            }

            return dto;
        }
    }
}