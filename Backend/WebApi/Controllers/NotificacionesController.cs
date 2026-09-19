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
    public class NotificacionesController : ControllerBase
    {
        private readonly INotificacionService _notificacionService;
        private readonly IUsuarioService _usuarioService;
        private readonly ILogger<NotificacionesController> _logger;

        public NotificacionesController(
            INotificacionService notificacionService,
            IUsuarioService usuarioService,
            ILogger<NotificacionesController> logger)
        {
            _notificacionService = notificacionService;
            _usuarioService = usuarioService;
            _logger = logger;
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<NotificacionResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerNotificacionesDeUsuario(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var notificaciones = await _notificacionService.ObtenerNotificacionesDeUsuarioAsync(usuarioId);
            return Ok(notificaciones.Select(Convertir).ToList());
        }

        [HttpGet("usuario/{usuarioId:int}/no-leidas")]
        [ProducesResponseType(typeof(IEnumerable<NotificacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerNoLeidas(int usuarioId)
        {
            var notificaciones = await _notificacionService.ObtenerNoLeidasAsync(usuarioId);
            return Ok(notificaciones.Select(Convertir).ToList());
        }

        [HttpGet("usuario/{usuarioId:int}/no-leidas/total")]
        public async Task<IActionResult> ContarNoLeidas(int usuarioId)
        {
            var total = await _notificacionService.ContarNoLeidasAsync(usuarioId);
            return Ok(new { total });
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(NotificacionResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var notificacion = await _notificacionService.ObtenerPorIdAsync(id);
            if (notificacion is null)
                return NotFound(new { mensaje = $"No se encontro la notificacion con id {id}." });
            return Ok(Convertir(notificacion));
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(NotificacionResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Crear([FromBody] CrearNotificacionRequestDto dto)
        {
            if (await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            var notificacion = new Notificacion
            {
                UsuarioId = dto.UsuarioId,
                Titulo = dto.Titulo.Trim(),
                Mensaje = dto.Mensaje.Trim(),
                Tipo = dto.Tipo.Trim().ToUpper(),
                Leida = false,
                Fecha = DateTime.Now
            };
            notificacion = await _notificacionService.CrearNotificacionAsync(notificacion);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = notificacion.NotificacionId }, Convertir(notificacion));
        }

        [HttpPatch("{id:int}/leida")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> MarcarComoLeida(int id)
        {
            var ok = await _notificacionService.MarcarComoLeidaAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la notificacion con id {id}." });
            return Ok(new { mensaje = "Notificacion marcada como leida." });
        }

        [HttpPatch("usuario/{usuarioId:int}/leidas")]
        public async Task<IActionResult> MarcarTodasComoLeidas(int usuarioId)
        {
            var ok = await _notificacionService.MarcarTodasComoLeidasAsync(usuarioId);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });
            return Ok(new { mensaje = "Todas las notificaciones marcadas como leidas." });
        }

        [HttpDelete("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _notificacionService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la notificacion con id {id}." });
            return NoContent();
        }

        [HttpDelete("usuario/{usuarioId:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<IActionResult> EliminarTodas(int usuarioId)
        {
            await _notificacionService.EliminarTodasAsync(usuarioId);
            return NoContent();
        }

        private static NotificacionResponseDto Convertir(Notificacion notificacion)
        {
            return new NotificacionResponseDto
            {
                NotificacionId = notificacion.NotificacionId,
                UsuarioId = notificacion.UsuarioId,
                Titulo = notificacion.Titulo,
                Mensaje = notificacion.Mensaje,
                Tipo = notificacion.Tipo,
                Leida = notificacion.Leida,
                Fecha = notificacion.Fecha,
                ReferenciaTipo = notificacion.ReferenciaTipo,
                ReferenciaId = notificacion.ReferenciaId,
                ActorUsuarioId = notificacion.ActorUsuarioId
            };
        }
    }
}