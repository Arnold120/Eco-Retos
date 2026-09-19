namespace WebApi.Modelo
{
    public class Publicacion
    {
        public int PublicacionId { get; set; }
        public int UsuarioId { get; set; }
        public string Contenido { get; set; } = string.Empty;
        public string? Imagen { get; set; }
        public string Tipo { get; set; } = "GENERAL";
        public DateTime FechaPublicacion { get; set; }
        public string Estado { get; set; } = "PUBLICADA";
        public string? Ubicacion { get; set; }
        public string? Categoria { get; set; }
        public int? CompartidoDeId { get; set; }
        public bool CompartidoEliminado { get; set; }
        public string Visibilidad { get; set; } = "PUBLICO";
        public bool Editada { get; set; }
        public DateTime? FechaEdicion { get; set; }
    }
}
