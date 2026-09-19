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
    public class BusquedaController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;
        private readonly IPublicacionService _publicacionService;
        private readonly IPerfilService _perfilService;
        private readonly PublicacionMapper _mapper;

        public BusquedaController(
            IUsuarioService usuarioService,
            IPublicacionService publicacionService,
            IPerfilService perfilService,
            PublicacionMapper mapper)
        {
            _usuarioService = usuarioService;
            _publicacionService = publicacionService;
            _perfilService = perfilService;
            _mapper = mapper;
        }


        [HttpGet("usuarios")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioResumenDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> TodosLosUsuarios(
            [FromQuery] int limite = 100,
            [FromQuery] int? excluir = null)
        {
            limite = Math.Clamp(limite, 1, 200);
            var usuarios = (await _usuarioService.BuscarAsync(string.Empty, limite + 1))
                .Where(u => u.UsuarioId != excluir)
                .Take(limite)
                .ToList();
            var perfiles = await _perfilService.ObtenerPorUsuariosAsync(
                usuarios.Select(u => u.UsuarioId));

            return Ok(usuarios.Select(u => new UsuarioResumenDto
            {
                UsuarioId = u.UsuarioId,
                NombreUsuario = u.NombreUsuario,
                FotoPerfil = perfiles.TryGetValue(u.UsuarioId, out var p)
                    ? p.FotoPerfil
                    : null
            }).ToList());
        }


        [HttpGet]
        [ProducesResponseType(typeof(BusquedaResponseDto), StatusCodes.Status200OK)]
        public async Task<IActionResult> Buscar([FromQuery] string q, [FromQuery] int limite = 15)
        {
            if (string.IsNullOrWhiteSpace(q))
                return Ok(new BusquedaResponseDto());

            limite = Math.Clamp(limite, 1, 30);
            var espectadorId = User.ObtenerUsuarioId();

            var usuarios = (await _usuarioService.BuscarAsync(q, limite)).ToList();
            var perfiles = await _perfilService.ObtenerPorUsuariosAsync(usuarios.Select(u => u.UsuarioId));
            var publicaciones = await _publicacionService.BuscarAsync(q, limite, espectadorId);

            return Ok(new BusquedaResponseDto
            {
                Usuarios = usuarios.Select(u => new UsuarioResumenDto
                {
                    UsuarioId = u.UsuarioId,
                    NombreUsuario = u.NombreUsuario,
                    FotoPerfil = perfiles.TryGetValue(u.UsuarioId, out var p) ? p.FotoPerfil : null
                }).ToList(),
                Publicaciones = await _mapper.MapearListaAsync(publicaciones, espectadorId)
            });
        }
    }
}
