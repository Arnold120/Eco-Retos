using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class AgregarInventarioRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "El material es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El material es invalido.")]
        public int MaterialId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "La cantidad debe ser mayor a cero.")]
        public int Cantidad { get; set; } = 1;
    }

    public class ActualizarCantidadRequestDto
    {
        [Range(0, int.MaxValue, ErrorMessage = "La cantidad no puede ser negativa.")]
        public int Cantidad { get; set; }
    }

    public class InventarioResponseDto
    {
        public int InventarioId { get; set; }
        public int UsuarioId { get; set; }
        public int MaterialId { get; set; }
        public int Cantidad { get; set; }
        public string NombreMaterial { get; set; } = string.Empty;
    }
}