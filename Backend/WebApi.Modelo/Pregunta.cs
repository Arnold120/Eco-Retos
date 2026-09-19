namespace WebApi.Modelo
{
    public class Pregunta
    {
        public int PreguntaId { get; set; }
        public int TriviaId { get; set; }
        public string PreguntaTexto { get; set; } = string.Empty;
        public int Puntos { get; set; } = 1;
    }
}
