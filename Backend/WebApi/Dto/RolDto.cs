using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearRolRequestDto
    {
        [Required(ErrorMessage = "El nombre del rol es obligatorio.")]
        [StringLength(100, ErrorMessage = "El nombre del rol no puede superar los 100 caracteres.")]
        public string NombreRol { get; set; } = string.Empty;

        [StringLength(300, ErrorMessage = "La descripcion no puede superar los 300 caracteres.")]
        public string Descripcion { get; set; } = string.Empty;
    }

    public class ActualizarRolRequestDto
    {
        [Required(ErrorMessage = "El nombre del rol es obligatorio.")]
        [StringLength(100, ErrorMessage = "El nombre del rol no puede superar los 100 caracteres.")]
        public string NombreRol { get; set; } = string.Empty;

        [StringLength(300, ErrorMessage = "La descripcion no puede superar los 300 caracteres.")]
        public string Descripcion { get; set; } = string.Empty;
    }

    public class RolResponseDto
    {
        public int RolId { get; set; }
        public string NombreRol { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
    }
}