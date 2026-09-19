using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearComentarioRequestDto
    {
        [Required(ErrorMessage = "La publicacion es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La publicacion es invalida.")]
        public int PublicacionId { get; set; }

        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "El comentario es obligatorio.")]
        public string ComentarioTexto { get; set; } = string.Empty;

        /// <summary>Comentario padre al que responde. Null para comentarios de primer nivel.</summary>
        public int? ComentarioPadreId { get; set; }
    }

    public class ActualizarComentarioRequestDto
    {
        [Required(ErrorMessage = "El comentario es obligatorio.")]
        public string ComentarioTexto { get; set; } = string.Empty;
    }

    public class ComentarioResponseDto
    {
        public int ComentarioId { get; set; }
        public int PublicacionId { get; set; }
        public int UsuarioId { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string? FotoPerfil { get; set; }
        public string ComentarioTexto { get; set; } = string.Empty;
        public DateTime FechaComentario { get; set; }
        public int? ComentarioPadreId { get; set; }
        public bool Editado { get; set; }
        public int CantidadLikes { get; set; }
        public bool MeGusta { get; set; }
    }
}
