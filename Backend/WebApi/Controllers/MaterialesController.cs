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
    public class MaterialesController : ControllerBase
    {
        private readonly IMaterialService _materialService;
        private readonly ILogger<MaterialesController> _logger;

        public MaterialesController(IMaterialService materialService, ILogger<MaterialesController> logger)
        {
            _materialService = materialService;
            _logger = logger;
        }

        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<MaterialResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodos()
        {
            var materiales = await _materialService.ObtenerTodosAsync();
            return Ok(materiales.Select(Convertir).ToList());
        }

        [HttpGet("disponibles")]
        [ProducesResponseType(typeof(IEnumerable<MaterialResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerDisponibles()
        {
            var materiales = await _materialService.ObtenerDisponiblesAsync();
            return Ok(materiales.Select(Convertir).ToList());
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(MaterialResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var material = await _materialService.ObtenerPorIdAsync(id);
            if (material is null)
                return NotFound(new { mensaje = $"No se encontro el material con id {id}." });
            return Ok(Convertir(material));
        }

        [HttpGet("tipo/{tipo}")]
        [ProducesResponseType(typeof(IEnumerable<MaterialResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorTipo(string tipo)
        {
            var materiales = await _materialService.ObtenerPorTipoAsync(tipo.Trim().ToUpper());
            return Ok(materiales.Select(Convertir).ToList());
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(MaterialResponseDto), StatusCodes.Status201Created)]
        public async Task<IActionResult> Crear([FromBody] CrearMaterialRequestDto dto)
        {
            var material = new Material
            {
                NombreMaterial = dto.NombreMaterial.Trim(),
                Descripcion = dto.Descripcion.Trim(),
                Tipo = dto.Tipo.Trim().ToUpper(),
                PrecioMonedas = dto.PrecioMonedas,
                CantidadDisponible = dto.CantidadDisponible,
                Imagen = dto.Imagen,
                Estado = "DISPONIBLE"
            };
            material = await _materialService.CrearAsync(material);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = material.MaterialId }, Convertir(material));
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(MaterialResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarMaterialRequestDto dto)
        {
            var material = await _materialService.ObtenerPorIdAsync(id);
            if (material is null)
                return NotFound(new { mensaje = $"No se encontro el material con id {id}." });

            material.NombreMaterial = dto.NombreMaterial.Trim();
            material.Descripcion = dto.Descripcion.Trim();
            material.Tipo = dto.Tipo.Trim().ToUpper();
            material.PrecioMonedas = dto.PrecioMonedas;
            material.CantidadDisponible = dto.CantidadDisponible;
            material.Imagen = dto.Imagen;
            material.Estado = dto.Estado.Trim().ToUpper();

            var actualizado = await _materialService.ActualizarAsync(material);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro el material con id {id}." });

            return Ok(Convertir(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _materialService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el material con id {id}." });
            return NoContent();
        }

        private static MaterialResponseDto Convertir(Material material)
        {
            return new MaterialResponseDto
            {
                MaterialId = material.MaterialId,
                NombreMaterial = material.NombreMaterial,
                Descripcion = material.Descripcion,
                Tipo = material.Tipo,
                PrecioMonedas = material.PrecioMonedas,
                CantidadDisponible = material.CantidadDisponible,
                Imagen = material.Imagen,
                Estado = material.Estado
            };
        }
    }
}
