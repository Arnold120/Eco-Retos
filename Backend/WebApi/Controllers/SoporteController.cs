using System.Security.Cryptography;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using WebApi.Dto;
using WebApi.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    /// <summary>
    /// Módulo de soporte asistido por IA (aditivo).
    /// - Rutas de usuario: requieren JWT (cualquier rol).
    /// - Rutas admin: requieren rol ADMIN validado por el backend.
    /// - El código de sesión permite abrir la web desde Flutter sin exponer el JWT.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class SoporteController : ControllerBase
    {
        private readonly ISoporteService _soporte;
        private readonly IAuditoriaService _auditoria;
        private readonly IUsuarioService _usuarioService;
        private readonly IUsuarioRolService _usuarioRolService;
        private readonly IRolService _rolService;
        private readonly ITokenService _tokenService;
        private readonly IMemoryCache _cache;
        private readonly ILogger<SoporteController> _logger;

        private const int SegundosCodigoSesion = 90;

        public SoporteController(
            ISoporteService soporte,
            IAuditoriaService auditoria,
            IUsuarioService usuarioService,
            IUsuarioRolService usuarioRolService,
            IRolService rolService,
            ITokenService tokenService,
            IMemoryCache cache,
            ILogger<SoporteController> logger)
        {
            _soporte = soporte;
            _auditoria = auditoria;
            _usuarioService = usuarioService;
            _usuarioRolService = usuarioRolService;
            _rolService = rolService;
            _tokenService = tokenService;
            _cache = cache;
            _logger = logger;
        }

        private int? UsuarioActual => User.ObtenerUsuarioId();
        private string NombreActual => User.Identity?.Name ?? "Admin";

        /* ─── Sesión desde Flutter (código de un solo uso) ─────────────────── */

        /// <summary>Crea un código de un solo uso (90 s) para abrir la web sin exponer el JWT.</summary>
        [HttpPost("sesion/codigo")]
        public IActionResult CrearCodigoSesion()
        {
            var usuarioId = UsuarioActual;
            if (usuarioId is null) return Unauthorized();

            var codigo = GenerarCodigo();
            _cache.Set($"soporte_codigo_{codigo}", usuarioId.Value, TimeSpan.FromSeconds(SegundosCodigoSesion));
            return Ok(new CodigoSesionResponseDto { Codigo = codigo, ExpiraEnSegundos = SegundosCodigoSesion });
        }

        /// <summary>Canjea el código por un JWT nuevo. Un solo uso y expira en 90 s.</summary>
        [HttpPost("sesion/canjear")]
        [AllowAnonymous]
        public async Task<IActionResult> CanjearCodigo([FromBody] CanjearCodigoRequestDto dto)
        {
            var codigo = (dto?.Codigo ?? string.Empty).Trim();
            if (codigo.Length == 0) return Unauthorized(new { mensaje = "Código inválido o expirado." });

            var clave = $"soporte_codigo_{codigo}";
            if (!_cache.TryGetValue(clave, out int usuarioId))
                return Unauthorized(new { mensaje = "El código es inválido o expiró. Vuelve a abrir el soporte desde la app." });

            _cache.Remove(clave);

            var usuario = await _usuarioService.ObtenerPorIdAsync(usuarioId);
            if (usuario is null || !usuario.Activo)
                return Unauthorized(new { mensaje = "Credenciales incorrectas o usuario inactivo." });

            var roles = await ObtenerRolesAsync(usuario.UsuarioId);
            var (token, expiraEn) = _tokenService.GenerarToken(usuario.UsuarioId, usuario.NombreUsuario, usuario.Correo, roles);

            return Ok(new AuthResponseDto
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
            });
        }

        private async Task<List<string>> ObtenerRolesAsync(int usuarioId)
        {
            var roles = new List<string>();
            var asignados = await _usuarioRolService.ObtenerRolesPorUsuarioAsync(usuarioId);
            foreach (var ur in asignados)
            {
                var rol = await _rolService.ObtenerPorIdAsync(ur.RolId);
                if (rol is not null && !roles.Contains(rol.NombreRol)) roles.Add(rol.NombreRol);
            }
            return roles;
        }

        private static string GenerarCodigo()
        {
            return Convert.ToBase64String(RandomNumberGenerator.GetBytes(32))
                .Replace("+", "-").Replace("/", "_").TrimEnd('=');
        }

        /* ─── Configuración de soporte ─────────────────────────────────────── */

        [HttpGet("config")]
        public async Task<IActionResult> ObtenerConfig() => Ok(await _soporte.ObtenerConfigAsync());

        [HttpPatch("config")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> GuardarConfig([FromBody] GuardarConfigRequestDto dto)
        {
            await _soporte.GuardarConfigAsync(dto, UsuarioActual!.Value, NombreActual);
            return Ok(await _soporte.ObtenerConfigAsync());
        }

        /* ─── Casos (usuario) ──────────────────────────────────────────────── */

        [HttpPost("casos")]
        public async Task<IActionResult> CrearCaso([FromBody] CrearCasoRequestDto dto)
        {
            var usuarioId = UsuarioActual;
            if (usuarioId is null) return Unauthorized();
            try
            {
                var caso = await _soporte.CrearCasoAsync(usuarioId.Value, NombreActual, dto);
                return StatusCode(201, caso);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        [HttpGet("casos/mios")]
        public async Task<IActionResult> CasosMios()
        {
            var usuarioId = UsuarioActual;
            if (usuarioId is null) return Unauthorized();
            return Ok(await _soporte.ObtenerCasosUsuarioAsync(usuarioId.Value));
        }

        [HttpGet("casos/{id:int}")]
        public async Task<IActionResult> ObtenerCaso(int id)
        {
            var caso = await _soporte.ObtenerCasoAsync(id);
            if (caso is null) return NotFound(new { mensaje = "Caso no encontrado." });
            if (!User.IsInRole("ADMIN") && caso.UsuarioId != UsuarioActual)
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No tienes acceso a este caso." });
            return Ok(caso);
        }

        [HttpGet("casos/{id:int}/mensajes")]
        public async Task<IActionResult> ObtenerMensajes(int id)
        {
            var caso = await _soporte.ObtenerCasoAsync(id);
            if (caso is null) return NotFound(new { mensaje = "Caso no encontrado." });
            if (!User.IsInRole("ADMIN") && caso.UsuarioId != UsuarioActual)
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No tienes acceso a este caso." });
            return Ok(await _soporte.ObtenerMensajesAsync(id));
        }

        [HttpPost("casos/{id:int}/mensajes")]
        public async Task<IActionResult> EnviarMensaje(int id, [FromBody] EnviarMensajeSoporteRequestDto dto)
        {
            var caso = await _soporte.ObtenerCasoAsync(id);
            if (caso is null) return NotFound(new { mensaje = "Caso no encontrado." });
            if (caso.UsuarioId != UsuarioActual)
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No tienes acceso a este caso." });
            try
            {
                return Ok(await _soporte.AgregarMensajeUsuarioAsync(id, UsuarioActual!.Value, dto));
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        [HttpPost("casos/{id:int}/leidos")]
        public async Task<IActionResult> MarcarLeidos(int id)
        {
            var caso = await _soporte.ObtenerCasoAsync(id);
            if (caso is null) return NotFound(new { mensaje = "Caso no encontrado." });
            var esAdmin = User.IsInRole("ADMIN");
            if (!esAdmin && caso.UsuarioId != UsuarioActual)
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No tienes acceso a este caso." });
            await _soporte.MarcarLeidosAsync(id, esAdmin);
            return Ok(new { mensaje = "Mensajes marcados como leídos." });
        }

        /* ─── Casos (admin) ───────────────────────────────────────────────── */

        [HttpGet("admin/casos")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> CasosAdmin(
            [FromQuery] string? estado, [FromQuery] string? prioridad,
            [FromQuery] string? categoria, [FromQuery] string? q)
            => Ok(await _soporte.ObtenerCasosAdminAsync(estado, prioridad, categoria, q));

        [HttpGet("admin/casos/{id:int}")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> CasoAdmin(int id)
        {
            var caso = await _soporte.ObtenerCasoAsync(id);
            return caso is null ? NotFound(new { mensaje = "Caso no encontrado." }) : Ok(caso);
        }

        [HttpPatch("admin/casos/{id:int}")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> ActualizarCaso(int id, [FromBody] ActualizarCasoAdminRequestDto dto)
        {
            var caso = await _soporte.ActualizarCasoAdminAsync(id, dto, UsuarioActual!.Value, NombreActual);
            return caso is null ? NotFound(new { mensaje = "Caso no encontrado." }) : Ok(caso);
        }

        [HttpGet("admin/dashboard")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> Dashboard() => Ok(await _soporte.ObtenerDashboardAsync());

        /// <summary>Resumen ligero para la actualización automática del panel.</summary>
        [HttpGet("admin/resumen")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> Resumen() => Ok(await _soporte.ObtenerResumenAdminAsync());

        /* ─── Reportes y moderación ────────────────────────────────────────── */

        [HttpGet("reportes")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> Reportes([FromQuery] string? estado)
            => Ok(await _soporte.ObtenerReportesAsync(estado));

        [HttpGet("reportes/{id:int}")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> ObtenerReporte(int id)
        {
            var reporte = await _soporte.ObtenerReporteAsync(id);
            return reporte is null ? NotFound(new { mensaje = "Reporte no encontrado." }) : Ok(reporte);
        }

        [HttpPatch("reportes/{id:int}")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> ActualizarReporte(int id, [FromBody] ActualizarReporteRequestDto dto)
        {
            var ok = await _soporte.ActualizarReporteAsync(id, dto, UsuarioActual!.Value, NombreActual);
            return ok ? Ok(new { mensaje = "Reporte actualizado." }) : NotFound(new { mensaje = "Reporte no encontrado." });
        }

        /// <summary>
        /// Análisis de IA del reporte (recomendación). No aplica acciones:
        /// la decisión final es del administrador.
        /// </summary>
        [HttpPost("reportes/{id:int}/analizar")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> AnalizarReporte(int id)
        {
            var analisis = await _soporte.AnalizarReporteAsync(id);
            return analisis is null ? NotFound(new { mensaje = "Reporte no encontrado." }) : Ok(analisis);
        }

        [HttpPost("moderacion/contenido")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> ModerarContenido([FromBody] ModerarContenidoRequestDto dto)
        {
            var ok = await _soporte.ModerarContenidoAsync(dto, UsuarioActual!.Value, NombreActual);
            return ok
                ? Ok(new { mensaje = "Acción de moderación aplicada y auditada." })
                : BadRequest(new { mensaje = "No se pudo aplicar la acción (objetivo/acción inválidos o contenido inexistente)." });
        }

        /* ─── Evidencias de retos ──────────────────────────────────────────── */

        [HttpGet("evidencias")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> Evidencias([FromQuery] string? estado)
            => Ok(await _soporte.ObtenerEvidenciasAsync(estado));

        [HttpGet("evidencias/{id:int}")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> ObtenerEvidencia(int id)
        {
            var evidencia = await _soporte.ObtenerEvidenciaAsync(id);
            return evidencia is null ? NotFound(new { mensaje = "Evidencia no encontrada." }) : Ok(evidencia);
        }

        /// <summary>
        /// Evalúa la evidencia con IA y guarda el resultado en auditoría.
        /// No aprueba ni rechaza: el administrador conserva la decisión final.
        /// </summary>
        [HttpPost("evidencias/{id:int}/analizar")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> AnalizarEvidencia(int id)
        {
            var evaluacion = await _soporte.AnalizarEvidenciaAsync(id);
            return evaluacion is null ? NotFound(new { mensaje = "Evidencia no encontrada." }) : Ok(evaluacion);
        }

        [HttpPatch("evidencias/{id:int}")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> DecidirEvidencia(int id, [FromBody] DecidirEvidenciaRequestDto dto)
        {
            var ok = await _soporte.DecidirEvidenciaAsync(id, dto, UsuarioActual!.Value, NombreActual);
            return ok ? Ok(new { mensaje = "Evidencia actualizada." }) : BadRequest(new { mensaje = "No se pudo actualizar la evidencia." });
        }

        /* ─── Administradores ──────────────────────────────────────────────── */

        [HttpGet("admins")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> Admins() => Ok(await _soporte.ObtenerAdminsAsync());

        [HttpPost("admins")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> CrearAdmin([FromBody] CrearAdminRequestDto dto)
        {
            try
            {
                var resultado = await _soporte.CrearAdminAsync(dto, UsuarioActual!.Value, NombreActual);
                return Ok(resultado);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        [HttpPatch("admins/{usuarioId:int}")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> CambiarEstadoAdmin(int usuarioId, [FromBody] CambiarEstadoAdminRequestDto dto)
        {
            try
            {
                var ok = await _soporte.CambiarEstadoAdminAsync(usuarioId, dto.Activo, UsuarioActual!.Value, NombreActual);
                return ok ? Ok(new { mensaje = "Estado actualizado." }) : NotFound(new { mensaje = "El usuario no es administrador." });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        [HttpDelete("admins/{usuarioId:int}")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> QuitarAdmin(int usuarioId)
        {
            try
            {
                var ok = await _soporte.QuitarAdminAsync(usuarioId, UsuarioActual!.Value, NombreActual);
                return ok ? Ok(new { mensaje = "Rol ADMIN retirado." }) : NotFound(new { mensaje = "El usuario no tenía rol ADMIN." });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { mensaje = ex.Message });
            }
        }

        /* ─── Auditoría ────────────────────────────────────────────────────── */

        [HttpGet("auditoria")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> Auditoria([FromQuery] string? entidadTipo)
        {
            var registros = await _auditoria.ObtenerAsync(entidadTipo, 300);
            return Ok(registros.Select(a => new SupportAuditLogDto
            {
                Id = a.AuditLogId,
                Actor = a.ActorTipo == "IA" ? "IA" : (a.ActorNombre ?? a.ActorTipo),
                Accion = a.Accion,
                EntidadTipo = a.EntidadTipo,
                EntidadId = a.EntidadId,
                EstadoAnterior = a.EstadoAnterior,
                EstadoNuevo = a.EstadoNuevo,
                Motivo = a.Motivo,
                Fecha = a.Fecha
            }));
        }

        /// <summary>Registra el acceso al panel administrativo (auditoría explícita).</summary>
        [HttpPost("auditoria/acceso")]
        [Authorize(Roles = "ADMIN")]
        public async Task<IActionResult> RegistrarAcceso()
        {
            await _auditoria.RegistrarAsync(UsuarioActual, "ADMIN", "ACCESO_PANEL", "Panel", null, null, null,
                "Acceso al panel de administración de soporte");
            return Ok(new { mensaje = "Acceso registrado." });
        }
    }
}
