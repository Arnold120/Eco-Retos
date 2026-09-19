using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/opciones-respuesta")]
    [Authorize]
    public class OpcionesRespuestaController : ControllerBase
    {
        private readonly IOpcionRespuestaService _opcionRespuestaService;
        private readonly IPreguntaService _preguntaService;
        private readonly ILogger<OpcionesRespuestaController> _logger;

        public OpcionesRespuestaController(
            IOpcionRespuestaService opcionRespuestaService,
            IPreguntaService preguntaService,
            ILogger<OpcionesRespuestaController> logger)
        {
            _opcionRespuestaService = opcionRespuestaService;
            _preguntaService = preguntaService;
            _logger = logger;
        }

        [HttpGet("pregunta/{preguntaId:int}")]
        [ProducesResponseType(typeof(IEnumerable<OpcionRespuestaDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorPregunta(int preguntaId)
        {
            if (await _preguntaService.ObtenerPorIdAsync(preguntaId) is null)
                return NotFound(new { mensaje = $"No se encontro la pregunta con id {preguntaId}." });

            var opciones = await _opcionRespuestaService.ObtenerPorPreguntaAsync(preguntaId);
            return Ok(opciones.Select(Convertir).ToList());
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(OpcionRespuestaDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var opcion = await _opcionRespuestaService.ObtenerPorIdAsync(id);
            if (opcion is null)
                return NotFound(new { mensaje = $"No se encontro la opcion con id {id}." });
            return Ok(Convertir(opcion));
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(OpcionRespuestaDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Crear([FromBody] CrearOpcionRequestDto dto)
        {
            if (await _preguntaService.ObtenerPorIdAsync(dto.PreguntaId) is null)
                return NotFound(new { mensaje = $"No se encontro la pregunta con id {dto.PreguntaId}." });

            var opcion = new OpcionRespuesta
            {
                PreguntaId = dto.PreguntaId,
                TextoOpcion = dto.TextoOpcion.Trim(),
                EsCorrecta = dto.EsCorrecta
            };
            opcion = await _opcionRespuestaService.CrearAsync(opcion);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = opcion.OpcionId }, Convertir(opcion));
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(OpcionRespuestaDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarOpcionRequestDto dto)
        {
            var opcion = await _opcionRespuestaService.ObtenerPorIdAsync(id);
            if (opcion is null)
                return NotFound(new { mensaje = $"No se encontro la opcion con id {id}." });

            opcion.TextoOpcion = dto.TextoOpcion.Trim();
            opcion.EsCorrecta = dto.EsCorrecta;

            var actualizado = await _opcionRespuestaService.ActualizarAsync(opcion);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro la opcion con id {id}." });

            return Ok(Convertir(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _opcionRespuestaService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la opcion con id {id}." });
            return NoContent();
        }

        private static OpcionRespuestaDto Convertir(OpcionRespuesta opcion)
        {
            return new OpcionRespuestaDto
            {
                OpcionId = opcion.OpcionId,
                PreguntaId = opcion.PreguntaId,
                TextoOpcion = opcion.TextoOpcion,
                EsCorrecta = opcion.EsCorrecta
            };
        }
    }
}