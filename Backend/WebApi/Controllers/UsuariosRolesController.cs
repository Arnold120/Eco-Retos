using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/usuarios-roles")]
    [Authorize]
    public class UsuariosRolesController : ControllerBase
    {
        private readonly IUsuarioRolService _usuarioRolService;
        private readonly IUsuarioService _usuarioService;
        private readonly IRolService _rolService;
        private readonly ILogger<UsuariosRolesController> _logger;

        public UsuariosRolesController(
            IUsuarioRolService usuarioRolService,
            IUsuarioService usuarioService,
            IRolService rolService,
            ILogger<UsuariosRolesController> logger)
        {
            _usuarioRolService = usuarioRolService;
            _usuarioService = usuarioService;
            _rolService = rolService;
            _logger = logger;
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioRolResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerRolesDeUsuario(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var lista = new List<UsuarioRolResponseDto>();
            foreach (var ur in await _usuarioRolService.ObtenerRolesPorUsuarioAsync(usuarioId))
                lista.Add(await ConvertirAsync(ur));
            return Ok(lista);
        }

        [HttpGet("rol/{rolId:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioRolResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerUsuariosDeRol(int rolId)
        {
            if (await _rolService.ObtenerPorIdAsync(rolId) is null)
                return NotFound(new { mensaje = $"No se encontro el rol con id {rolId}." });

            var lista = new List<UsuarioRolResponseDto>();
            foreach (var ur in await _usuarioRolService.ObtenerUsuariosPorRolAsync(rolId))
                lista.Add(await ConvertirAsync(ur));
            return Ok(lista);
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(UsuarioRolResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> AsignarRol([FromBody] AsignarRolRequestDto dto)
        {
            if (await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            if (await _rolService.ObtenerPorIdAsync(dto.RolId) is null)
                return NotFound(new { mensaje = $"No se encontro el rol con id {dto.RolId}." });

            if (await _usuarioRolService.UsuarioTieneRolAsync(dto.UsuarioId, dto.RolId))
                return Conflict(new { mensaje = "El usuario ya posee ese rol." });

            var asignado = await _usuarioRolService.AsignarRolAsync(new UsuarioRol
            {
                UsuarioId = dto.UsuarioId,
                RolId = dto.RolId
            });
            return CreatedAtAction(nameof(ObtenerRolesDeUsuario), new { usuarioId = dto.UsuarioId }, await ConvertirAsync(asignado));
        }

        [HttpDelete("{usuarioId:int}/rol/{rolId:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> QuitarRol(int usuarioId, int rolId)
        {
            var ok = await _usuarioRolService.QuitarRolAsync(usuarioId, rolId);
            if (!ok)
                return NotFound(new { mensaje = "El usuario no posee ese rol o los datos son invalidos." });
            return NoContent();
        }

        private async Task<UsuarioRolResponseDto> ConvertirAsync(UsuarioRol usuarioRol)
        {
            var dto = new UsuarioRolResponseDto
            {
                UsuarioRolId = usuarioRol.UsuarioRolId,
                UsuarioId = usuarioRol.UsuarioId,
                RolId = usuarioRol.RolId
            };

            var usuario = await _usuarioService.ObtenerPorIdAsync(usuarioRol.UsuarioId);
            if (usuario is not null)
                dto.NombreUsuario = usuario.NombreUsuario;

            var rol = await _rolService.ObtenerPorIdAsync(usuarioRol.RolId);
            if (rol is not null)
                dto.NombreRol = rol.NombreRol;

            return dto;
        }
    }
}