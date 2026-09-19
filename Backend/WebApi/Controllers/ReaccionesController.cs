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
    public class ReaccionesController : ControllerBase
    {
        private readonly IReaccionService _reaccionService;

        public ReaccionesController(IReaccionService reaccionService)
        {
            _reaccionService = reaccionService;
        }





        [HttpPost]
        [ProducesResponseType(typeof(ReaccionResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Alternar([FromBody] AlternarReaccionRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            if ((dto.PublicacionId is null) == (dto.ComentarioId is null))
                return BadRequest(new { mensaje = "Indica exactamente una publicacion o un comentario." });

            var (activa, tipo, total) = await _reaccionService.AlternarAsync(
                usuarioId.Value, dto.PublicacionId, dto.ComentarioId, dto.Tipo);

            return Ok(new ReaccionResponseDto { Activa = activa, Tipo = tipo, Total = total });
        }
    }
}
