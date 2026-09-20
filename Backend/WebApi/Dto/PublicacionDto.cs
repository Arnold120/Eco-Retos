using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class MultimediaDto
    {
        [Required(ErrorMessage = "La URL es obligatoria.")]
        [StringLength(500, ErrorMessage = "La URL no puede superar los 500 caracteres.")]
        public string Url { get; set; } = string.Empty;

        [StringLength(20, ErrorMessage = "El tipo no puede superar los 20 caracteres.")]
        public string Tipo { get; set; } = "imagen";

        [StringLength(20, ErrorMessage = "La duracion no puede superar los 20 caracteres.")]
        public string? Duracion { get; set; }


        [StringLength(500, ErrorMessage = "La portada no puede superar los 500 caracteres.")]
        public string? Poster { get; set; }
    }

    public class CrearPublicacionRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        public string Contenido { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La imagen no puede superar los 500 caracteres.")]
        public string? Imagen { get; set; }

        [Required(ErrorMessage = "El tipo es obligatorio.")]
        [StringLength(50, ErrorMessage = "El tipo no puede superar los 50 caracteres.")]
        public string Tipo { get; set; } = "GENERAL";

        [StringLength(200, ErrorMessage = "La ubicacion no puede superar los 200 caracteres.")]
        public string? Ubicacion { get; set; }

        [StringLength(50, ErrorMessage = "La categoria no puede superar los 50 caracteres.")]
        public string? Categoria { get; set; }


        [StringLength(20, ErrorMessage = "La visibilidad no puede superar los 20 caracteres.")]
        public string Visibilidad { get; set; } = "PUBLICO";


        public int? CompartidoDeId { get; set; }

        public List<MultimediaDto>? Multimedia { get; set; }
    }

    public class ActualizarPublicacionRequestDto
    {
        public string Contenido { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La imagen no puede superar los 500 caracteres.")]
        public string? Imagen { get; set; }

        [StringLength(50, ErrorMessage = "El tipo no puede superar los 50 caracteres.")]
        public string Tipo { get; set; } = "GENERAL";

        [StringLength(50, ErrorMessage = "El estado no puede superar los 50 caracteres.")]
        public string Estado { get; set; } = "PUBLICADA";

        [StringLength(200, ErrorMessage = "La ubicacion no puede superar los 200 caracteres.")]
        public string? Ubicacion { get; set; }

        [StringLength(50, ErrorMessage = "La categoria no puede superar los 50 caracteres.")]
        public string? Categoria { get; set; }


        [StringLength(20, ErrorMessage = "La visibilidad no puede superar los 20 caracteres.")]
        public string Visibilidad { get; set; } = "PUBLICO";

        public List<MultimediaDto>? Multimedia { get; set; }
    }

    public class PublicacionResponseDto
    {
        public int PublicacionId { get; set; }
        public int UsuarioId { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string? FotoPerfil { get; set; }
        public string Contenido { get; set; } = string.Empty;
        public string? Imagen { get; set; }
        public string Tipo { get; set; } = string.Empty;
        public DateTime FechaPublicacion { get; set; }
        public string Estado { get; set; } = string.Empty;
        public string? Ubicacion { get; set; }
        public string? Categoria { get; set; }
        public string Visibilidad { get; set; } = "PUBLICO";
        public bool Editada { get; set; }
        public DateTime? FechaEdicion { get; set; }

        public int CantidadLikes { get; set; }
        public bool MeGusta { get; set; }
        public bool Guardada { get; set; }
        public int CantidadComentarios { get; set; }
        public int CantidadCompartidos { get; set; }

        public int? CompartidoDeId { get; set; }
        public string? CompartidoDeNombreUsuario { get; set; }
        public string? CompartidoDeContenido { get; set; }
        public string? CompartidoDeImagen { get; set; }
        public bool CompartidoEliminado { get; set; }

        public List<MultimediaDto> Multimedia { get; set; } = new();
    }
}
