namespace WebApi.Modelo
{
    public class PublicacionMultimedia
    {
        public int MultimediaId { get; set; }
        public int PublicacionId { get; set; }
        public string Url { get; set; } = string.Empty;
        public string Tipo { get; set; } = "imagen";
        public string? Duracion { get; set; }
        public string? Poster { get; set; }
        public int Orden { get; set; }
        public DateTime FechaCreacion { get; set; }
    }
}
