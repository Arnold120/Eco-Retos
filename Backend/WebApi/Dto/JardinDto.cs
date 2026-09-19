using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class ActualizarJardinRequestDto
    {
        [Range(0, 100, ErrorMessage = "El nivel del jardin debe estar entre 0 y 100.")]
        public int NivelJardin { get; set; } = 1;

        [Range(0, int.MaxValue, ErrorMessage = "Las plantas no pueden ser negativas.")]
        public int Plantas { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Los arboles no pueden ser negativos.")]
        public int Arboles { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Las flores no pueden ser negativas.")]
        public int Flores { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Los puntos del jardin no pueden ser negativos.")]
        public int PuntosJardin { get; set; }
    }

    public class JardinResponseDto
    {
        public int JardinId { get; set; }
        public int UsuarioId { get; set; }
        public int NivelJardin { get; set; }
        public int Plantas { get; set; }
        public int Arboles { get; set; }
        public int Flores { get; set; }
        public int PuntosJardin { get; set; }
    }
}