using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearUsuarioRequestDto
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
    }

    public class ActualizarUsuarioRequestDto
    {
        [Required(ErrorMessage = "El nombre de usuario es obligatorio.")]
        [StringLength(200, MinimumLength = 3, ErrorMessage = "El nombre de usuario debe tener entre 3 y 200 caracteres.")]
        public string NombreUsuario { get; set; } = string.Empty;

        [Required(ErrorMessage = "El correo es obligatorio.")]
        [EmailAddress(ErrorMessage = "El correo no tiene un formato valido.")]
        public string Correo { get; set; } = string.Empty;
    }

    public class CambiarEstadoUsuarioRequestDto
    {
        [Required(ErrorMessage = "El estado es obligatorio.")]
        public bool Activo { get; set; }
    }

    public class CambiarContrasenaRequestDto
    {
        [Required(ErrorMessage = "La contrasena actual es obligatoria.")]
        public string ContrasenaActual { get; set; } = string.Empty;

        [Required(ErrorMessage = "La nueva contrasena es obligatoria.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "La nueva contrasena debe tener al menos 6 caracteres.")]
        public string NuevaContrasena { get; set; } = string.Empty;
    }

    public class DesactivarCuentaRequestDto
    {
        [Required(ErrorMessage = "La contrasena es obligatoria.")]
        public string Contrasena { get; set; } = string.Empty;
    }

    public class UsuarioResponseDto
    {
        public int UsuarioId { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string Correo { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime FechaRegistro { get; set; }
        public IEnumerable<string> Roles { get; set; } = new List<string>();
    }
}