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
    public class AuthController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;
        private readonly IPerfilService _perfilService;
        private readonly IRolService _rolService;
        private readonly IUsuarioRolService _usuarioRolService;
        private readonly IProgresoService _progresoService;
        private readonly IJardinService _jardinService;
        private readonly IMonederoService _monederoService;
        private readonly ITokenService _tokenService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            IUsuarioService usuarioService,
            IPerfilService perfilService,
            IRolService rolService,
            IUsuarioRolService usuarioRolService,
            IProgresoService progresoService,
            IJardinService jardinService,
            IMonederoService monederoService,
            ITokenService tokenService,
            ILogger<AuthController> logger)
        {
            _usuarioService = usuarioService;
            _perfilService = perfilService;
            _rolService = rolService;
            _usuarioRolService = usuarioRolService;
            _progresoService = progresoService;
            _jardinService = jardinService;
            _monederoService = monederoService;
            _tokenService = tokenService;
            _logger = logger;
        }

        [HttpPost("registrar")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> Registrar([FromBody] RegistroRequestDto registro)
        {
            try
            {
                if (await _usuarioService.ExisteCorreoAsync(registro.Correo.Trim().ToLower()))
                    return Conflict(new { mensaje = "El correo ya esta registrado." });

                if (await _usuarioService.ExisteNombreUsuarioAsync(registro.NombreUsuario.Trim()))
                    return Conflict(new { mensaje = "El nombre de usuario ya esta en uso." });

                var usuario = new Usuario
                {
                    NombreUsuario = registro.NombreUsuario.Trim(),
                    Correo = registro.Correo.Trim().ToLower(),
                    Contrasena = registro.Contrasena,
                    Activo = true,
                    FechaRegistro = DateTime.Now
                };
                usuario = await _usuarioService.CrearAsync(usuario);

                var perfil = new Perfil
                {
                    UsuarioId = usuario.UsuarioId,
                    Nombre = registro.Nombre?.Trim() ?? string.Empty,
                    Apellido = registro.Apellido?.Trim() ?? string.Empty,
                    Carnet = registro.Carnet?.Trim() ?? string.Empty,
                    CentroEducativo = registro.CentroEducativo?.Trim() ?? string.Empty,
                    Grado = registro.Grado?.Trim() ?? string.Empty,
                    FotoPerfil = registro.FotoPerfil
                };
                await _perfilService.CrearAsync(perfil);

                var rolEstudiante = await _rolService.ObtenerPorNombreAsync("ESTUDIANTE");
                var rolId = rolEstudiante?.RolId ?? 1;
                await _usuarioRolService.AsignarRolAsync(new UsuarioRol { UsuarioId = usuario.UsuarioId, RolId = rolId });

                await _progresoService.CrearProgresoAsync(new Progreso { UsuarioId = usuario.UsuarioId });
                await _jardinService.CrearJardinAsync(new Jardin { UsuarioId = usuario.UsuarioId });
                await _monederoService.CrearMonederoAsync(usuario.UsuarioId);

                var respuesta = await GenerarRespuestaAutenticacionAsync(usuario);
                return Ok(respuesta);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al registrar el usuario.");
                return StatusCode(StatusCodes.Status500InternalServerError, new { mensaje = "Ocurrio un error al registrar el usuario." });
            }
        }

        [HttpPost("login")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto login)
        {
            var usuario = await _usuarioService.AutenticarAsync(login.Correo.Trim().ToLower(), login.Contrasena);
            if (usuario is null)
                return Unauthorized(new { mensaje = "Credenciales incorrectas o usuario inactivo." });

            var respuesta = await GenerarRespuestaAutenticacionAsync(usuario);
            return Ok(respuesta);
        }

        private async Task<AuthResponseDto> GenerarRespuestaAutenticacionAsync(Usuario usuario)
        {
            var roles = await ObtenerRolesAsync(usuario.UsuarioId);
            var (token, expiraEn) = _tokenService.GenerarToken(usuario.UsuarioId, usuario.NombreUsuario, usuario.Correo, roles);

            return new AuthResponseDto
            {
                Token = token,
                ExpiraEn = expiraEn,
                Usuario = new UsuarioResponseDto
                {
                    UsuarioId = usuario.UsuarioId,
                    NombreUsuario = usuario.NombreUsuario,
                    Correo = usuario.Correo,
                    Activo = usuario.Activo,
                    FechaRegistro = usuario.FechaRegistro,
                    Roles = roles
                }
            };
        }

        private async Task<List<string>> ObtenerRolesAsync(int usuarioId)
        {
            var roles = new List<string>();
            var usuarioRoles = await _usuarioRolService.ObtenerRolesPorUsuarioAsync(usuarioId);
            foreach (var ur in usuarioRoles)
            {
                var rol = await _rolService.ObtenerPorIdAsync(ur.RolId);
                if (rol is not null && !roles.Contains(rol.NombreRol))
                    roles.Add(rol.NombreRol);
            }
            return roles;
        }
    }
}