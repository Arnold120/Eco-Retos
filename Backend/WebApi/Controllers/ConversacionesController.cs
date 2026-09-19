using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Helpers;
using WebApi.Interfaz;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ConversacionesController : ControllerBase
    {
        private readonly IMensajeService _mensajeService;
        private readonly IUsuarioService _usuarioService;
        private readonly IPerfilService _perfilService;

        public ConversacionesController(
            IMensajeService mensajeService,
            IUsuarioService usuarioService,
            IPerfilService perfilService)
        {
            _mensajeService = mensajeService;
            _usuarioService = usuarioService;
            _perfilService = perfilService;
        }

        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<ConversacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerConversaciones()
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            var resumenes = await _mensajeService.ObtenerConversacionesAsync(usuarioId.Value);
            var usuarioIds = resumenes.Select(r => r.OtroUsuario.UsuarioId).ToList();
            var perfiles = await _perfilService.ObtenerPorUsuariosAsync(usuarioIds);

            return Ok(resumenes.Select(r => new ConversacionResponseDto
            {
                ConversacionId = r.Conversacion.ConversacionId,
                OtroUsuarioId = r.OtroUsuario.UsuarioId,
                OtroNombreUsuario = r.OtroUsuario.NombreUsuario,
                OtroFotoPerfil = perfiles.TryGetValue(r.OtroUsuario.UsuarioId, out var p) ? p.FotoPerfil : null,
                UltimoMensaje = r.UltimoMensaje,
                FechaUltimoMensaje = r.FechaUltimoMensaje,
                NoLeidos = r.NoLeidos
            }).ToList());
        }

        [HttpGet("no-leidos/total")]
        public async Task<IActionResult> ContarNoLeidos()
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();
            var total = await _mensajeService.ContarNoLeidosAsync(usuarioId.Value);
            return Ok(new { total });
        }


        [HttpPost]
        [ProducesResponseType(typeof(ConversacionResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Abrir([FromBody] CrearConversacionRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            if (dto.UsuarioId == usuarioId.Value)
                return BadRequest(new { mensaje = "No puedes iniciar una conversacion contigo mismo." });

            var otro = await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId);
            if (otro is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            var conversacionId = await _mensajeService.ObtenerOCrearConversacionAsync(usuarioId.Value, dto.UsuarioId);
            var perfil = await _perfilService.ObtenerPerfilPorUsuarioAsync(dto.UsuarioId);

            return Ok(new ConversacionResponseDto
            {
                ConversacionId = conversacionId,
                OtroUsuarioId = otro.UsuarioId,
                OtroNombreUsuario = otro.NombreUsuario,
                OtroFotoPerfil = perfil?.FotoPerfil,
                NoLeidos = 0
            });
        }

        [HttpGet("{conversacionId:int}/mensajes")]
        [ProducesResponseType(typeof(IEnumerable<MensajeResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerMensajes(
            int conversacionId,
            [FromQuery] int? antesDe = null,
            [FromQuery] int limite = 40)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            if (!await _mensajeService.EsParticipanteAsync(conversacionId, usuarioId.Value))
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No participas en esta conversacion." });

            var mensajes = await _mensajeService.ObtenerMensajesAsync(conversacionId, antesDe, limite);
            return Ok(mensajes.Select(m => new MensajeResponseDto
            {
                MensajeId = m.MensajeId,
                ConversacionId = m.ConversacionId,
                RemitenteId = m.RemitenteId,
                Contenido = m.Contenido,
                Fecha = m.Fecha,
                Leido = m.Leido
            }).ToList());
        }

        [HttpPost("{conversacionId:int}/mensajes")]
        [ProducesResponseType(typeof(MensajeResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> EnviarMensaje(int conversacionId, [FromBody] EnviarMensajeRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            if (!await _mensajeService.EsParticipanteAsync(conversacionId, usuarioId.Value))
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No participas en esta conversacion." });

            if (string.IsNullOrWhiteSpace(dto.Contenido))
                return BadRequest(new { mensaje = "El mensaje no puede estar vacio." });

            var mensaje = await _mensajeService.EnviarMensajeAsync(conversacionId, usuarioId.Value, dto.Contenido);
            return StatusCode(StatusCodes.Status201Created, new MensajeResponseDto
            {
                MensajeId = mensaje.MensajeId,
                ConversacionId = mensaje.ConversacionId,
                RemitenteId = mensaje.RemitenteId,
                Contenido = mensaje.Contenido,
                Fecha = mensaje.Fecha,
                Leido = mensaje.Leido
            });
        }

        [HttpPost("{conversacionId:int}/leidos")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> MarcarLeidos(int conversacionId)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            if (!await _mensajeService.EsParticipanteAsync(conversacionId, usuarioId.Value))
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No participas en esta conversacion." });

            await _mensajeService.MarcarLeidosAsync(conversacionId, usuarioId.Value);
            return Ok(new { mensaje = "Conversacion marcada como leida." });
        }
    }
}
