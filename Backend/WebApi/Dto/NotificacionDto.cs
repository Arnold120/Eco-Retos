using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearNotificacionRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        [Required(ErrorMessage = "El mensaje es obligatorio.")]
        public string Mensaje { get; set; } = string.Empty;

        [StringLength(50, ErrorMessage = "El tipo no puede superar los 50 caracteres.")]
        public string Tipo { get; set; } = string.Empty;
    }

    public class NotificacionResponseDto
    {
        public int NotificacionId { get; set; }
        public int UsuarioId { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        public bool Leida { get; set; }
        public DateTime Fecha { get; set; }


        public string? ReferenciaTipo { get; set; }
        public int? ReferenciaId { get; set; }
        public int? ActorUsuarioId { get; set; }
    }
}