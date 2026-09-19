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
    public class CategoriasController : ControllerBase
    {
        private readonly ICategoriaService _categoriaService;
        private readonly ILogger<CategoriasController> _logger;

        public CategoriasController(ICategoriaService categoriaService, ILogger<CategoriasController> logger)
        {
            _categoriaService = categoriaService;
            _logger = logger;
        }

        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<CategoriaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodas()
        {
            var categorias = await _categoriaService.ObtenerTodosAsync();
            return Ok(categorias.Select(Convertir).ToList());
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(CategoriaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var categoria = await _categoriaService.ObtenerPorIdAsync(id);
            if (categoria is null)
                return NotFound(new { mensaje = $"No se encontro la categoria con id {id}." });
            return Ok(Convertir(categoria));
        }

        [HttpGet("nombre/{nombre}")]
        [ProducesResponseType(typeof(CategoriaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorNombre(string nombre)
        {
            var categoria = await _categoriaService.ObtenerPorNombreAsync(nombre.Trim());
            if (categoria is null)
                return NotFound(new { mensaje = "No se encontro la categoria indicada." });
            return Ok(Convertir(categoria));
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(CategoriaResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Crear([FromBody] CrearCategoriaRequestDto dto)
        {
            var categoria = new Categoria
            {
                NombreCategoria = dto.NombreCategoria.Trim(),
                Descripcion = dto.Descripcion.Trim()
            };
            categoria = await _categoriaService.CrearAsync(categoria);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = categoria.CategoriaId }, Convertir(categoria));
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(CategoriaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarCategoriaRequestDto dto)
        {
            var categoria = await _categoriaService.ObtenerPorIdAsync(id);
            if (categoria is null)
                return NotFound(new { mensaje = $"No se encontro la categoria con id {id}." });

            categoria.NombreCategoria = dto.NombreCategoria.Trim();
            categoria.Descripcion = dto.Descripcion.Trim();

            try
            {
                var actualizado = await _categoriaService.ActualizarAsync(categoria);
                if (actualizado is null)
                    return NotFound(new { mensaje = $"No se encontro la categoria con id {id}." });
                return Ok(Convertir(actualizado));
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Eliminar(int id)
        {
            try
            {
                var ok = await _categoriaService.EliminarAsync(id);
                if (!ok)
                    return NotFound(new { mensaje = $"No se encontro la categoria con id {id}." });
                return NoContent();
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        private static CategoriaResponseDto Convertir(Categoria categoria)
        {
            return new CategoriaResponseDto
            {
                CategoriaId = categoria.CategoriaId,
                NombreCategoria = categoria.NombreCategoria,
                Descripcion = categoria.Descripcion
            };
        }
    }
}