namespace WebApi.Modelo
{
    public class HistorialPuntos
    {
        public int HistorialId { get; set; }
        public int UsuarioId { get; set; }
        public int? CategoriaId { get; set; }
        public int Puntos { get; set; }
        public string Tipo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public DateTime Fecha { get; set; }
    }
}
