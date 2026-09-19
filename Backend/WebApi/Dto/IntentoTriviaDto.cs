using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class IniciarIntentoRequestDto
    {
        [Required(ErrorMessage = "El usuario es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El usuario es invalido.")]
        public int UsuarioId { get; set; }

        [Required(ErrorMessage = "La trivia es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La trivia es invalida.")]
        public int TriviaId { get; set; }
    }

    public class FinalizarIntentoRequestDto
    {
        [Range(0, 10000, ErrorMessage = "La puntuacion debe estar entre 0 y 10000.")]
        public int Puntuacion { get; set; }
    }

    public class IntentoTriviaResponseDto
    {
        public int IntentoId { get; set; }
        public int UsuarioId { get; set; }
        public int TriviaId { get; set; }
        public string TituloTrivia { get; set; } = string.Empty;
        public int Puntuacion { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaFinalizacion { get; set; }
    }
}