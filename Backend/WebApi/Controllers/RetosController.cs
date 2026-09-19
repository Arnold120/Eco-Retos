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
    public class RetosController : ControllerBase
    {
        private readonly IRetoService _retoService;
        private readonly ICategoriaService _categoriaService;
        private readonly IUsuarioRetoService _usuarioRetoService;
        private readonly IUsuarioService _usuarioService;
        private readonly ILogger<RetosController> _logger;

        public RetosController(
            IRetoService retoService,
            ICategoriaService categoriaService,
            IUsuarioRetoService usuarioRetoService,
            IUsuarioService usuarioService,
            ILogger<RetosController> logger)
        {
            _retoService = retoService;
            _categoriaService = categoriaService;
            _usuarioRetoService = usuarioRetoService;
            _usuarioService = usuarioService;
            _logger = logger;
        }

        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<RetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerTodos()
        {
            var retos = await _retoService.ObtenerTodosAsync();
            return Ok((await ConvertirListaAsync(retos)).ToList());
        }

        [HttpGet("activos")]
        [ProducesResponseType(typeof(IEnumerable<RetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerActivos()
        {
            var retos = await _retoService.ObtenerActivosAsync();
            return Ok((await ConvertirListaAsync(retos)).ToList());
        }

        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(RetoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ObtenerPorId(int id)
        {
            var reto = await _retoService.ObtenerPorIdAsync(id);
            if (reto is null)
                return NotFound(new { mensaje = $"No se encontro el reto con id {id}." });
            return Ok(await ConvertirAsync(reto));
        }

        [HttpGet("categoria/{categoriaId:int}")]
        [ProducesResponseType(typeof(IEnumerable<RetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorCategoria(int categoriaId)
        {
            var retos = await _retoService.ObtenerPorCategoriaAsync(categoriaId);
            return Ok((await ConvertirListaAsync(retos)).ToList());
        }

        [HttpGet("dificultad/{dificultad}")]
        [ProducesResponseType(typeof(IEnumerable<RetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorDificultad(string dificultad)
        {
            var retos = await _retoService.ObtenerPorDificultadAsync(dificultad.Trim().ToUpper());
            return Ok((await ConvertirListaAsync(retos)).ToList());
        }

        [HttpGet("estado/{estado}")]
        [ProducesResponseType(typeof(IEnumerable<RetoResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ObtenerPorEstado(string estado)
        {
            var retos = await _retoService.ObtenerPorEstadoAsync(estado.Trim().ToUpper());
            return Ok((await ConvertirListaAsync(retos)).ToList());
        }

        /// <summary>Registro automático de un reto del catálogo local (upsert por Codigo).</summary>
        [HttpPost("registrar")]
        [Authorize]
        [ProducesResponseType(typeof(RetoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(RetoResponseDto), StatusCodes.Status201Created)]
        public async Task<IActionResult> RegistrarPorCodigo([FromBody] RegistrarRetoCatalogoRequestDto dto)
        {
            // Upsert centralizado: si el reto existe, también actualiza su
            // recompensa (XP + Monedas Eco) con la del catálogo local.
            var reto = await _retoService.ObtenerOCrearPorCodigoAsync(
                dto.Codigo.Trim(),
                dto.CategoriaId,
                dto.Titulo.Trim(),
                dto.Descripcion?.Trim() ?? string.Empty,
                dto.Instrucciones?.Trim() ?? string.Empty,
                dto.ExperienciaRecompensa,
                dto.MonedasRecompensa,
                dto.Dificultad.Trim().ToUpper());
            return Ok(await ConvertirAsync(reto));
        }

        [HttpPost("asignar")]
        [Authorize]
        [ProducesResponseType(typeof(UsuarioRetoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> AsignarRetoAUsuario([FromBody] AsignarRetoRequestDto dto)
        {
            var usuario = await _usuarioService.ObtenerPorIdAsync(dto.UsuarioId);
            if (usuario is null)
                return NotFound(new { mensaje = $"No se encontro el usuario con id {dto.UsuarioId}." });

            // Vive en Retos el "push": verifica si el reto del catalogo ya esta
            // en la base (por Codigo) y, si no esta, lo crea. Despues se asigna
            // al usuario (o se reutiliza la participacion existente).
            var reto = await _retoService.ObtenerOCrearPorCodigoAsync(
                dto.Codigo.Trim(),
                dto.CategoriaId,
                dto.Titulo.Trim(),
                dto.Descripcion?.Trim() ?? string.Empty,
                dto.Instrucciones?.Trim() ?? string.Empty,
                dto.ExperienciaRecompensa,
                dto.MonedasRecompensa,
                dto.Dificultad.Trim().ToUpper());

            var usuarioReto = await _usuarioRetoService.ObtenerPorUsuarioYRetoAsync(dto.UsuarioId, reto.RetoId);
            if (usuarioReto is null)
            {
                usuarioReto = await _usuarioRetoService.RegistrarParticipacionAsync(new UsuarioReto
                {
                    UsuarioId = dto.UsuarioId,
                    RetoId = reto.RetoId,
                    Estado = "INICIADO",
                    FechaInicio = DateTime.Now
                });
            }

            var estado = dto.Estado?.Trim().ToUpper() ?? "INICIADO";
            if (estado == "EN_REVISION" && !string.IsNullOrWhiteSpace(dto.Evidencia))
            {
                await _usuarioRetoService.RegistrarEvidenciaAsync(usuarioReto.UsuarioRetoId, dto.Evidencia.Trim());
                usuarioReto.Estado = "EN_REVISION";
                usuarioReto.Evidencia = dto.Evidencia.Trim();
                usuarioReto.MotivoRechazo = null;
            }
            else if (estado == "COMPLETADO")
            {
                await _usuarioRetoService.CompletarRetoAsync(usuarioReto.UsuarioRetoId, dto.PuntosObtenidos);
                usuarioReto.Estado = "COMPLETADO";
                usuarioReto.PuntosObtenidos = dto.PuntosObtenidos;
                usuarioReto.FechaCompletado = DateTime.Now;
            }
            else if (estado == "INICIADO")
            {
                await _usuarioRetoService.ActualizarEstadoAsync(usuarioReto.UsuarioRetoId, "INICIADO");
                usuarioReto.Estado = "INICIADO";
            }

            return Ok(new UsuarioRetoResponseDto
            {
                UsuarioRetoId = usuarioReto.UsuarioRetoId,
                UsuarioId = usuarioReto.UsuarioId,
                RetoId = reto.RetoId,
                Codigo = reto.Codigo,
                NombreUsuario = usuario.NombreUsuario,
                TituloReto = reto.Titulo,
                Estado = usuarioReto.Estado,
                Evidencia = usuarioReto.Evidencia,
                MotivoRechazo = usuarioReto.MotivoRechazo,
                PuntosObtenidos = usuarioReto.PuntosObtenidos,
                ExperienciaRecompensaReto = reto.ExperienciaRecompensa,
                MonedasRecompensaReto = reto.MonedasRecompensa,
                FechaInicio = usuarioReto.FechaInicio,
                FechaCompletado = usuarioReto.FechaCompletado
            });
        }

        [HttpPost]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(RetoResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Crear([FromBody] CrearRetoRequestDto dto)
        {
            if (await _categoriaService.ObtenerPorIdAsync(dto.CategoriaId) is null)
                return NotFound(new { mensaje = $"No se encontro la categoria con id {dto.CategoriaId}." });

            var reto = new Reto
            {
                CategoriaId = dto.CategoriaId,
                Titulo = dto.Titulo.Trim(),
                Descripcion = dto.Descripcion.Trim(),
                Instrucciones = dto.Instrucciones.Trim(),
                ExperienciaRecompensa = dto.ExperienciaRecompensa,
                MonedasRecompensa = dto.MonedasRecompensa,
                Dificultad = dto.Dificultad.Trim().ToUpper(),
                FechaInicio = dto.FechaInicio,
                FechaFin = dto.FechaFin,
                Estado = "ACTIVO"
            };
            reto = await _retoService.CrearAsync(reto);
            return CreatedAtAction(nameof(ObtenerPorId), new { id = reto.RetoId }, await ConvertirAsync(reto));
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(typeof(RetoResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Actualizar(int id, [FromBody] ActualizarRetoRequestDto dto)
        {
            var reto = await _retoService.ObtenerPorIdAsync(id);
            if (reto is null)
                return NotFound(new { mensaje = $"No se encontro el reto con id {id}." });

            if (dto.CategoriaId != reto.CategoriaId && await _categoriaService.ObtenerPorIdAsync(dto.CategoriaId) is null)
                return NotFound(new { mensaje = $"No se encontro la categoria con id {dto.CategoriaId}." });

            reto.CategoriaId = dto.CategoriaId;
            reto.Titulo = dto.Titulo.Trim();
            reto.Descripcion = dto.Descripcion.Trim();
            reto.Instrucciones = dto.Instrucciones.Trim();
            reto.ExperienciaRecompensa = dto.ExperienciaRecompensa;
            reto.MonedasRecompensa = dto.MonedasRecompensa;
            reto.Dificultad = dto.Dificultad.Trim().ToUpper();
            reto.FechaInicio = dto.FechaInicio;
            reto.FechaFin = dto.FechaFin;
            reto.Estado = dto.Estado.Trim().ToUpper();

            var actualizado = await _retoService.ActualizarAsync(reto);
            if (actualizado is null)
                return NotFound(new { mensaje = $"No se encontro el reto con id {id}." });

            return Ok(await ConvertirAsync(actualizado));
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "ADMIN")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Eliminar(int id)
        {
            var ok = await _retoService.EliminarAsync(id);
            if (!ok)
                return NotFound(new { mensaje = $"No se encontro el reto con id {id}." });
            return NoContent();
        }

        private async Task<IEnumerable<RetoResponseDto>> ConvertirListaAsync(IEnumerable<Reto> retos)
        {
            var lista = new List<RetoResponseDto>();
            foreach (var reto in retos)
                lista.Add(await ConvertirAsync(reto));
            return lista;
        }

        private async Task<RetoResponseDto> ConvertirAsync(Reto reto)
        {
            var categoria = await _categoriaService.ObtenerPorIdAsync(reto.CategoriaId);
            return new RetoResponseDto
            {
                RetoId = reto.RetoId,
                Codigo = reto.Codigo,
                CategoriaId = reto.CategoriaId,
                NombreCategoria = categoria?.NombreCategoria ?? string.Empty,
                Titulo = reto.Titulo,
                Descripcion = reto.Descripcion,
                Instrucciones = reto.Instrucciones,
                ExperienciaRecompensa = reto.ExperienciaRecompensa,
                MonedasRecompensa = reto.MonedasRecompensa,
                Dificultad = reto.Dificultad,
                FechaInicio = reto.FechaInicio,
                FechaFin = reto.FechaFin,
                Estado = reto.Estado,
                Subcategoria = reto.Subcategoria,
                Tipo = reto.Tipo,
                TiempoMin = reto.TiempoMin,
                Materiales = reto.Materiales,
                CantidadObjetivo = reto.CantidadObjetivo,
                Consejos = reto.Consejos,
                Advertencias = reto.Advertencias,
                Requisitos = reto.Requisitos,
                Evidencia = reto.Evidencia,
                Etiquetas = reto.Etiquetas,
                Destacado = reto.Destacado,
                EsDiario = reto.EsDiario,
                EsSemanal = reto.EsSemanal,
                EsEspecial = reto.EsEspecial
            };
        }
    }
}