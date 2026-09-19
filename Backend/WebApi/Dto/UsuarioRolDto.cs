using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class AsignarRolRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "El rol es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El rol es invalido.")]
        public int RolId { get; set; }
    }

    public class UsuarioRolResponseDto
    {
        public int UsuarioRolId { get; set; }
        public int UsuarioId { get; set; }
        public int RolId { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string NombreRol { get; set; } = string.Empty;
    }
}