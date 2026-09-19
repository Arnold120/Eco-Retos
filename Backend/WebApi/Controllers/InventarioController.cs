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
    public class InventarioController : ControllerBase
    {
        private readonly IInventarioService _inventarioService;
        private readonly IUsuarioService _usuarioService;
        private readonly IMaterialService _materialService;
        private readonly ILogger<InventarioController> _logger;

        public InventarioController(
            IInventarioService inventarioService,
            IUsuarioService usuarioService,
            IMaterialService materialService,
            ILogger<InventarioController> logger)
        {
            _inventarioService = inventarioService;
            _usuarioService = usuarioService;
            _materialService = materialService;
            _logger = logger;
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<InventarioResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerInventarioDeUsuario(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var lista = new List<InventarioResponseDto>();
            foreach (var item in await _inventarioService.ObtenerInventarioDeUsuarioAsync(usuarioId))
                lista.Add(await ConvertirAsync(item));
            return Ok(lista);
        }

        [HttpGet("usuario/{usuarioId:int}/material/{materialId:int}")]
        [ProducesResponseType(typeof(InventarioResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorMaterial(int usuarioId, int materialId)
        {
            var item = await _inventarioService.ObtenerPorMaterialAsync(usuarioId, materialId);
            if (item is null)
                return NotFound(new { mensaje = "El usuario no posee ese material." });
            return Ok(await ConvertirAsync(item));
        }

        [HttpPost]
        [ProducesResponseType(typeof(InventarioResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> AgregarMaterial([FromBody] AgregarInventarioRequestDto dto)
        {
            if (await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            if (await _materialService.ObtenerPorIdAsync(dto.MaterialId) is null)
                return NotFound(new { mensaje = $"No se encontro el material con id {dto.MaterialId}." });

            if (await _inventarioService.ObtenerPorMaterialAsync(dto.UsuarioId, dto.MaterialId) is not null)
                return Conflict(new { mensaje = "El material ya existe en el inventario del usuario." });

            var item = new Inventario
            {
                UsuarioId = dto.UsuarioId,
                MaterialId = dto.MaterialId,
                Cantidad = dto.Cantidad
            };
            item = await _inventarioService.AgregarMaterialAsync(item);
            return CreatedAtAction(nameof(ObtenerPorMaterial), new { usuarioId = dto.UsuarioId, materialId = dto.MaterialId }, await ConvertirAsync(item));
        }

        [HttpPatch("{inventarioId:int}/cantidad")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ActualizarCantidad(int inventarioId, [FromBody] ActualizarCantidadRequestDto dto)
        {
            var ok = await _inventarioService.ActualizarCantidadAsync(inventarioId, dto.Cantidad);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el item de inventario con id {inventarioId}." });
            return Ok(new { mensaje = "Cantidad actualizada correctamente." });
        }

        [HttpDelete("usuario/{usuarioId:int}/material/{materialId:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> QuitarMaterial(int usuarioId, int materialId)
        {
            var ok = await _inventarioService.QuitarMaterialAsync(usuarioId, materialId);
            if (!ok)
                return NotFound(new { mensaje = "El usuario no posee ese material." });
            return NoContent();
        }

        private async Task<InventarioResponseDto> ConvertirAsync(Inventario inventario)
        {
            var dto = new InventarioResponseDto
            {
                InventarioId = inventario.InventarioId,
                UsuarioId = inventario.UsuarioId,
                MaterialId = inventario.MaterialId,
                Cantidad = inventario.Cantidad
            };

            var material = await _materialService.ObtenerPorIdAsync(inventario.MaterialId);
            if (material is not null)
                dto.NombreMaterial = material.NombreMaterial;

            return dto;
        }
    }
}