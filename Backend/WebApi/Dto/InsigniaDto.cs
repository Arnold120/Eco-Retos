using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearInsigniaRequestDto
    {
        [Required(ErrorMessage = "El nombre de la insignia es obligatorio.")]
        [StringLength(150, ErrorMessage = "El nombre de la insignia no puede superar los 150 caracteres.")]
        public string NombreInsignia { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La descripcion no puede superar los 500 caracteres.")]
        public string Descripcion { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "El requisito no puede superar los 500 caracteres.")]
        public string Requisito { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La imagen no puede superar los 500 caracteres.")]
        public string? Imagen { get; set; }

        [Range(0, 10000, ErrorMessage = "Las Monedas Eco de recompensa deben estar entre 0 y 10000.")]
        public int MonedasRecompensa { get; set; }
    }

    public class ActualizarInsigniaRequestDto
    {
        [Required(ErrorMessage = "El nombre de la insignia es obligatorio.")]
        [StringLength(150, ErrorMessage = "El nombre de la insignia no puede superar los 150 caracteres.")]
        public string NombreInsignia { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La descripcion no puede superar los 500 caracteres.")]
        public string Descripcion { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "El requisito no puede superar los 500 caracteres.")]
        public string Requisito { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La imagen no puede superar los 500 caracteres.")]
        public string? Imagen { get; set; }

        [Range(0, 10000, ErrorMessage = "Las Monedas Eco de recompensa deben estar entre 0 y 10000.")]
        public int MonedasRecompensa { get; set; }
    }

    public class InsigniaResponseDto
    {
        public int InsigniaId { get; set; }
        public string NombreInsignia { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Requisito { get; set; } = string.Empty;
        public string? Imagen { get; set; }

        public int MonedasRecompensa { get; set; }
    }
}
