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
    public class RecursosController : ControllerBase
    {
        private readonly IRecursoService _recursoService;
        private readonly ICategoriaService _categoriaService;
        private readonly ILogger<RecursosController> _logger;

        public RecursosController(
            IRecursoService recursoService,
            ICategoriaService categoriaService,
            ILogger<RecursosController> logger)
        {
            _recursoService = recursoService;
            _categoriaService = categoriaService;
            _logger = logger;
        }

        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<RecursoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodos()
        {
            var recursos = await _recursoService.ObtenerTodosAsync();
            return Ok((await ConvertirListaAsync(recursos)).ToList());
        }

        [HttpGet("activos")]
        [ProducesResponseType(typeof(IEnumerable<RecursoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerActivos()
        {
            var recursos = await _recursoService.ObtenerActivosAsync();
            return Ok((await ConvertirListaAsync(recursos)).ToList());
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(RecursoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var recurso = await _recursoService.ObtenerPorIdAsync(id);
            if (recurso is null)
                return NotFound(new { mensaje = $"No se encontro el recurso con id {id}." });
            return Ok(await ConvertirAsync(recurso));
        }

        [HttpGet("categoria/{categoriaId:int}")]
        [ProducesResponseType(typeof(IEnumerable<RecursoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorCategoria(int categoriaId)
        {
            var recursos = await _recursoService.ObtenerPorCategoriaAsync(categoriaId);
            return Ok((await ConvertirListaAsync(recursos)).ToList());
        }

        [HttpGet("tipo/{tipo}")]
        [ProducesResponseType(typeof(IEnumerable<RecursoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorTipo(string tipo)
        {
            var recursos = await _recursoService.ObtenerPorTipoAsync(tipo.Trim().ToUpper());
            return Ok((await ConvertirListaAsync(recursos)).ToList());
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(RecursoResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Crear([FromBody] CrearRecursoRequestDto dto)
        {
            if (await _categoriaService.ObtenerPorIdAsync(dto.CategoriaId) is null)
                return NotFound(new { mensaje = $"No se encontro la categoria con id {dto.CategoriaId}." });

            var recurso = new Recurso
            {
                CategoriaId = dto.CategoriaId,
                Titulo = dto.Titulo.Trim(),
                Descripcion = dto.Descripcion.Trim(),
                Tipo = dto.Tipo.Trim().ToUpper(),
                URL = dto.URL,
                FechaPublicacion = DateTime.Now,
                Estado = "ACTIVO"
            };
            recurso = await _recursoService.CrearAsync(recurso);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = recurso.RecursoId }, await ConvertirAsync(recurso));
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(RecursoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarRecursoRequestDto dto)
        {
            var recurso = await _recursoService.ObtenerPorIdAsync(id);
            if (recurso is null)
                return NotFound(new { mensaje = $"No se encontro el recurso con id {id}." });

            if (dto.CategoriaId != recurso.CategoriaId && await _categoriaService.ObtenerPorIdAsync(dto.CategoriaId) is null)
                return NotFound(new { mensaje = $"No se encontro la categoria con id {dto.CategoriaId}." });

            recurso.CategoriaId = dto.CategoriaId;
            recurso.Titulo = dto.Titulo.Trim();
            recurso.Descripcion = dto.Descripcion.Trim();
            recurso.Tipo = dto.Tipo.Trim().ToUpper();
            recurso.URL = dto.URL;
            recurso.Estado = dto.Estado.Trim().ToUpper();

            var actualizado = await _recursoService.ActualizarAsync(recurso);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro el recurso con id {id}." });

            return Ok(await ConvertirAsync(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _recursoService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el recurso con id {id}." });
            return NoContent();
        }

        private async Task<IEnumerable<RecursoResponseDto>> ConvertirListaAsync(IEnumerable<Recurso> recursos)
        {
            var lista = new List<RecursoResponseDto>();
            foreach (var recurso in recursos)
                lista.Add(await ConvertirAsync(recurso));
            return lista;
        }

        private async Task<RecursoResponseDto> ConvertirAsync(Recurso recurso)
        {
            var categoria = await _categoriaService.ObtenerPorIdAsync(recurso.CategoriaId);
            return new RecursoResponseDto
            {
                RecursoId = recurso.RecursoId,
                CategoriaId = recurso.CategoriaId,
                NombreCategoria = categoria?.NombreCategoria ?? string.Empty,
                Titulo = recurso.Titulo,
                Descripcion = recurso.Descripcion,
                Tipo = recurso.Tipo,
                URL = recurso.URL,
                FechaPublicacion = recurso.FechaPublicacion,
                Estado = recurso.Estado
            };
        }
    }
}