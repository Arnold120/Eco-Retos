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
    public class PerfilesController : ControllerBase
    {
        private readonly IPerfilService _perfilService;
        private readonly IUsuarioService _usuarioService;
        private readonly ISeguimientoService _seguimientoService;
        private readonly IPublicacionService _publicacionService;
        private readonly ILogger<PerfilesController> _logger;

        public PerfilesController(
            IPerfilService perfilService,
            IUsuarioService usuarioService,
            ISeguimientoService seguimientoService,
            IPublicacionService publicacionService,
            ILogger<PerfilesController> logger)
        {
            _perfilService = perfilService;
            _usuarioService = usuarioService;
            _seguimientoService = seguimientoService;
            _publicacionService = publicacionService;
            _logger = logger;
        }


        [HttpGet("usuario/{usuarioId:int}/publico")]
        [ProducesResponseType(typeof(PerfilPublicoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPublico(int usuarioId)
        {
            var usuario = await _usuarioService.ObtenerPorIdAsync(usuarioId);
            if (usuario is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var perfil = await _perfilService.ObtenerPerfilPorUsuarioAsync(usuarioId);
            var espectadorId = User.ObtenerUsuarioId();

            var nombreCompleto = perfil is null
                ? null
                : $"{perfil.Nombre} {perfil.Apellido}".Trim();

            return Ok(new PerfilPublicoResponseDto
            {
                UsuarioId = usuarioId,
                NombreUsuario = usuario.NombreUsuario,
                FotoPerfil = perfil?.FotoPerfil,
                NombreCompleto = string.IsNullOrWhiteSpace(nombreCompleto) ? null : nombreCompleto,
                CentroEducativo = string.IsNullOrWhiteSpace(perfil?.CentroEducativo) ? null : perfil!.CentroEducativo,
                Grado = string.IsNullOrWhiteSpace(perfil?.Grado) ? null : perfil!.Grado,
                CantidadPublicaciones = await _publicacionService.ContarPublicacionesAsync(usuarioId),
                CantidadSeguidores = await _seguimientoService.ContarSeguidoresAsync(usuarioId),
                CantidadSeguidos = await _seguimientoService.ContarSeguidosAsync(usuarioId),
                Siguiendo = espectadorId is int id && id != usuarioId
                    && await _seguimientoService.EstaSiguiendoAsync(id, usuarioId),
                EsMiPerfil = espectadorId == usuarioId
            });
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(PerfilResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorUsuario(int usuarioId)
        {
            var perfil = await _perfilService.ObtenerPerfilPorUsuarioAsync(usuarioId);
            if (perfil is null)
                return NotFound(new { mensaje = $"No se encontro un perfil para el usuario {usuarioId}." });
            return Ok(Convertir(perfil));
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(PerfilResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var perfil = await _perfilService.ObtenerPorIdAsync(id);
            if (perfil is null)
                return NotFound(new { mensaje = $"No se encontro el perfil con id {id}." });
            return Ok(Convertir(perfil));
        }

        [HttpGet("centro/{centroEducativo}")]
        [ProducesResponseType(typeof(IEnumerable<PerfilResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorCentroEducativo(string centroEducativo)
        {
            var perfiles = await _perfilService.ObtenerPorCentroEducativoAsync(centroEducativo.Trim());
            return Ok(perfiles.Select(p => Convertir(p)).ToList());
        }

        [HttpPost]
        [ProducesResponseType(typeof(PerfilResponseDto), StatusCodes.Status201Created)]
        public async Task<IActionResult> Crear([FromBody] CrearPerfilRequestDto dto)
        {
            var perfil = new Perfil
            {
                UsuarioId = dto.UsuarioId,
                Nombre = dto.Nombre.Trim(),
                Apellido = dto.Apellido.Trim(),
                Carnet = dto.Carnet?.Trim() ?? string.Empty,
                CentroEducativo = dto.CentroEducativo?.Trim() ?? string.Empty,
                Grado = dto.Grado?.Trim() ?? string.Empty,
                FotoPerfil = dto.FotoPerfil
            };
            perfil = await _perfilService.CrearAsync(perfil);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = perfil.PerfilId }, Convertir(perfil));
        }

        [HttpPut("{id:int}")]
        [ProducesResponseType(typeof(PerfilResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarPerfilRequestDto dto)
        {
            var perfil = await _perfilService.ObtenerPorIdAsync(id);
            if (perfil is null)
                return NotFound(new { mensaje = $"No se encontro el perfil con id {id}." });





            perfil.Nombre = string.IsNullOrWhiteSpace(dto.Nombre) ? perfil.Nombre : dto.Nombre.Trim();
            perfil.Apellido = string.IsNullOrWhiteSpace(dto.Apellido) ? perfil.Apellido : dto.Apellido.Trim();
            if (dto.Carnet is not null)
                perfil.Carnet = dto.Carnet.Trim();
            if (dto.CentroEducativo is not null)
                perfil.CentroEducativo = dto.CentroEducativo.Trim();
            if (dto.Grado is not null)
                perfil.Grado = dto.Grado.Trim();
            if (dto.FotoPerfil is not null)
                perfil.FotoPerfil = dto.FotoPerfil;

            var actualizado = await _perfilService.ActualizarAsync(perfil);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro el perfil con id {id}." });

            return Ok(Convertir(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _perfilService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el perfil con id {id}." });
            return NoContent();
        }

        private static PerfilResponseDto Convertir(Perfil perfil)
        {
            return new PerfilResponseDto
            {
                PerfilId = perfil.PerfilId,
                UsuarioId = perfil.UsuarioId,
                Nombre = perfil.Nombre,
                Apellido = perfil.Apellido,
                Carnet = perfil.Carnet,
                CentroEducativo = perfil.CentroEducativo,
                Grado = perfil.Grado,
                FotoPerfil = perfil.FotoPerfil
            };
        }
    }
}