using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Helpers;
using WebApi.Interfaz;
using WebApi.Mappers;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class GuardadosController : ControllerBase
    {
        private readonly IGuardadoService _guardadoService;
        private readonly IPublicacionService _publicacionService;
        private readonly PublicacionMapper _mapper;

        public GuardadosController(
            IGuardadoService guardadoService,
            IPublicacionService publicacionService,
            PublicacionMapper mapper)
        {
            _guardadoService = guardadoService;
            _publicacionService = publicacionService;
            _mapper = mapper;
        }


        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<PublicacionResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerGuardadas()
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            var ids = (await _guardadoService.ObtenerIdsGuardadosAsync(usuarioId.Value)).ToList();
            var publicaciones = await _publicacionService.ObtenerPorIdsAsync(ids);
            var ordenadas = ids
                .Where(publicaciones.ContainsKey)
                .Select(id => publicaciones[id])
                .Where(p => p.Estado == "PUBLICADA")
                .ToList();

            return Ok(await _mapper.MapearListaAsync(ordenadas, usuarioId));
        }

        [HttpPost("{publicacionId:int}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Alternar(int publicacionId)
        {
            var usuarioId = User.ObtenerUsuarioId();
            if (usuarioId is null) return Unauthorized();

            if (await _publicacionService.ObtenerPorIdAsync(publicacionId) is null)
                return NotFound(new { mensaje = $"No se encontro la publicacion con id {publicacionId}." });

            var guardada = await _guardadoService.AlternarAsync(usuarioId.Value, publicacionId);
            return Ok(new { guardada });
        }
    }
}
