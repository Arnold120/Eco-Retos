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
    public class UsuariosController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;
        private readonly IUsuarioRolService _usuarioRolService;
        private readonly IRolService _rolService;
        private readonly IMonederoService _monederoService;
        private readonly ILogger<UsuariosController> _logger;

        public UsuariosController(
            IUsuarioService usuarioService,
            IUsuarioRolService usuarioRolService,
            IRolService rolService,
            IMonederoService monederoService,
            ILogger<UsuariosController> logger)
        {
            _usuarioService = usuarioService;
            _usuarioRolService = usuarioRolService;
            _rolService = rolService;
            _monederoService = monederoService;
            _logger = logger;
        }

        [HttpGet]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodos()
        {
            var usuarios = await _usuarioService.ObtenerTodosAsync();
            var dtos = new List<UsuarioResponseDto>();
            foreach (var u in usuarios)
                dtos.Add(await ConvertirAsync(u));
            return Ok(dtos);
        }

        [HttpGet("activos")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerActivos()
        {
            var usuarios = await _usuarioService.ObtenerActivosAsync();
            var dtos = new List<UsuarioResponseDto>();
            foreach (var u in usuarios)
                dtos.Add(await ConvertirAsync(u));
            return Ok(dtos);
        }

        [HttpGet("inactivos")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerInactivos()
        {
            var usuarios = await _usuarioService.ObtenerInactivosAsync();
            var dtos = new List<UsuarioResponseDto>();
            foreach (var u in usuarios)
                dtos.Add(await ConvertirAsync(u));
            return Ok(dtos);
        }

        [HttpGet("totales")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> ObtenerTotales()
        {
            var total = await _usuarioService.ObtenerTotalAsync();
            var activos = await _usuarioService.ObtenerTotalActivosAsync();
            return Ok(new { total, activos, inactivos = total - activos });
        }

        [HttpGet("{id:int}", Name = "ObtenerUsuario")]
        [ProducesResponseType(typeof(UsuarioResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var usuario = await _usuarioService.ObtenerPorIdAsync(id);
            if (usuario is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {id}." });
            return Ok(await ConvertirAsync(usuario));
        }

        [HttpGet("correo/{correo}")]
        [ProducesResponseType(typeof(UsuarioResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorCorreo(string correo)
        {
            var usuario = await _usuarioService.ObtenerPorCorreoAsync(correo.Trim().ToLower());
            if (usuario is null)
                return NotFound(new { mensaje = "No se encontro el usuario con el correo indicado." });
            return Ok(await ConvertirAsync(usuario));
        }

        [HttpGet("nombreusuario/{nombre}")]
        [ProducesResponseType(typeof(UsuarioResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorNombreUsuario(string nombre)
        {
            var usuario = await _usuarioService.ObtenerPorNombreUsuarioAsync(nombre.Trim());
            if (usuario is null)
                return NotFound(new { mensaje = "No se encontro el nombre de usuario indicado." });
            return Ok(await ConvertirAsync(usuario));
        }

        [HttpPost]
        // [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(UsuarioResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> Crear([FromBody] CrearUsuarioRequestDto dto)
        {
            if (await _usuarioService.ExisteCorreoAsync(dto.Correo.Trim().ToLower()))
                return Conflict(new { mensaje = "El correo ya esta registrado." });

            if (await _usuarioService.ExisteNombreUsuarioAsync(dto.NombreUsuario.Trim()))
                return Conflict(new { mensaje = "El nombre de usuario ya esta en uso." });

            var usuario = new Usuario
            {
                NombreUsuario = dto.NombreUsuario.Trim(),
                Correo = dto.Correo.Trim().ToLower(),
                Contrasena = dto.Contrasena,
                Activo = true,
                FechaRegistro = DateTime.Now
            };
            usuario = await _usuarioService.CrearAsync(usuario);
            await _monederoService.CrearMonederoAsync(usuario.UsuarioId);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = usuario.UsuarioId }, await ConvertirAsync(usuario));
        }

        [HttpPut("{id:int}")]
        [ProducesResponseType(typeof(UsuarioResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarUsuarioRequestDto dto)
        {
            // Solo el propio usuario (o un administrador) puede editar la cuenta.
            var autenticadoId = User.ObtenerUsuarioId();
            if (autenticadoId is null)
                return Unauthorized();
            if (autenticadoId.Value != id && !User.IsInRole("ADMIN"))
                return StatusCode(StatusCodes.Status403Forbidden,
                    new { mensaje = "No puedes editar la cuenta de otro usuario." });

            var usuario = await _usuarioService.ObtenerPorIdAsync(id);
            if (usuario is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {id}." });

            if (await _usuarioService.ExisteNombreUsuarioAsync(dto.NombreUsuario.Trim()) &&
                !string.Equals(usuario.NombreUsuario, dto.NombreUsuario.Trim(),
                    StringComparison.OrdinalIgnoreCase))
                return Conflict(new { mensaje = "El nombre de usuario ya esta en uso." });

            if (await _usuarioService.ExisteCorreoAsync(dto.Correo.Trim().ToLower()) &&
                !string.Equals(usuario.Correo, dto.Correo.Trim().ToLower(),
                    StringComparison.OrdinalIgnoreCase))
                return Conflict(new { mensaje = "El correo ya esta registrado." });

            usuario.NombreUsuario = dto.NombreUsuario.Trim();
            usuario.Correo = dto.Correo.Trim().ToLower();

            var actualizado = await _usuarioService.ActualizarAsync(usuario);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {id}." });

            return Ok(await ConvertirAsync(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _usuarioService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {id}." });
            return NoContent();
        }

        [HttpPost("{id:int}/activar")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> Activar(int id)
        {
            var ok = await _usuarioService.ActivarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {id}." });
            return Ok(new { mensaje = "Usuario activado correctamente." });
        }

        [HttpPost("{id:int}/desactivar")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> Desactivar(int id)
        {
            var ok = await _usuarioService.DesactivarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {id}." });
            return Ok(new { mensaje = "Usuario desactivado correctamente." });
        }

        [HttpPatch("{id:int}/estado")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> CambiarEstado(int id, [FromBody] CambiarEstadoUsuarioRequestDto dto)
        {
            var usuario = await _usuarioService.ObtenerPorIdAsync(id);
            if (usuario is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {id}." });

            usuario.Activo = dto.Activo;
            var actualizado = await _usuarioService.ActualizarAsync(usuario);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {id}." });

            return Ok(await ConvertirAsync(actualizado));
        }

        [HttpPatch("{id:int}/contrasena")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> CambiarContrasena(int id, [FromBody] CambiarContrasenaRequestDto dto)
        {
            var autenticadoId = User.ObtenerUsuarioId();
            if (autenticadoId is null)
                return Unauthorized();
            if (autenticadoId.Value != id && !User.IsInRole("ADMIN"))
                return StatusCode(StatusCodes.Status403Forbidden,
                    new { mensaje = "No puedes cambiar la contrasena de otro usuario." });

            if (await _usuarioService.ObtenerPorIdAsync(id) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {id}." });

            if (string.CompareOrdinal(dto.ContrasenaActual, dto.NuevaContrasena) == 0)
                return BadRequest(new { mensaje = "La nueva contrasena debe ser diferente a la actual." });

            var ok = await _usuarioService.CambiarContrasenaAsync(id, dto.ContrasenaActual, dto.NuevaContrasena);
            if (!ok)
                return BadRequest(new { mensaje = "La contrasena actual es incorrecta." });

            return Ok(new { mensaje = "Contrasena actualizada correctamente." });
        }

        /// <summary>
        /// Desactiva la propia cuenta. Exige la contrasena actual como
        /// confirmacion; el usuario puede reactivarla contactando soporte.
        /// </summary>
        [HttpPost("mi-cuenta/desactivar")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> DesactivarMiCuenta([FromBody] DesactivarCuentaRequestDto dto)
        {
            var autenticadoId = User.ObtenerUsuarioId();
            if (autenticadoId is null)
                return Unauthorized();

            var usuario = await _usuarioService.ObtenerPorIdAsync(autenticadoId.Value);
            if (usuario is null)
                return NotFound(new { mensaje = "No se encontro el usuario autenticado." });

            var valido = await _usuarioService.AutenticarAsync(usuario.Correo, dto.Contrasena);
            if (valido is null)
                return BadRequest(new { mensaje = "La contrasena es incorrecta." });

            await _usuarioService.DesactivarAsync(autenticadoId.Value);
            return Ok(new { mensaje = "Cuenta desactivada correctamente." });
        }

        private async Task<UsuarioResponseDto> ConvertirAsync(Usuario usuario)
        {
            var roles = new List<string>();
            var usuarioRoles = await _usuarioRolService.ObtenerRolesPorUsuarioAsync(usuario.UsuarioId);
            foreach (var ur in usuarioRoles)
            {
                var rol = await _rolService.ObtenerPorIdAsync(ur.RolId);
                if (rol is not null && !roles.Contains(rol.NombreRol))
                    roles.Add(rol.NombreRol);
            }

            return new UsuarioResponseDto
            {
                UsuarioId = usuario.UsuarioId,
                NombreUsuario = usuario.NombreUsuario,
                Correo = usuario.Correo,
                Activo = usuario.Activo,
                FechaRegistro = usuario.FechaRegistro,
                Roles = roles
            };
        }
    }
}