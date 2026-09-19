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
    public class SeguimientosController : ControllerBase
    {
        private readonly ISeguimientoService _seguimientoService;
        private readonly IUsuarioService _usuarioService;
        private readonly IPerfilService _perfilService;

        public SeguimientosController(
            ISeguimientoService seguimientoService,
            IUsuarioService usuarioService,
            IPerfilService perfilService)
        {
            _seguimientoService = seguimientoService;
            _usuarioService = usuarioService;
            _perfilService = perfilService;
        }

        private async Task<List<UsuarioResumenDto>> MapearUsuariosAsync(
            IEnumerable<int> ids)
        {
            var usuarios = await _usuarioService.ObtenerPorIdsAsync(ids);
            var perfiles = await _perfilService.ObtenerPorUsuariosAsync(
                usuarios.Keys);
            return usuarios.Values
                .Select(u => new UsuarioResumenDto
                {
                    UsuarioId = u.UsuarioId,
                    NombreUsuario = u.NombreUsuario,
                    FotoPerfil = perfiles.TryGetValue(u.UsuarioId, out var p)
                        ? p.FotoPerfil
                        : null
                })
                .OrderBy(u => u.NombreUsuario)
                .ToList();
        }


        [HttpGet("estado/{usuarioId:int}")]
        [ProducesResponseType(typeof(SeguimientoEstadoDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerEstado(int usuarioId)
        {
            var espectadorId = User.ObtenerUsuarioId();
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            return Ok(new SeguimientoEstadoDto
            {
                UsuarioId = usuarioId,
                Siguiendo = espectadorId is int id && await _seguimientoService.EstaSiguiendoAsync(id, usuarioId),
                Seguidores = await _seguimientoService.ContarSeguidoresAsync(usuarioId),
                Seguidos = await _seguimientoService.ContarSeguidosAsync(usuarioId)
            });
        }


        [HttpGet("ids")]
        [ProducesResponseType(typeof(IEnumerable<int>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerIdsSeguidos()
        {
            var espectadorId = User.ObtenerUsuarioId();
            if (espectadorId is null) return Unauthorized();
            return Ok(await _seguimientoService.ObtenerIdsSeguidosAsync(espectadorId.Value));
        }

        [HttpGet("seguidores/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioResumenDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerSeguidores(int usuarioId)
        {
            var ids = await _seguimientoService.ObtenerIdsSeguidoresAsync(usuarioId);
            return Ok(await MapearUsuariosAsync(ids));
        }

        [HttpGet("siguiendo/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioResumenDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerSiguiendo(int usuarioId)
        {
            var ids = await _seguimientoService.ObtenerIdsSeguidosAsync(usuarioId);
            return Ok(await MapearUsuariosAsync(ids));
        }

        [HttpPost("{usuarioId:int}")]
        [ProducesResponseType(typeof(SeguimientoEstadoDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Seguir(int usuarioId)
        {
            var espectadorId = User.ObtenerUsuarioId();
            if (espectadorId is null) return Unauthorized();

            if (espectadorId.Value == usuarioId)
                return BadRequest(new { mensaje = "No puedes seguirte a ti mismo." });

            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            await _seguimientoService.SeguirAsync(espectadorId.Value, usuarioId);
            return Ok(await EstadoAsync(espectadorId.Value, usuarioId));
        }

        [HttpDelete("{usuarioId:int}")]
        [ProducesResponseType(typeof(SeguimientoEstadoDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DejarDeSeguir(int usuarioId)
        {
            var espectadorId = User.ObtenerUsuarioId();
            if (espectadorId is null) return Unauthorized();

            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            await _seguimientoService.DejarDeSeguirAsync(espectadorId.Value, usuarioId);
            return Ok(await EstadoAsync(espectadorId.Value, usuarioId));
        }

        private async Task<SeguimientoEstadoDto> EstadoAsync(int espectadorId, int usuarioId)
        {
            return new SeguimientoEstadoDto
            {
                UsuarioId = usuarioId,
                Siguiendo = await _seguimientoService.EstaSiguiendoAsync(espectadorId, usuarioId),
                Seguidores = await _seguimientoService.ContarSeguidoresAsync(usuarioId),
                Seguidos = await _seguimientoService.ContarSeguidosAsync(usuarioId)
            };
        }
    }
}
