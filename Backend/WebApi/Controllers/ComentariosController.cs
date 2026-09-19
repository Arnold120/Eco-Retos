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
    public class ComentariosController : ControllerBase
    {
        private readonly IComentarioService _comentarioService;
        private readonly IPublicacionService _publicacionService;
        private readonly IUsuarioService _usuarioService;
        private readonly PublicacionMapper _mapper;
        private readonly ILogger<ComentariosController> _logger;

        public ComentariosController(
            IComentarioService comentarioService,
            IPublicacionService publicacionService,
            IUsuarioService usuarioService,
            PublicacionMapper mapper,
            ILogger<ComentariosController> logger)
        {
            _comentarioService = comentarioService;
            _publicacionService = publicacionService;
            _usuarioService = usuarioService;
            _mapper = mapper;
            _logger = logger;
        }

        [HttpGet("publicacion/{publicacionId:int}")]
        [ProducesResponseType(typeof(IEnumerable<ComentarioResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerComentariosDePublicacion(int publicacionId)
        {
            if (await _publicacionService.ObtenerPorIdAsync(publicacionId) is null)
                return NotFound(new { mensaje = $"No se encontro la publicacion con id {publicacionId}." });

            var comentarios = await _comentarioService.ObtenerComentariosDePublicacionAsync(publicacionId);
            return Ok(await _mapper.MapearComentariosAsync(comentarios, User.ObtenerUsuarioId()));
        }

        [HttpGet("publicacion/{publicacionId:int}/total")]
        public async Task<IActionResult> ContarComentarios(int publicacionId)
        {
            var total = await _comentarioService.ContarComentariosAsync(publicacionId);
            return Ok(new { total });
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(ComentarioResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var comentario = await _comentarioService.ObtenerPorIdAsync(id);
            if (comentario is null)
                return NotFound(new { mensaje = $"No se encontro el comentario con id {id}." });
            return Ok(await _mapper.MapearComentarioAsync(comentario, User.ObtenerUsuarioId()));
        }

        [HttpPost]
        [ProducesResponseType(typeof(ComentarioResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Crear([FromBody] CrearComentarioRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            if (string.IsNullOrWhiteSpace(dto.ComentarioTexto))
                return BadRequest(new { mensaje = "El comentario no puede estar vacio." });

            if (await _publicacionService.ObtenerPorIdAsync(dto.PublicacionId) is null)
                return NotFound(new { mensaje = $"No se encontro la publicacion con id {dto.PublicacionId}." });

            if (await _usuarioService.ObtenerPorIdAsync(usuarioId.Value) is null)
                return NotFound(new { mensaje = "No se encontro el usuario autenticado." });

            if (dto.ComentarioPadreId is int padreId)
            {
                var padre = await _comentarioService.ObtenerPorIdAsync(padreId);
                if (padre is null)
                    return NotFound(new { mensaje = "El comentario al que respondes ya no esta disponible." });
                if (padre.PublicacionId != dto.PublicacionId)
                    return BadRequest(new { mensaje = "El comentario padre pertenece a otra publicacion." });
            }

            var comentario = await _comentarioService.CrearComentarioAsync(new Comentario
            {
                PublicacionId = dto.PublicacionId,
                UsuarioId = usuarioId.Value,
                ComentarioTexto = dto.ComentarioTexto.Trim(),
                FechaComentario = DateTime.Now,
                ComentarioPadreId = dto.ComentarioPadreId
            });

            return CreatedAtAction(nameof(ObtenerPorId), new { id = comentario.ComentarioId },
                await _mapper.MapearComentarioAsync(comentario, usuarioId));
        }

        [HttpPut("{id:int}")]
        [ProducesResponseType(typeof(ComentarioResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarComentarioRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            var comentario = await _comentarioService.ObtenerPorIdAsync(id);
            if (comentario is null)
                return NotFound(new { mensaje = $"No se encontro el comentario con id {id}." });

            if (comentario.UsuarioId != usuarioId.Value)
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No puedes editar un comentario que no te pertenece." });

            comentario.ComentarioTexto = dto.ComentarioTexto.Trim();
            var actualizado = await _comentarioService.ActualizarAsync(comentario);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro el comentario con id {id}." });

            return Ok(await _mapper.MapearComentarioAsync(actualizado, usuarioId));
        }

        [HttpDelete("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            var comentario = await _comentarioService.ObtenerPorIdAsync(id);
            if (comentario is null)
                return NotFound(new { mensaje = $"No se encontro el comentario con id {id}." });

            if (comentario.UsuarioId != usuarioId.Value)
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No puedes eliminar un comentario que no te pertenece." });

            await _comentarioService.EliminarAsync(id);
            return NoContent();
        }
    }
}
