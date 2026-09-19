using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearRetoRequestDto
    {
        [Required(ErrorMessage = "La categoria es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La categoria es invalida.")]
        public int CategoriaId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public string Instrucciones { get; set; } = string.Empty;

        [Range(0, 10000, ErrorMessage = "Los puntos deben estar entre 0 y 10000.")]
        public int ExperienciaRecompensa { get; set; }

        public int MonedasRecompensa { get; set; }

        [Required(ErrorMessage = "La dificultad es obligatoria.")]
        [StringLength(50, ErrorMessage = "La dificultad no puede superar los 50 caracteres.")]
        public string Dificultad { get; set; } = string.Empty;

        public DateTime FechaInicio { get; set; } = DateTime.Now;

        public DateTime? FechaFin { get; set; }

        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "ACTIVO";
    }

    public class ActualizarRetoRequestDto
    {
        [Required(ErrorMessage = "La categoria es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La categoria es invalida.")]
        public int CategoriaId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        public string Instrucciones { get; set; } = string.Empty;

        [Range(0, 10000, ErrorMessage = "Los puntos deben estar entre 0 y 10000.")]
        public int ExperienciaRecompensa { get; set; }

        public int MonedasRecompensa { get; set; }

        [Required(ErrorMessage = "La dificultad es obligatoria.")]
        [StringLength(50, ErrorMessage = "La dificultad no puede superar los 50 caracteres.")]
        public string Dificultad { get; set; } = string.Empty;

        public DateTime FechaInicio { get; set; }

        public DateTime? FechaFin { get; set; }

        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "ACTIVO";
    }

    public class RetoResponseDto
    {
        public int RetoId { get; set; }
        public string? Codigo { get; set; }
        public int CategoriaId { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Instrucciones { get; set; } = string.Empty;
        public int ExperienciaRecompensa { get; set; }

        public int MonedasRecompensa { get; set; }
        public string Dificultad { get; set; } = string.Empty;
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public string Estado { get; set; } = string.Empty;

        public string? Subcategoria { get; set; }
        public string? Tipo { get; set; }
        public int? TiempoMin { get; set; }
        public string? Materiales { get; set; }
        public int? CantidadObjetivo { get; set; }
        public string? Consejos { get; set; }
        public string? Advertencias { get; set; }
        public string? Requisitos { get; set; }
        public string? Evidencia { get; set; }
        public string? Etiquetas { get; set; }
        public bool Destacado { get; set; }
        public bool EsDiario { get; set; }
        public bool EsSemanal { get; set; }
        public bool EsEspecial { get; set; }
    }

    /// <summary>Registro automático de un reto del catálogo local en el backend (upsert por Codigo).</summary>
    public class RegistrarRetoCatalogoRequestDto
    {
        [Required(ErrorMessage = "El codigo es obligatorio.")]
        [StringLength(50, ErrorMessage = "El codigo no puede superar los 50 caracteres.")]
        public string Codigo { get; set; } = string.Empty;

        [Required(ErrorMessage = "La categoria es obligatoria.")]
        [Range(1, 7, ErrorMessage = "La categoria debe estar entre 1 y 7 (las 7 categorias oficiales).")]
        public int CategoriaId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;
        public string Instrucciones { get; set; } = string.Empty;

        [Range(0, 10000, ErrorMessage = "Los puntos deben estar entre 0 y 10000.")]
        public int ExperienciaRecompensa { get; set; }

        public int MonedasRecompensa { get; set; }

        [Required(ErrorMessage = "La dificultad es obligatoria.")]
        [StringLength(50, ErrorMessage = "La dificultad no puede superar los 50 caracteres.")]
        public string Dificultad { get; set; } = string.Empty;
    }

    /// <summary>
    /// Verifica (o crea) un reto del catálogo local y lo asigna al usuario en
    /// un solo viaje. El endpoint vive en Retos para que el "push" del reto
    /// sea responsabilidad del módulo de retos.
    /// </summary>
    public class AsignarRetoRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "El codigo es obligatorio.")]
        [StringLength(50, ErrorMessage = "El codigo no puede superar los 50 caracteres.")]
        public string Codigo { get; set; } = string.Empty;

        [Required(ErrorMessage = "La categoria es obligatoria.")]
        [Range(1, 7, ErrorMessage = "La categoria debe estar entre 1 y 7 (las 7 categorias oficiales).")]
        public int CategoriaId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;
        public string Instrucciones { get; set; } = string.Empty;

        [Range(0, 10000, ErrorMessage = "Los puntos deben estar entre 0 y 10000.")]
        public int ExperienciaRecompensa { get; set; }

        public int MonedasRecompensa { get; set; }

        [Required(ErrorMessage = "La dificultad es obligatoria.")]
        [StringLength(50, ErrorMessage = "La dificultad no puede superar los 50 caracteres.")]
        public string Dificultad { get; set; } = string.Empty;

        /// <summary>Estado final de la participación: INICIADO, EN_REVISION o COMPLETADO.</summary>
        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "INICIADO";

        [StringLength(500, ErrorMessage = "La evidencia no puede superar los 500 caracteres.")]
        public string? Evidencia { get; set; }

        [Range(0, 10000, ErrorMessage = "Los puntos obtenidos deben estar entre 0 y 10000.")]
        public int PuntosObtenidos { get; set; }
    }
}