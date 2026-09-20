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
    public class CalificacionesController : ControllerBase
    {
        private readonly ICalificacionService _calificacionService;
        private readonly IUsuarioService _usuarioService;

        public CalificacionesController(
            ICalificacionService calificacionService,
            IUsuarioService usuarioService)
        {
            _calificacionService = calificacionService;
            _usuarioService = usuarioService;
        }

        [HttpGet("{usuarioId:int}")]
        [ProducesResponseType(typeof(ResumenCalificacionesDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerResumen(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            return Ok(await ResumenAsync(User.ObtenerUsuarioId(), usuarioId));
        }

        [HttpPost("{usuarioId:int}")]
        [ProducesResponseType(typeof(ResumenCalificacionesDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Calificar(int usuarioId, [FromBody] CalificarPerfilRequestDto dto)
        {
            var espectadorId = User.ObtenerUsuarioId();
            if (espectadorId is null) return Unauthorized();
            if (espectadorId.Value == usuarioId)
                return BadRequest(new { mensaje = "No puedes calificar tu propio perfil." });

            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            await _calificacionService.GuardarAsync(
                espectadorId.Value, usuarioId, dto.Calificacion, dto.Comentario);

            return Ok(await ResumenAsync(espectadorId, usuarioId));
        }

        [HttpDelete("{usuarioId:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<IActionResult> Eliminar(int usuarioId)
        {
            var espectadorId = User.ObtenerUsuarioId();
            if (espectadorId is null) return Unauthorized();

            await _calificacionService.EliminarAsync(espectadorId.Value, usuarioId);
            return NoContent();
        }

        private async Task<ResumenCalificacionesDto> ResumenAsync(int? espectadorId, int usuarioId)
        {
            var (promedio, total) = await _calificacionService.ObtenerResumenAsync(usuarioId);
            var opiniones = await _calificacionService.ObtenerOpinionesAsync(usuarioId);
            var propia = espectadorId is int id && id != usuarioId
                ? await _calificacionService.ObtenerCalificacionPropiaAsync(id, usuarioId)
                : (int?)null;

            return new ResumenCalificacionesDto
            {
                Promedio = Math.Round(promedio, 1),
                Total = total,
                CalificacionPropia = propia,
                Opiniones = opiniones.Select(o => new CalificacionOpinionDto
                {
                    UsuarioId = o.UsuarioId,
                    NombreUsuario = o.NombreUsuario,
                    FotoPerfil = o.FotoPerfil,
                    Calificacion = o.Calificacion,
                    Comentario = o.Comentario,
                    Fecha = o.Fecha
                }).ToList()
            };
        }
    }
}