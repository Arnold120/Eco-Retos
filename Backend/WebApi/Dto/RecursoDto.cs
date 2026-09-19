using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearRecursoRequestDto
    {
        [Required(ErrorMessage = "La categoria es obligatoria.")]
        [Range(1, 7, ErrorMessage = "La categoria debe ser una de las 7 categorias oficiales (1-7).")]
        public int CategoriaId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        [Required(ErrorMessage = "El tipo es obligatorio.")]
        [StringLength(50, ErrorMessage = "El tipo no puede superar los 50 caracteres.")]
        public string Tipo { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La URL no puede superar los 500 caracteres.")]
        public string? URL { get; set; }

        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "ACTIVO";
    }

    public class ActualizarRecursoRequestDto
    {
        [Required(ErrorMessage = "La categoria es obligatoria.")]
        [Range(1, 7, ErrorMessage = "La categoria debe ser una de las 7 categorias oficiales (1-7).")]
        public int CategoriaId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;

        [Required(ErrorMessage = "El tipo es obligatorio.")]
        [StringLength(50, ErrorMessage = "El tipo no puede superar los 50 caracteres.")]
        public string Tipo { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La URL no puede superar los 500 caracteres.")]
        public string? URL { get; set; }

        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "ACTIVO";
    }

    public class RecursoResponseDto
    {
        public int RecursoId { get; set; }
        public int CategoriaId { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        public string? URL { get; set; }
        public DateTime FechaPublicacion { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}