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
    public class DenunciasController : ControllerBase
    {
        private readonly IDenunciaService _denunciaService;
        private readonly IPublicacionService _publicacionService;
        private readonly IComentarioService _comentarioService;
        private readonly IUsuarioService _usuarioService;
        private readonly ISoporteService _soporteService;
        private readonly ILogger<DenunciasController> _logger;

        public DenunciasController(
            IDenunciaService denunciaService,
            IPublicacionService publicacionService,
            IComentarioService comentarioService,
            IUsuarioService usuarioService,
            ISoporteService soporteService,
            ILogger<DenunciasController> logger)
        {
            _denunciaService = denunciaService;
            _publicacionService = publicacionService;
            _comentarioService = comentarioService;
            _usuarioService = usuarioService;
            _soporteService = soporteService;
            _logger = logger;
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Crear([FromBody] CrearDenunciaRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            if (dto.PublicacionId is null && dto.ComentarioId is null)
                return BadRequest(new { mensaje = "Indica el contenido que deseas reportar." });

            if (dto.PublicacionId is int publicacionId && await _publicacionService.ObtenerPorIdAsync(publicacionId) is null)
                return NotFound(new { mensaje = "La publicacion ya no esta disponible." });

            if (dto.ComentarioId is int comentarioId && await _comentarioService.ObtenerPorIdAsync(comentarioId) is null)
                return NotFound(new { mensaje = "El comentario ya no esta disponible." });

            if (await _denunciaService.ExisteDenunciaAsync(usuarioId.Value, dto.PublicacionId, dto.ComentarioId))
                return Ok(new { mensaje = "Ya reportaste este contenido. Nuestro equipo lo revisara." });

            var denuncia = await _denunciaService.CrearAsync(new Denuncia
            {
                UsuarioId = usuarioId.Value,
                PublicacionId = dto.PublicacionId,
                ComentarioId = dto.ComentarioId,
                Motivo = dto.Motivo.Trim(),
                Descripcion = string.IsNullOrWhiteSpace(dto.Descripcion) ? null : dto.Descripcion.Trim(),
                ReporteOrigen = "APP"
            });


            try
            {
                var usuario = await _usuarioService.ObtenerPorIdAsync(usuarioId.Value);
                await _soporteService.NotificarAdminsReporteAsync(
                    denuncia.DenunciaId,
                    usuario?.NombreUsuario ?? "Un usuario",
                    denuncia.Motivo);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudo notificar el reporte {DenunciaId} a los administradores.", denuncia.DenunciaId);
            }

            return StatusCode(StatusCodes.Status201Created, new { mensaje = "Reporte enviado. Gracias por cuidar la comunidad." });
        }
    }
}
