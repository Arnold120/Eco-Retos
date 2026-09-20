using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class ReaccionResponseDto
    {
        public bool Activa { get; set; }
        public string Tipo { get; set; } = "ME_GUSTA";
        public int Total { get; set; }
    }

    public class AlternarReaccionRequestDto
    {
        public int? PublicacionId { get; set; }
        public int? ComentarioId { get; set; }

        [StringLength(20, ErrorMessage = "El tipo no puede superar los 20 caracteres.")]
        public string Tipo { get; set; } = "ME_GUSTA";
    }

    public class SeguimientoEstadoDto
    {
        public int UsuarioId { get; set; }
        public bool Siguiendo { get; set; }
        public int Seguidores { get; set; }
        public int Seguidos { get; set; }
    }

    public class CrearDenunciaRequestDto
    {
        public int? PublicacionId { get; set; }
        public int? ComentarioId { get; set; }

        [Required(ErrorMessage = "El motivo es obligatorio.")]
        [StringLength(100, ErrorMessage = "El motivo no puede superar los 100 caracteres.")]
        public string Motivo { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La descripcion no puede superar los 500 caracteres.")]
        public string? Descripcion { get; set; }
    }

    public class CrearConversacionRequestDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }
    }

    public class ConversacionResponseDto
    {
        public int ConversacionId { get; set; }
        public int OtroUsuarioId { get; set; }
        public string OtroNombreUsuario { get; set; } = string.Empty;
        public string? OtroFotoPerfil { get; set; }
        public string? UltimoMensaje { get; set; }
        public DateTime? FechaUltimoMensaje { get; set; }
        public int NoLeidos { get; set; }
    }

    public class EnviarMensajeRequestDto
    {
        [StringLength(2000, ErrorMessage = "El mensaje no puede superar los 2000 caracteres.")]
        public string? Contenido { get; set; }

        public string? Tipo { get; set; }

        public string? ArchivoUrl { get; set; }

        public int? PublicacionId { get; set; }

        public int? RespuestaAId { get; set; }
    }

    public class EditarMensajeRequestDto
    {
        [Required(ErrorMessage = "El mensaje es obligatorio.")]
        [StringLength(2000, MinimumLength = 1, ErrorMessage = "El mensaje debe tener entre 1 y 2000 caracteres.")]
        public string Contenido { get; set; } = string.Empty;
    }

    public class MensajeResponseDto
    {
        public int MensajeId { get; set; }
        public int ConversacionId { get; set; }
        public int RemitenteId { get; set; }
        public string Contenido { get; set; } = string.Empty;
        public DateTime Fecha { get; set; }
        public bool Leido { get; set; }
        public string Tipo { get; set; } = "TEXTO";
        public string? ArchivoUrl { get; set; }
        public int? PublicacionId { get; set; }
        public int? RespuestaAId { get; set; }
        public bool Editado { get; set; }
    }

    public class UsuarioResumenDto
    {
        public int UsuarioId { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string? FotoPerfil { get; set; }
    }

    public class PerfilPublicoResponseDto
    {
        public int UsuarioId { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string? FotoPerfil { get; set; }
        public string? NombreCompleto { get; set; }
        public string? CentroEducativo { get; set; }
        public string? Grado { get; set; }
        public string? Correo { get; set; }
        public int CantidadPublicaciones { get; set; }
        public int CantidadSeguidores { get; set; }
        public int CantidadSeguidos { get; set; }
        public bool Siguiendo { get; set; }
        public bool EsMiPerfil { get; set; }
    }

    public class BusquedaResponseDto
    {
        public List<UsuarioResumenDto> Usuarios { get; set; } = new();
        public List<PublicacionResponseDto> Publicaciones { get; set; } = new();
    }

    public class CalificarPerfilRequestDto
    {
        [Range(1, 5, ErrorMessage = "La calificacion debe estar entre 1 y 5 estrellas.")]
        public int Calificacion { get; set; }

        [StringLength(500, ErrorMessage = "La opinion no puede superar los 500 caracteres.")]
        public string? Comentario { get; set; }
    }

    public class CalificacionOpinionDto
    {
        public int UsuarioId { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string? FotoPerfil { get; set; }
        public int Calificacion { get; set; }
        public string? Comentario { get; set; }
        public DateTime Fecha { get; set; }
    }

    public class ResumenCalificacionesDto
    {
        public decimal Promedio { get; set; }
        public int Total { get; set; }
        public int? CalificacionPropia { get; set; }

        public List<CalificacionOpinionDto> Opiniones { get; set; } = new();
    }
}
