using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearDetalleCompraRequestDto
    {
        [Required(ErrorMessage = "La compra es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La compra es invalida.")]
        public int CompraId { get; set; }

        [Required(ErrorMessage = "El material es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El material es invalido.")]
        public int MaterialId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "La cantidad debe ser mayor a cero.")]
        public int Cantidad { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "El precio unitario en Monedas Eco no puede ser negativo.")]
        public int PrecioUnitarioMonedas { get; set; }
    }

    public class DetalleCompraResponseDto
    {
        public int DetalleCompraId { get; set; }
        public int CompraId { get; set; }
        public int MaterialId { get; set; }
        public int Cantidad { get; set; }
        public int PrecioUnitarioMonedas { get; set; }
        public string NombreMaterial { get; set; } = string.Empty;
    }
}
