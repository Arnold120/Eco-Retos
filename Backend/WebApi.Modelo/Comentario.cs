namespace WebApi.Modelo
{
    public class Comentario
    {
        public int ComentarioId { get; set; }
        public int PublicacionId { get; set; }
        public int UsuarioId { get; set; }
        public string ComentarioTexto { get; set; } = string.Empty;
        public DateTime FechaComentario { get; set; }
        public int? ComentarioPadreId { get; set; }
        public bool Editado { get; set; }

        public string Estado { get; set; } = "ACTIVO";
    }
}
