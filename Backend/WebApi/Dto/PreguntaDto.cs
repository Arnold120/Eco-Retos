using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearPreguntaRequestDto
    {
        [Required(ErrorMessage = "La trivia es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La trivia es invalida.")]
        public int TriviaId { get; set; }

        [Required(ErrorMessage = "La pregunta es obligatoria.")]
        public string PreguntaTexto { get; set; } = string.Empty;

        [Range(1, 100, ErrorMessage = "Los puntos deben estar entre 1 y 100.")]
        public int Puntos { get; set; } = 1;
    }

    public class ActualizarPreguntaRequestDto
    {
        [Required(ErrorMessage = "La trivia es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La trivia es invalida.")]
        public int TriviaId { get; set; }

        [Required(ErrorMessage = "La pregunta es obligatoria.")]
        public string PreguntaTexto { get; set; } = string.Empty;

        [Range(1, 100, ErrorMessage = "Los puntos deben estar entre 1 y 100.")]
        public int Puntos { get; set; } = 1;
    }

    public class PreguntaResponseDto
    {
        public int PreguntaId { get; set; }
        public int TriviaId { get; set; }
        public string PreguntaTexto { get; set; } = string.Empty;
        public int Puntos { get; set; }
        public List<OpcionRespuestaDto> Opciones { get; set; } = new();
    }
}