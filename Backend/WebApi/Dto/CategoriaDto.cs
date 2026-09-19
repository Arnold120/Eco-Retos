using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearCategoriaRequestDto
    {
        [Required(ErrorMessage = "El nombre de la categoria es obligatorio.")]
        [StringLength(150, ErrorMessage = "El nombre de la categoria no puede superar los 150 caracteres.")]
        public string NombreCategoria { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La descripcion no puede superar los 500 caracteres.")]
        public string Descripcion { get; set; } = string.Empty;
    }

    public class ActualizarCategoriaRequestDto
    {
        [Required(ErrorMessage = "El nombre de la categoria es obligatorio.")]
        [StringLength(150, ErrorMessage = "El nombre de la categoria no puede superar los 150 caracteres.")]
        public string NombreCategoria { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La descripcion no puede superar los 500 caracteres.")]
        public string Descripcion { get; set; } = string.Empty;
    }

    public class CategoriaResponseDto
    {
        public int CategoriaId { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
    }
}