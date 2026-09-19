using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class RegistrarRespuestaRequestDto
    {
        [Required(ErrorMessage = "El intento es obligatorio.")]
        [Range(1, int.MaxValue, ErrorMessage = "El intento es invalido.")]
        public int IntentoId { get; set; }

        [Required(ErrorMessage = "La pregunta es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La pregunta es invalida.")]
        public int PreguntaId { get; set; }

        [Required(ErrorMessage = "La opcion es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La opcion es invalida.")]
        public int OpcionId { get; set; }

        public bool EsCorrecta { get; set; }
    }

    public class RespuestaUsuarioResponseDto
    {
        public int RespuestaId { get; set; }
        public int IntentoId { get; set; }
        public int PreguntaId { get; set; }
        public int OpcionId { get; set; }
        public bool EsCorrecta { get; set; }
    }
}