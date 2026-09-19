using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearTriviaRequestDto
    {
        [Required(ErrorMessage = "La categoria es obligatoria.")]
        [Range(1, 7, ErrorMessage = "La categoria debe ser una de las 7 categorias oficiales (1-7).")]
        public int CategoriaId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        [Required(ErrorMessage = "La dificultad es obligatoria.")]
        [StringLength(50, ErrorMessage = "La dificultad no puede superar los 50 caracteres.")]
        public string Dificultad { get; set; } = string.Empty;

        [Range(0, 10000, ErrorMessage = "Los puntos maximos deben estar entre 0 y 10000.")]
        public int PuntosMaximos { get; set; }

        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "ACTIVA";
    }

    public class ActualizarTriviaRequestDto
    {
        [Required(ErrorMessage = "La categoria es obligatoria.")]
        [Range(1, 7, ErrorMessage = "La categoria debe ser una de las 7 categorias oficiales (1-7).")]
        public int CategoriaId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        [Required(ErrorMessage = "La dificultad es obligatoria.")]
        [StringLength(50, ErrorMessage = "La dificultad no puede superar los 50 caracteres.")]
        public string Dificultad { get; set; } = string.Empty;

        [Range(0, 10000, ErrorMessage = "Los puntos maximos deben estar entre 0 y 10000.")]
        public int PuntosMaximos { get; set; }

        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "ACTIVA";
    }

    public class TriviaResponseDto
    {
        public int TriviaId { get; set; }
        public int CategoriaId { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Dificultad { get; set; } = string.Empty;
        public int PuntosMaximos { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}