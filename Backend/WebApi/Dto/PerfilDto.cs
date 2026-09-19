using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearPerfilRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "El nombre es obligatorio.")]
        [StringLength(100, ErrorMessage = "El nombre no puede superar los 100 caracteres.")]
        public string Nombre { get; set; } = string.Empty;

        [Required(ErrorMessage = "El apellido es obligatorio.")]
        [StringLength(100, ErrorMessage = "El apellido no puede superar los 100 caracteres.")]
        public string Apellido { get; set; } = string.Empty;

        [StringLength(50, ErrorMessage = "El carnet no puede superar los 50 caracteres.")]
        public string? Carnet { get; set; }

        [StringLength(200, ErrorMessage = "El centro educativo no puede superar los 200 caracteres.")]
        public string? CentroEducativo { get; set; }

        [StringLength(100, ErrorMessage = "El grado no puede superar los 100 caracteres.")]
        public string? Grado { get; set; }

        [StringLength(500, ErrorMessage = "La foto de perfil no puede superar los 500 caracteres.")]
        public string? FotoPerfil { get; set; }
    }

    public class ActualizarPerfilRequestDto
    {
        [StringLength(100, ErrorMessage = "El nombre no puede superar los 100 caracteres.")]
        public string? Nombre { get; set; }

        [StringLength(100, ErrorMessage = "El apellido no puede superar los 100 caracteres.")]
        public string? Apellido { get; set; }

        [StringLength(50, ErrorMessage = "El carnet no puede superar los 50 caracteres.")]
        public string? Carnet { get; set; }

        [StringLength(200, ErrorMessage = "El centro educativo no puede superar los 200 caracteres.")]
        public string? CentroEducativo { get; set; }

        [StringLength(100, ErrorMessage = "El grado no puede superar los 100 caracteres.")]
        public string? Grado { get; set; }

        [StringLength(500, ErrorMessage = "La foto de perfil no puede superar los 500 caracteres.")]
        public string? FotoPerfil { get; set; }
    }

    public class PerfilResponseDto
    {
        public int PerfilId { get; set; }
        public int UsuarioId { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Apellido { get; set; } = string.Empty;
        public string? Carnet { get; set; }
        public string? CentroEducativo { get; set; }
        public string? Grado { get; set; }
        public string? FotoPerfil { get; set; }
    }
}