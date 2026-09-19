using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{
    public class CrearOpcionRequestDto
    {
        [Required(ErrorMessage = "La pregunta es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "La pregunta es invalida.")]
        public int PreguntaId { get; set; }

        [Required(ErrorMessage = "El texto de la opcion es obligatorio.")]
        [StringLength(500, ErrorMessage = "El texto de la opcion no puede superar los 500 caracteres.")]
        public string TextoOpcion { get; set; } = string.Empty;

        public bool EsCorrecta { get; set; }
    }

    public class ActualizarOpcionRequestDto
    {
        [Required(ErrorMessage = "El texto de la opcion es obligatorio.")]
        [StringLength(500, ErrorMessage = "El texto de la opcion no puede superar los 500 caracteres.")]
        public string TextoOpcion { get; set; } = string.Empty;

        public bool EsCorrecta { get; set; }
    }

    public class OpcionRespuestaDto
    {
        public int OpcionId { get; set; }
        public int PreguntaId { get; set; }
        public string TextoOpcion { get; set; } = string.Empty;
        public bool EsCorrecta { get; set; }
    }
}