using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class RegistrarParticipacionRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "El reto es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El reto es invalido.")]
        public int RetoId { get; set; }
    }

    public class CompletarRetoRequestDto
    {
        [Range(0, 10000, ErrorMessage = "Los puntos obtenidos deben estar entre 0 y 10000.")]
        public int PuntosObtenidos { get; set; }
    }

    public class RegistrarEvidenciaRequestDto
    {
        [Required(ErrorMessage = "La evidencia es obligatoria.")]
        [StringLength(500, ErrorMessage = "La evidencia no puede superar los 500 caracteres.")]
        public string Evidencia { get; set; } = string.Empty;
    }

    public class RechazarEvidenciaRequestDto
    {
        [Required(ErrorMessage = "El motivo de rechazo es obligatorio.")]
        [StringLength(300, ErrorMessage = "El motivo no puede superar los 300 caracteres.")]
        public string Motivo { get; set; } = string.Empty;
    }

    public class ActualizarEstadoUsuarioRetoRequestDto
    {
        [Required(ErrorMessage = "El estado es obligatorio.")]
        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = string.Empty;
    }

    public class UsuarioRetoResponseDto
    {
        public int UsuarioRetoId { get; set; }
        public int UsuarioId { get; set; }
        public int RetoId { get; set; }
        public string? Codigo { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string TituloReto { get; set; } = string.Empty;
        public string Estado { get; set; } = string.Empty;
        public string? Evidencia { get; set; }
        public string? MotivoRechazo { get; set; }
        public int PuntosObtenidos { get; set; }
        public int ExperienciaRecompensaReto { get; set; }
        public int MonedasRecompensaReto { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaCompletado { get; set; }
    }

    public class SincronizarParticipacionesRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "La lista de participaciones es obligatoria.")]
        [MinLength(1, ErrorMessage = "Debe enviar al menos una participacion.")]
        [MaxLength(300, ErrorMessage = "El lote no puede superar los 300 retos.")]
        public List<SincronizarParticipacionRequestDto> Participaciones { get; set; } = new();
    }

    public class SincronizarParticipacionRequestDto
    {
        [Required(ErrorMessage = "El codigo del reto es obligatorio.")]
        [StringLength(50, ErrorMessage = "El codigo no puede superar los 50 caracteres.")]
        public string Codigo { get; set; } = string.Empty;

        [Required(ErrorMessage = "La categoria es obligatoria.")]
        [Range(1, 7, ErrorMessage = "La categoria debe estar entre 1 y 7 (las 7 categorias oficiales).")]
        public int CategoriaId { get; set; }

        [Required(ErrorMessage = "El titulo es obligatorio.")]
        [StringLength(200, ErrorMessage = "El titulo no puede superar los 200 caracteres.")]
        public string Titulo { get; set; } = string.Empty;

        public string Descripcion { get; set; } = string.Empty;
        public string Instrucciones { get; set; } = string.Empty;

        [Range(0, 10000, ErrorMessage = "La experiencia de recompensa debe estar entre 0 y 10000.")]
        public int ExperienciaRecompensa { get; set; }

        [Range(0, 10000, ErrorMessage = "Las monedas de recompensa deben estar entre 0 y 10000.")]
        public int MonedasRecompensa { get; set; }

        [Required(ErrorMessage = "La dificultad es obligatoria.")]
        [StringLength(50, ErrorMessage = "La dificultad no puede superar los 50 caracteres.")]
        public string Dificultad { get; set; } = string.Empty;

        [Required(ErrorMessage = "El estado es obligatorio.")]
        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La evidencia no puede superar los 500 caracteres.")]
        public string? Evidencia { get; set; }

        [Range(0, 10000, ErrorMessage = "Los puntos obtenidos deben estar entre 0 y 10000.")]
        public int PuntosObtenidos { get; set; }
    }
}