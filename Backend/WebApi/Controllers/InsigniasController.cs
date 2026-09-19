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
    public class InsigniasController : ControllerBase
    {
        private readonly IInsigniaService _insigniaService;
        private readonly ILogger<InsigniasController> _logger;

        public InsigniasController(IInsigniaService insigniaService, ILogger<InsigniasController> logger)
        {
            _insigniaService = insigniaService;
            _logger = logger;
        }

        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<InsigniaResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodas()
        {
            var insignias = await _insigniaService.ObtenerTodasAsync();
            return Ok(insignias.Select(Convertir).ToList());
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(InsigniaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var insignia = await _insigniaService.ObtenerPorIdAsync(id);
            if (insignia is null)
                return NotFound(new { mensaje = $"No se encontro la insignia con id {id}." });
            return Ok(Convertir(insignia));
        }

        [HttpGet("nombre/{nombre}")]
        [ProducesResponseType(typeof(InsigniaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorNombre(string nombre)
        {
            var insignia = await _insigniaService.ObtenerPorNombreAsync(nombre.Trim());
            if (insignia is null)
                return NotFound(new { mensaje = "No se encontro la insignia indicada." });
            return Ok(Convertir(insignia));
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(InsigniaResponseDto), StatusCodes.Status201Created)]
        public async Task<IActionResult> Crear([FromBody] CrearInsigniaRequestDto dto)
        {
            var insignia = new Insignia
            {
                NombreInsignia = dto.NombreInsignia.Trim(),
                Descripcion = dto.Descripcion.Trim(),
                Requisito = dto.Requisito.Trim(),
                Imagen = dto.Imagen,
                MonedasRecompensa = dto.MonedasRecompensa
            };
            insignia = await _insigniaService.CrearAsync(insignia);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = insignia.InsigniaId }, Convertir(insignia));
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(InsigniaResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarInsigniaRequestDto dto)
        {
            var insignia = await _insigniaService.ObtenerPorIdAsync(id);
            if (insignia is null)
                return NotFound(new { mensaje = $"No se encontro la insignia con id {id}." });

            insignia.NombreInsignia = dto.NombreInsignia.Trim();
            insignia.Descripcion = dto.Descripcion.Trim();
            insignia.Requisito = dto.Requisito.Trim();
            insignia.Imagen = dto.Imagen;
            insignia.MonedasRecompensa = dto.MonedasRecompensa;

            var actualizado = await _insigniaService.ActualizarAsync(insignia);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro la insignia con id {id}." });

            return Ok(Convertir(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _insigniaService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la insignia con id {id}." });
            return NoContent();
        }

        private static InsigniaResponseDto Convertir(Insignia insignia)
        {
            return new InsigniaResponseDto
            {
                InsigniaId = insignia.InsigniaId,
                NombreInsignia = insignia.NombreInsignia,
                Descripcion = insignia.Descripcion,
                Requisito = insignia.Requisito,
                Imagen = insignia.Imagen,
                MonedasRecompensa = insignia.MonedasRecompensa
            };
        }
    }
}
