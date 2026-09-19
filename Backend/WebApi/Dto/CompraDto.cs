using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class DetalleCompraItemRequestDto
    {
        [Required(ErrorMessage = "El material es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El material es invalido.")]
        public int MaterialId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "La cantidad debe ser mayor a cero.")]
        public int Cantidad { get; set; }
    }

    public class CrearCompraRequestDto
    {





        [StringLength(120, ErrorMessage = "La clave de idempotencia no puede superar los 120 caracteres.")]
        public string? ClaveIdempotencia { get; set; }

        [Required(ErrorMessage = "La compra debe incluir detalles.")]
        [MinLength(1, ErrorMessage = "La compra debe incluir al menos un detalle.")]
        public List<DetalleCompraItemRequestDto> Detalles { get; set; } = new();
    }

    public class CompraResponseDto
    {
        public int CompraId { get; set; }
        public int UsuarioId { get; set; }

        public int TotalMonedas { get; set; }

        public int SaldoRestante { get; set; }
        public DateTime FechaCompra { get; set; }
        public string? ClaveIdempotencia { get; set; }
        public List<DetalleCompraResponseDto> Detalles { get; set; } = new();
    }
}
