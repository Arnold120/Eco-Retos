using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Helpers;
using WebApi.Interfaz;
using WebApi.Mappers;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PublicacionesController : ControllerBase
    {
        private readonly IPublicacionService _publicacionService;
        private readonly IUsuarioService _usuarioService;
        private readonly IMultimediaService _multimediaService;
        private readonly INotificacionService _notificacionService;
        private readonly PublicacionMapper _mapper;
        private readonly ILogger<PublicacionesController> _logger;

        public PublicacionesController(
            IPublicacionService publicacionService,
            IUsuarioService usuarioService,
            IMultimediaService multimediaService,
            INotificacionService notificacionService,
            PublicacionMapper mapper,
            ILogger<PublicacionesController> logger)
        {
            _publicacionService = publicacionService;
            _usuarioService = usuarioService;
            _multimediaService = multimediaService;
            _notificacionService = notificacionService;
            _mapper = mapper;
            _logger = logger;
        }

        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<PublicacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodas()
        {
            var publicaciones = await _publicacionService.ObtenerTodasAsync();
            return Ok(await _mapper.MapearListaAsync(publicaciones, User.ObtenerUsuarioId()));
        }

        [HttpGet("activas")]
        [ProducesResponseType(typeof(IEnumerable<PublicacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerActivas()
        {
            var espectadorId = User.ObtenerUsuarioId();
            var publicaciones = await _publicacionService.ObtenerPublicacionesActivasAsync(espectadorId);
            return Ok(await _mapper.MapearListaAsync(publicaciones, espectadorId));
        }

        [HttpGet("feed")]
        [ProducesResponseType(typeof(IEnumerable<PublicacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerFeed(
            [FromQuery] int pagina = 1,
            [FromQuery] int tamano = 10,
            [FromQuery] int? autorId = null,
            [FromQuery] bool siguiendo = false)
        {
            var espectadorId = User.ObtenerUsuarioId();
            var seguidosDe = siguiendo ? espectadorId : null;
            var publicaciones = await _publicacionService.ObtenerFeedAsync(pagina, tamano, autorId, seguidosDe, espectadorId);
            return Ok(await _mapper.MapearListaAsync(publicaciones, espectadorId));
        }

        [HttpGet("buscar")]
        [ProducesResponseType(typeof(IEnumerable<PublicacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> Buscar([FromQuery] string q, [FromQuery] int limite = 20)
        {
            if (string.IsNullOrWhiteSpace(q))
                return Ok(Array.Empty<PublicacionResponseDto>());

            var espectadorId = User.ObtenerUsuarioId();
            var publicaciones = await _publicacionService.BuscarAsync(q, limite, espectadorId);
            return Ok(await _mapper.MapearListaAsync(publicaciones, espectadorId));
        }

        [HttpGet("recientes/{cantidad:int}")]
        [ProducesResponseType(typeof(IEnumerable<PublicacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerRecientes(int cantidad)
        {
            var espectadorId = User.ObtenerUsuarioId();
            var publicaciones = await _publicacionService.ObtenerRecientesAsync(cantidad, espectadorId);
            return Ok(await _mapper.MapearListaAsync(publicaciones, espectadorId));
        }

        [HttpGet("tipo/{tipo}")]
        [ProducesResponseType(typeof(IEnumerable<PublicacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorTipo(string tipo)
        {
            var espectadorId = User.ObtenerUsuarioId();
            var publicaciones = await _publicacionService.ObtenerPorTipoAsync(tipo.Trim().ToUpper(), espectadorId);
            return Ok(await _mapper.MapearListaAsync(publicaciones, espectadorId));
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(PublicacionResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var publicacion = await _publicacionService.ObtenerPorIdAsync(id);
            if (publicacion is null)
                return NotFound(new { mensaje = $"No se encontro la publicacion con id {id}." });
            return Ok(await _mapper.MapearAsync(publicacion, User.ObtenerUsuarioId()));
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<PublicacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPublicacionesDeUsuario(int usuarioId)
        {
            var espectadorId = User.ObtenerUsuarioId();
            var publicaciones = await _publicacionService.ObtenerPublicacionesDeUsuarioAsync(usuarioId, espectadorId);
            return Ok(await _mapper.MapearListaAsync(publicaciones, espectadorId));
        }

        [HttpGet("usuario/{usuarioId:int}/total")]
        public async Task<IActionResult> ContarPublicaciones(int usuarioId)
        {
            var total = await _publicacionService.ContarPublicacionesAsync(usuarioId);
            return Ok(new { total });
        }

        [HttpPost]
        [ProducesResponseType(typeof(PublicacionResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Crear([FromBody] CrearPublicacionRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null)
                return Unauthorized(new { mensaje = "Sesion no valida." });

            if (await _usuarioService.ObtenerPorIdAsync(usuarioId.Value) is null)
                return NotFound(new { mensaje = "No se encontro el usuario autenticado." });

            var tieneContenido = !string.IsNullOrWhiteSpace(dto.Contenido);
            var tieneMultimedia = dto.Multimedia is { Count: > 0 };
            var esCompartido = dto.CompartidoDeId is not null;

            if (!tieneContenido && !tieneMultimedia && !esCompartido)
                return BadRequest(new { mensaje = "La publicacion necesita texto, multimedia o un contenido compartido." });

            Publicacion? original = null;
            if (dto.CompartidoDeId is int originalId)
            {
                original = await _publicacionService.ObtenerPorIdAsync(originalId);
                if (original is null)
                    return NotFound(new { mensaje = "La publicacion original ya no esta disponible." });
            }

            var publicacion = await _publicacionService.CrearAsync(new Publicacion
            {
                UsuarioId = usuarioId.Value,
                Contenido = dto.Contenido?.Trim() ?? string.Empty,
                Imagen = dto.Imagen,
                Tipo = (dto.Tipo ?? "GENERAL").Trim().ToUpper(),
                FechaPublicacion = DateTime.Now,
                Estado = "PUBLICADA",
                Ubicacion = string.IsNullOrWhiteSpace(dto.Ubicacion) ? null : dto.Ubicacion.Trim(),
                Categoria = string.IsNullOrWhiteSpace(dto.Categoria) ? null : dto.Categoria.Trim(),
                Visibilidad = NormalizarVisibilidad(dto.Visibilidad),
                CompartidoDeId = dto.CompartidoDeId
            });

            if (tieneMultimedia)
                await _multimediaService.ReemplazarAsync(publicacion.PublicacionId, dto.Multimedia!.Select(m => new PublicacionMultimedia
                {
                    Url = m.Url,
                    Tipo = m.Tipo,
                    Duracion = m.Duracion,
                    Poster = m.Poster
                }));

            if (original is not null && original.UsuarioId != usuarioId.Value)
            {
                try
                {
                    var actor = await _usuarioService.ObtenerPorIdAsync(usuarioId.Value);
                    await _notificacionService.CrearInteraccionAsync(
                        original.UsuarioId, usuarioId.Value,
                        $"{actor?.NombreUsuario ?? "Alguien"} compartió tu publicación",
                        "Tu publicación está llegando a más personas.",
                        "COMPARTIDO", "PUBLICACION", original.PublicacionId);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "No se pudo crear la notificacion de compartido.");
                }
            }

            return CreatedAtAction(nameof(ObtenerPorId), new { id = publicacion.PublicacionId },
                await _mapper.MapearAsync(publicacion, usuarioId));
        }

        [HttpPut("{id:int}")]
        [ProducesResponseType(typeof(PublicacionResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarPublicacionRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            var publicacion = await _publicacionService.ObtenerPorIdAsync(id);
            if (publicacion is null)
                return NotFound(new { mensaje = $"No se encontro la publicacion con id {id}." });

            if (publicacion.UsuarioId != usuarioId.Value)
                return Forbidden("No puedes editar una publicacion que no te pertenece.");

            publicacion.Contenido = dto.Contenido.Trim();
            publicacion.Imagen = dto.Imagen;
            publicacion.Tipo = dto.Tipo.Trim().ToUpper();
            publicacion.Estado = dto.Estado.Trim().ToUpper();
            publicacion.Ubicacion = string.IsNullOrWhiteSpace(dto.Ubicacion) ? null : dto.Ubicacion.Trim();
            publicacion.Categoria = string.IsNullOrWhiteSpace(dto.Categoria) ? null : dto.Categoria.Trim();
            publicacion.Visibilidad = NormalizarVisibilidad(dto.Visibilidad);
            publicacion.Editada = true;
            publicacion.FechaEdicion = DateTime.Now;

            var actualizado = await _publicacionService.ActualizarAsync(publicacion);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro la publicacion con id {id}." });

            if (dto.Multimedia is not null)
                await _multimediaService.ReemplazarAsync(id, dto.Multimedia.Select(m => new PublicacionMultimedia
                {
                    Url = m.Url,
                    Tipo = m.Tipo,
                    Duracion = m.Duracion,
                    Poster = m.Poster
                }));

            return Ok(await _mapper.MapearAsync(actualizado, usuarioId));
        }

        [HttpDelete("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            var publicacion = await _publicacionService.ObtenerPorIdAsync(id);
            if (publicacion is null)
                return NotFound(new { mensaje = $"No se encontro la publicacion con id {id}." });

            if (publicacion.UsuarioId != usuarioId.Value)
                return Forbidden("No puedes eliminar una publicacion que no te pertenece.");

            await _publicacionService.EliminarAsync(id);
            return NoContent();
        }

        private ObjectResult Forbidden(string mensaje)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { mensaje });
        }

        private static string NormalizarVisibilidad(string? visibilidad)
        {
            return (visibilidad ?? "PUBLICO").Trim().ToUpperInvariant() switch
            {
                "SEGUIDORES" => "SEGUIDORES",
                "SOLO_YO" => "SOLO_YO",
                _ => "PUBLICO"
            };
        }
    }
}
