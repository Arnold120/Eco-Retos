using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class RegistroRequestDto
    {
        [Required(ErrorMessage = "El nombre de usuario es obligatorio.")]
        [StringLength(200, MinimumLength = 3, ErrorMessage = "El nombre de usuario debe tener entre 3 y 200 caracteres.")]
        public string NombreUsuario { get; set; } = string.Empty;

        [Required(ErrorMessage = "El correo es obligatorio.")]
        [EmailAddress(ErrorMessage = "El correo no tiene un formato valido.")]
        public string Correo { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contrasena es obligatoria.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "La contrasena debe tener al menos 6 caracteres.")]
        public string Contrasena { get; set; } = string.Empty;

        [StringLength(100, ErrorMessage = "El nombre no puede superar los 100 caracteres.")]
        public string Nombre { get; set; } = string.Empty;

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

    public class LoginRequestDto
    {
        [Required(ErrorMessage = "El correo es obligatorio.")]
        [EmailAddress(ErrorMessage = "El correo no tiene un formato valido.")]
        public string Correo { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contrasena es obligatoria.")]
        public string Contrasena { get; set; } = string.Empty;
    }

    public class AuthResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public DateTime ExpiraEn { get; set; }
        public UsuarioResponseDto Usuario { get; set; } = new();
    }
}