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
    public class DispositivosController : ControllerBase
    {
        private readonly IDispositivoService _dispositivoService;

        public DispositivosController(IDispositivoService dispositivoService)
        {
            _dispositivoService = dispositivoService;
        }

        [HttpPost("token")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> RegistrarToken([FromBody] RegistrarDispositivoRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();
            if (string.IsNullOrWhiteSpace(dto.Token))
                return BadRequest(new { mensaje = "El token FCM es obligatorio." });

            var ahora = DateTime.UtcNow;
            await _dispositivoService.RegistrarAsync(new UsuarioDispositivo
            {
                UsuarioId = usuarioId.Value,
                Token = dto.Token.Trim(),
                Plataforma = string.IsNullOrWhiteSpace(dto.Plataforma)
                    ? "desconocida"
                    : dto.Plataforma.Trim().ToLowerInvariant(),
                FechaRegistro = ahora,
                FechaActualizacion = ahora,
                Activo = true
            });

            return NoContent();
        }

        [HttpDelete("token")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<IActionResult> DesactivarToken([FromBody] RegistrarDispositivoRequestDto dto)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();
            if (!string.IsNullOrWhiteSpace(dto.Token))
                await _dispositivoService.DesactivarAsync(usuarioId.Value, dto.Token.Trim());
            return NoContent();
        }
    }
}
