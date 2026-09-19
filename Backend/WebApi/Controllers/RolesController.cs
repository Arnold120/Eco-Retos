using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class RolesController : ControllerBase
    {
        private readonly IRolService _rolService;
        private readonly ILogger<RolesController> _logger;

        public RolesController(IRolService rolService, ILogger<RolesController> logger)
        {
            _rolService = rolService;
            _logger = logger;
        }

        [HttpGet]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<RolResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodos()
        {
            var roles = await _rolService.ObtenerTodosAsync();
            return Ok(roles.Select(Convertir).ToList());
        }

        [HttpGet("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(RolResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var rol = await _rolService.ObtenerPorIdAsync(id);
            if (rol is null)
                return NotFound(new { mensaje = $"No se encontro el rol con id {id}." });
            return Ok(Convertir(rol));
        }

        [HttpGet("nombre/{nombre}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(RolResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorNombre(string nombre)
        {
            var rol = await _rolService.ObtenerPorNombreAsync(nombre.Trim().ToUpper());
            if (rol is null)
                return NotFound(new { mensaje = "No se encontro el rol indicado." });
            return Ok(Convertir(rol));
        }

        [HttpPost]
        // [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(RolResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> Crear([FromBody] CrearRolRequestDto dto)
        {
            var existente = await _rolService.ObtenerPorNombreAsync(dto.NombreRol.Trim().ToUpper());
            if (existente is not null)
                return Conflict(new { mensaje = "Ya existe un rol con ese nombre." });

            var rol = new Rol
            {
                NombreRol = dto.NombreRol.Trim().ToUpper(),
                Descripcion = dto.Descripcion.Trim()
            };
            rol = await _rolService.CrearAsync(rol);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = rol.RolId }, Convertir(rol));
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(RolResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarRolRequestDto dto)
        {
            var rol = await _rolService.ObtenerPorIdAsync(id);
            if (rol is null)
                return NotFound(new { mensaje = $"No se encontro el rol con id {id}." });

            rol.NombreRol = dto.NombreRol.Trim().ToUpper();
            rol.Descripcion = dto.Descripcion.Trim();

            var actualizado = await _rolService.ActualizarAsync(rol);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro el rol con id {id}." });

            return Ok(Convertir(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _rolService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el rol con id {id}." });
            return NoContent();
        }

        private static RolResponseDto Convertir(Rol rol)
        {
            return new RolResponseDto
            {
                RolId = rol.RolId,
                NombreRol = rol.NombreRol,
                Descripcion = rol.Descripcion
            };
        }
    }
}