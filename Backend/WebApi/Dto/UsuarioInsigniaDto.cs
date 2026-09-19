using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class OtorgarInsigniaRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "La insignia es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La insignia es invalida.")]
        public int InsigniaId { get; set; }
    }

    public class UsuarioInsigniaResponseDto
    {
        public int UsuarioInsigniaId { get; set; }
        public int UsuarioId { get; set; }
        public int InsigniaId { get; set; }
        public DateTime FechaObtencion { get; set; }
        public string NombreInsignia { get; set; } = string.Empty;
    }
}