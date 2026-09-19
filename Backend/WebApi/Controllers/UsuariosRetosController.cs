using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Controllers
{
    [ApiController]
    [Route("api/usuarios-retos")]
    [Authorize]
    public class UsuariosRetosController : ControllerBase
    {
        private readonly IUsuarioRetoService _usuarioRetoService;
        private readonly IRetoService _retoService;
        private readonly IUsuarioService _usuarioService;
        private readonly ILogger<UsuariosRetosController> _logger;

        public UsuariosRetosController(
            IUsuarioRetoService usuarioRetoService,
            IRetoService retoService,
            IUsuarioService usuarioService,
            ILogger<UsuariosRetosController> logger)
        {
            _usuarioRetoService = usuarioRetoService;
            _retoService = retoService;
            _usuarioService = usuarioService;
            _logger = logger;
        }

        [HttpGet]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioRetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodos()
        {
            var lista = new List<UsuarioRetoResponseDto>();
            foreach (var ur in await _usuarioRetoService.ObtenerTodosAsync())
                lista.Add(await ConvertirAsync(ur));
            return Ok(lista);
        }


        [HttpGet("evidencias-pendientes")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioRetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerEvidenciasPendientes()
        {
            var lista = new List<UsuarioRetoResponseDto>();
            foreach (var ur in await _usuarioRetoService.ObtenerEvidenciasPendientesAsync())
                lista.Add(await ConvertirAsync(ur));
            return Ok(lista);
        }


        [HttpGet("evidencias")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioRetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerEvidencias()
        {
            var lista = new List<UsuarioRetoResponseDto>();
            foreach (var ur in await _usuarioRetoService.ObtenerEvidenciasAsync())
                lista.Add(await ConvertirAsync(ur));
            return Ok(lista);
        }


        [HttpPatch("{id:int}/aprobar")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> AprobarEvidencia(int id, [FromBody] CompletarRetoRequestDto dto)
        {
            var ok = await _usuarioRetoService.AprobarEvidenciaAsync(id, dto.PuntosObtenidos);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la participacion con id {id}." });
            return Ok(new { mensaje = "Evidencia aprobada. El reto fue completado." });
        }


        [HttpPatch("{id:int}/rechazar")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> RechazarEvidencia(int id, [FromBody] RechazarEvidenciaRequestDto dto)
        {
            var ok = await _usuarioRetoService.RechazarEvidenciaAsync(id, dto.Motivo?.Trim() ?? "Evidencia no valida.");
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la participacion con id {id}." });
            return Ok(new { mensaje = "Evidencia rechazada. El estudiante debera rehacerla." });
        }

        [HttpGet("usuario/{usuarioId:int}")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioRetoResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerRetosDeUsuario(int usuarioId)
        {
            if (await _usuarioService.ObtenerPorIdAsync(usuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {usuarioId}." });

            var lista = new List<UsuarioRetoResponseDto>();
            foreach (var ur in await _usuarioRetoService.ObtenerRetosDeUsuarioAsync(usuarioId))
                lista.Add(await ConvertirAsync(ur));
            return Ok(lista);
        }

        [HttpGet("usuario/{usuarioId:int}/activos")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioRetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerActivosDeUsuario(int usuarioId)
        {
            var lista = new List<UsuarioRetoResponseDto>();
            foreach (var ur in await _usuarioRetoService.ObtenerActivosDeUsuarioAsync(usuarioId))
                lista.Add(await ConvertirAsync(ur));
            return Ok(lista);
        }

        [HttpGet("usuario/{usuarioId:int}/completados")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioRetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerCompletadosDeUsuario(int usuarioId)
        {
            var lista = new List<UsuarioRetoResponseDto>();
            foreach (var ur in await _usuarioRetoService.ObtenerCompletadosDeUsuarioAsync(usuarioId))
                lista.Add(await ConvertirAsync(ur));
            return Ok(lista);
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(UsuarioRetoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var ur = await _usuarioRetoService.ObtenerPorIdAsync(id);
            if (ur is null)
                return NotFound(new { mensaje = $"No se encontro la participacion con id {id}." });
            return Ok(await ConvertirAsync(ur));
        }

        [HttpGet("usuario/{usuarioId:int}/reto/{retoId:int}")]
        [ProducesResponseType(typeof(UsuarioRetoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorUsuarioYReto(int usuarioId, int retoId)
        {
            var ur = await _usuarioRetoService.ObtenerPorUsuarioYRetoAsync(usuarioId, retoId);
            if (ur is null)
                return NotFound(new { mensaje = "El usuario no ha participado en ese reto." });
            return Ok(await ConvertirAsync(ur));
        }

        [HttpPost]
        [ProducesResponseType(typeof(UsuarioRetoResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> RegistrarParticipacion([FromBody] RegistrarParticipacionRequestDto dto)
        {
            if (await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId) is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            if (await _retoService.ObtenerPorIdAsync(dto.RetoId) is null)
                return NotFound(new { mensaje = $"No se encontro el reto con id {dto.RetoId}." });

            if (await _usuarioRetoService.ObtenerPorUsuarioYRetoAsync(dto.UsuarioId, dto.RetoId) is not null)
                return Conflict(new { mensaje = "El usuario ya esta participando en ese reto." });

            var usuarioReto = new UsuarioReto
            {
                UsuarioId = dto.UsuarioId,
                RetoId = dto.RetoId,
                Estado = "INICIADO",
                FechaInicio = DateTime.Now
            };
            usuarioReto = await _usuarioRetoService.RegistrarParticipacionAsync(usuarioReto);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = usuarioReto.UsuarioRetoId }, await ConvertirAsync(usuarioReto));
        }

        [HttpPost("sincronizar")]
        [ProducesResponseType(typeof(IEnumerable<UsuarioRetoResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> SincronizarParticipaciones([FromBody] SincronizarParticipacionesRequestDto dto)
        {
            var usuario = await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId);
            if (usuario is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            var items = dto.Participaciones.Select(p => new RetoSincronizacion
            {
                Codigo = p.Codigo,
                CategoriaId = p.CategoriaId,
                Titulo = p.Titulo,
                Descripcion = p.Descripcion,
                Instrucciones = p.Instrucciones,
                ExperienciaRecompensa = p.ExperienciaRecompensa,
                MonedasRecompensa = p.MonedasRecompensa,
                Dificultad = p.Dificultad,
                Estado = p.Estado,
                Evidencia = p.Evidencia,
                PuntosObtenidos = p.PuntosObtenidos
            });




            var sincronizados = await _usuarioRetoService.SincronizarParticipacionesAsync(dto.UsuarioId, items);

            var resultado = sincronizados.Select(r => new UsuarioRetoResponseDto
            {
                UsuarioRetoId = r.UsuarioReto.UsuarioRetoId,
                UsuarioId = r.UsuarioReto.UsuarioId,
                RetoId = r.UsuarioReto.RetoId,
                Codigo = r.Codigo,
                NombreUsuario = usuario.NombreUsuario,
                TituloReto = r.TituloReto,
                Estado = r.UsuarioReto.Estado,
                Evidencia = r.UsuarioReto.Evidencia,
                MotivoRechazo = r.UsuarioReto.MotivoRechazo,
                PuntosObtenidos = r.UsuarioReto.PuntosObtenidos,
                ExperienciaRecompensaReto = r.ExperienciaRecompensaReto,
                MonedasRecompensaReto = r.MonedasRecompensaReto,
                FechaInicio = r.UsuarioReto.FechaInicio,
                FechaCompletado = r.UsuarioReto.FechaCompletado
            }).ToList();

            return Ok(resultado);
        }

        [HttpPatch("{id:int}/estado")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ActualizarEstado(int id, [FromBody] ActualizarEstadoUsuarioRetoRequestDto dto)
        {
            var ok = await _usuarioRetoService.ActualizarEstadoAsync(id, dto.Estado.Trim().ToUpper());
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la participacion con id {id}." });
            return Ok(new { mensaje = "Estado actualizado correctamente." });
        }

        [HttpPatch("{id:int}/completar")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> CompletarReto(int id, [FromBody] CompletarRetoRequestDto dto)
        {
            var ok = await _usuarioRetoService.CompletarRetoAsync(id, dto.PuntosObtenidos);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la participacion con id {id}." });
            return Ok(new { mensaje = "Reto completado correctamente." });
        }

        [HttpPatch("{id:int}/evidencia")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> RegistrarEvidencia(int id, [FromBody] RegistrarEvidenciaRequestDto dto)
        {
            var ok = await _usuarioRetoService.RegistrarEvidenciaAsync(id, dto.Evidencia?.Trim() ?? string.Empty);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro la participacion con id {id}." });
            return Ok(new { mensaje = "Evidencia registrada correctamente." });
        }

        private async Task<UsuarioRetoResponseDto> ConvertirAsync(UsuarioReto usuarioReto)
        {
            var dto = new UsuarioRetoResponseDto
            {
                UsuarioRetoId = usuarioReto.UsuarioRetoId,
                UsuarioId = usuarioReto.UsuarioId,
                RetoId = usuarioReto.RetoId,
                Estado = usuarioReto.Estado,
                Evidencia = usuarioReto.Evidencia,
                MotivoRechazo = usuarioReto.MotivoRechazo,
                PuntosObtenidos = usuarioReto.PuntosObtenidos,
                FechaInicio = usuarioReto.FechaInicio,
                FechaCompletado = usuarioReto.FechaCompletado
            };

            var reto = await _retoService.ObtenerPorIdAsync(usuarioReto.RetoId);
            if (reto is not null)
            {
                dto.TituloReto = reto.Titulo;
                dto.ExperienciaRecompensaReto = reto.ExperienciaRecompensa;
                dto.MonedasRecompensaReto = reto.MonedasRecompensa;
                dto.Codigo = reto.Codigo;
            }

            var usuario = await _usuarioService.ObtenerPorIdAsync(usuarioReto.UsuarioId);
            if (usuario is not null)
                dto.NombreUsuario = usuario.NombreUsuario;

            return dto;
        }
    }
}