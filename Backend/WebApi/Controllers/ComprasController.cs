using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ComprasController : ControllerBase
    {
        private readonly ICompraService _compraService;
        private readonly IUsuarioService _usuarioService;
        private readonly ILogger<ComprasController> _logger;

        public ComprasController(
            ICompraService compraService,
            IUsuarioService usuarioService,
            ILogger<ComprasController> logger)
        {
            _compraService = compraService;
            _usuarioService = usuarioService;
            _logger = logger;
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<CompraResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerComprasDeUsuario(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var compras = await _compraService.ObtenerComprasDeUsuarioAsync(usuarioId);
            return Ok(compras.Select(Convertir).ToList());
        }

        [HttpGet("usuario/{usuarioId:int}/recientes/{cantidad:int}")]
        public async Task<IActionResult> ObtenerRecientes(int usuarioId, int cantidad)
        {
            var compras = await _compraService.ObtenerRecientesAsync(usuarioId, cantidad);
            return Ok(compras.Select(Convertir).ToList());
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(CompraResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var compra = await _compraService.ObtenerPorIdAsync(id);
            if (compra is null)
                return NotFound(new { mensaje = $"No se encontro la compra con id {id}." });
            return Ok(Convertir(compra));
        }

        /// <summary>
        /// Compra transaccional: valida stock y saldo en el servidor, cobra del
        /// Monedero, crea Compra + DetalleCompra, actualiza Inventario y registra
        /// el movimiento en HistorialMonedas. Todo o nada.
        /// El UsuarioId sale del token JWT, nunca del cuerpo.
        /// </summary>
        [HttpPost]
        [ProducesResponseType(typeof(CompraResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Crear([FromBody] CrearCompraRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null)
                return Unauthorized(new { mensaje = "Token inválido o sin usuario." });

            if (dto.Detalles is null || dto.Detalles.Count == 0)
                return BadRequest(new { mensaje = "La compra debe incluir al menos un detalle." });

            var solicitados = dto.Detalles.Select(d => new DetalleCompraSolicitado
            {
                MaterialId = d.MaterialId,
                Cantidad = d.Cantidad
            });

            var resultado = await _compraService.CrearCompraCompletaAsync(
                usuarioId.Value, solicitados, dto.ClaveIdempotencia);

            if (!resultado.Exito || resultado.Compra is null)
                return BadRequest(new { mensaje = resultado.Mensaje ?? "No se pudo completar la compra." });

            var respuesta = Convertir(resultado.Compra);
            respuesta.SaldoRestante = resultado.Saldo;
            respuesta.Detalles = resultado.Detalles.Select(d => new DetalleCompraResponseDto
            {
                DetalleCompraId = d.DetalleCompraId,
                CompraId = d.CompraId,
                MaterialId = d.MaterialId,
                Cantidad = d.Cantidad,
                PrecioUnitarioMonedas = d.PrecioUnitarioMonedas
            }).ToList();

            return CreatedAtAction(nameof(ObtenerPorId), new { id = resultado.Compra.CompraId }, respuesta);
        }

        private static CompraResponseDto Convertir(Compra compra)
        {
            return new CompraResponseDto
            {
                CompraId = compra.CompraId,
                UsuarioId = compra.UsuarioId,
                TotalMonedas = compra.TotalMonedas,
                FechaCompra = compra.FechaCompra,
                ClaveIdempotencia = compra.ClaveIdempotencia
            };
        }
    }
}
