namespace WebApi.Modelo
{
    public class Trivia
    {
        public int TriviaId { get; set; }
        public int CategoriaId { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Dificultad { get; set; } = string.Empty;
        public int PuntosMaximos { get; set; }
        public string Estado { get; set; } = "ACTIVA";
    }
}
