using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearMaterialRequestDto
    {
        [Required(ErrorMessage = "El nombre del material es obligatorio.")]
        [StringLength(150, ErrorMessage = "El nombre del material no puede superar los 150 caracteres.")]
        public string NombreMaterial { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La descripcion no puede superar los 500 caracteres.")]
        public string Descripcion { get; set; } = string.Empty;

        [Required(ErrorMessage = "El tipo es obligatorio.")]
        [StringLength(100, ErrorMessage = "El tipo no puede superar los 100 caracteres.")]
        public string Tipo { get; set; } = string.Empty;

        [Range(0, 100000, ErrorMessage = "El precio en Monedas Eco debe estar entre 0 y 100000.")]
        public int PrecioMonedas { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "La cantidad disponible no puede ser negativa.")]
        public int CantidadDisponible { get; set; }

        [StringLength(500, ErrorMessage = "La imagen no puede superar los 500 caracteres.")]
        public string? Imagen { get; set; }

        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "DISPONIBLE";
    }

    public class ActualizarMaterialRequestDto
    {
        [Required(ErrorMessage = "El nombre del material es obligatorio.")]
        [StringLength(150, ErrorMessage = "El nombre del material no puede superar los 150 caracteres.")]
        public string NombreMaterial { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La descripcion no puede superar los 500 caracteres.")]
        public string Descripcion { get; set; } = string.Empty;

        [Required(ErrorMessage = "El tipo es obligatorio.")]
        [StringLength(100, ErrorMessage = "El tipo no puede superar los 100 caracteres.")]
        public string Tipo { get; set; } = string.Empty;

        [Range(0, 100000, ErrorMessage = "El precio en Monedas Eco debe estar entre 0 y 100000.")]
        public int PrecioMonedas { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "La cantidad disponible no puede ser negativa.")]
        public int CantidadDisponible { get; set; }

        [StringLength(500, ErrorMessage = "La imagen no puede superar los 500 caracteres.")]
        public string? Imagen { get; set; }

        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "DISPONIBLE";
    }

    public class MaterialResponseDto
    {
        public int MaterialId { get; set; }
        public string NombreMaterial { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        public int PrecioMonedas { get; set; }
        public int CantidadDisponible { get; set; }
        public string? Imagen { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}
