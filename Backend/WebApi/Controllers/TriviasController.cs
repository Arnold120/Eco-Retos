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
    public class TriviasController : ControllerBase
    {
        private readonly ITriviaService _triviaService;
        private readonly ICategoriaService _categoriaService;
        private readonly ILogger<TriviasController> _logger;

        public TriviasController(
            ITriviaService triviaService,
            ICategoriaService categoriaService,
            ILogger<TriviasController> logger)
        {
            _triviaService = triviaService;
            _categoriaService = categoriaService;
            _logger = logger;
        }

        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<TriviaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodas()
        {
            var trivias = await _triviaService.ObtenerTodosAsync();
            return Ok((await ConvertirListaAsync(trivias)).ToList());
        }

        [HttpGet("activas")]
        [ProducesResponseType(typeof(IEnumerable<TriviaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerActivas()
        {
            var trivias = await _triviaService.ObtenerActivasAsync();
            return Ok((await ConvertirListaAsync(trivias)).ToList());
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(TriviaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var trivia = await _triviaService.ObtenerPorIdAsync(id);
            if (trivia is null)
                return NotFound(new { mensaje = $"No se encontro la trivia con id {id}." });
            return Ok(await ConvertirAsync(trivia));
        }

        [HttpGet("categoria/{categoriaId:int}")]
        [ProducesResponseType(typeof(IEnumerable<TriviaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorCategoria(int categoriaId)
        {
            var trivias = await _triviaService.ObtenerPorCategoriaAsync(categoriaId);
            return Ok((await ConvertirListaAsync(trivias)).ToList());
        }

        [HttpGet("dificultad/{dificultad}")]
        [ProducesResponseType(typeof(IEnumerable<TriviaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorDificultad(string dificultad)
        {
            var trivias = await _triviaService.ObtenerPorDificultadAsync(dificultad.Trim().ToUpper());
            return Ok((await ConvertirListaAsync(trivias)).ToList());
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(TriviaResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Crear([FromBody] CrearTriviaRequestDto dto)
        {
            if (await _categoriaService.ObtenerPorIdAsync(dto.CategoriaId) is null)
                return NotFound(new { mensaje = $"No se encontro la categoria con id {dto.CategoriaId}." });

            var trivia = new Trivia
            {
                CategoriaId = dto.CategoriaId,
                Titulo = dto.Titulo.Trim(),
                Descripcion = dto.Descripcion.Trim(),
                Dificultad = dto.Dificultad.Trim().ToUpper(),
                PuntosMaximos = dto.PuntosMaximos,
                Estado = "ACTIVA"
            };
            trivia = await _triviaService.CrearAsync(trivia);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = trivia.TriviaId }, await ConvertirAsync(trivia));
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(TriviaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarTriviaRequestDto dto)
        {
            var trivia = await _triviaService.ObtenerPorIdAsync(id);
            if (trivia is null)
                return NotFound(new { mensaje = $"No se encontro la trivia con id {id}." });

            if (dto.CategoriaId != trivia.CategoriaId && await _categoriaService.ObtenerPorIdAsync(dto.CategoriaId) is null)
                return NotFound(new { mensaje = $"No se encontro la categoria con id {dto.CategoriaId}." });

            trivia.CategoriaId = dto.CategoriaId;
            trivia.Titulo = dto.Titulo.Trim();
            trivia.Descripcion = dto.Descripcion.Trim();
            trivia.Dificultad = dto.Dificultad.Trim().ToUpper();
            trivia.PuntosMaximos = dto.PuntosMaximos;
            trivia.Estado = dto.Estado.Trim().ToUpper();

            var actualizado = await _triviaService.ActualizarAsync(trivia);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro la trivia con id {id}." });

            return Ok(await ConvertirAsync(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _triviaService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la trivia con id {id}." });
            return NoContent();
        }

        private async Task<IEnumerable<TriviaResponseDto>> ConvertirListaAsync(IEnumerable<Trivia> trivias)
        {
            var lista = new List<TriviaResponseDto>();
            foreach (var trivia in trivias)
                lista.Add(await ConvertirAsync(trivia));
            return lista;
        }

        private async Task<TriviaResponseDto> ConvertirAsync(Trivia trivia)
        {
            var categoria = await _categoriaService.ObtenerPorIdAsync(trivia.CategoriaId);
            return new TriviaResponseDto
            {
                TriviaId = trivia.TriviaId,
                CategoriaId = trivia.CategoriaId,
                NombreCategoria = categoria?.NombreCategoria ?? string.Empty,
                Titulo = trivia.Titulo,
                Descripcion = trivia.Descripcion,
                Dificultad = trivia.Dificultad,
                PuntosMaximos = trivia.PuntosMaximos,
                Estado = trivia.Estado
            };
        }
    }
}