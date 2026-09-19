using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/detalles-compra")]
    [Authorize]
    public class DetallesCompraController : ControllerBase
    {
        private readonly IDetalleCompraService _detalleCompraService;
        private readonly ICompraService _compraService;
        private readonly IMaterialService _materialService;
        private readonly ILogger<DetallesCompraController> _logger;

        public DetallesCompraController(
            IDetalleCompraService detalleCompraService,
            ICompraService compraService,
            IMaterialService materialService,
            ILogger<DetallesCompraController> logger)
        {
            _detalleCompraService = detalleCompraService;
            _compraService = compraService;
            _materialService = materialService;
            _logger = logger;
        }

        [HttpGet("compra/{compraId:int}")]
        [ProducesResponseType(typeof(IEnumerable<DetalleCompraResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerDetallesDeCompra(int compraId)
        {
            if (await _compraService.ObtenerPorIdAsync(compraId) is null)
                return NotFound(new { mensaje = $"No se encontro la compra con id {compraId}." });

            var lista = new List<DetalleCompraResponseDto>();
            foreach (var detalle in await _detalleCompraService.ObtenerDetallesDeCompraAsync(compraId))
                lista.Add(await ConvertirAsync(detalle));
            return Ok(lista);
        }






        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(DetalleCompraResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> CrearDetalle([FromBody] CrearDetalleCompraRequestDto dto)
        {
            if (await _compraService.ObtenerPorIdAsync(dto.CompraId) is null)
                return NotFound(new { mensaje = $"No se encontro la compra con id {dto.CompraId}." });

            if (await _materialService.ObtenerPorIdAsync(dto.MaterialId) is null)
                return NotFound(new { mensaje = $"No se encontro el material con id {dto.MaterialId}." });

            var detalle = new DetalleCompra
            {
                CompraId = dto.CompraId,
                MaterialId = dto.MaterialId,
                Cantidad = dto.Cantidad,
                PrecioUnitarioMonedas = dto.PrecioUnitarioMonedas
            };
            detalle = await _detalleCompraService.CrearDetalleAsync(detalle);
            return CreatedAtAction(nameof(ObtenerDetallesDeCompra), new { compraId = dto.CompraId }, await ConvertirAsync(detalle));
        }

        private async Task<DetalleCompraResponseDto> ConvertirAsync(DetalleCompra detalle)
        {
            var dto = new DetalleCompraResponseDto
            {
                DetalleCompraId = detalle.DetalleCompraId,
                CompraId = detalle.CompraId,
                MaterialId = detalle.MaterialId,
                Cantidad = detalle.Cantidad,
                PrecioUnitarioMonedas = detalle.PrecioUnitarioMonedas
            };

            var material = await _materialService.ObtenerPorIdAsync(detalle.MaterialId);
            if (material is not null)
                dto.NombreMaterial = material.NombreMaterial;

            return dto;
        }
    }
}
