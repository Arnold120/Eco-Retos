using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class RegistrarAccesoRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }
    }

    public class RachaResponseDto
    {
        public int RachaId { get; set; }
        public int UsuarioId { get; set; }
        public DateTime FechaAcceso { get; set; }
        public int NumeroRacha { get; set; }
    }
}