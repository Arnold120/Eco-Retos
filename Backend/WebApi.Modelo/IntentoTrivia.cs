namespace WebApi.Modelo
{
    public class IntentoTrivia
    {
        public int IntentoId { get; set; }
        public int UsuarioId { get; set; }
        public int TriviaId { get; set; }
        public int Puntuacion { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaFinalizacion { get; set; }
    }
}
