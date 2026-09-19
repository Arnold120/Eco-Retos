namespace WebApi.Modelo
{
    public class Recurso
    {
        public int RecursoId { get; set; }
        public int CategoriaId { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        public string? URL { get; set; }
        public DateTime FechaPublicacion { get; set; }
        public string Estado { get; set; } = "ACTIVO";
    }
}
