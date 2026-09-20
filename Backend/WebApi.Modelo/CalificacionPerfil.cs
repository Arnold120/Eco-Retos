namespace WebApi.Modelo
{
    public class CalificacionPerfil
    {
        public int CalificacionId { get; set; }
        public int UsuarioCalificadoId { get; set; }
        public int UsuarioCalificadorId { get; set; }
        public int Calificacion { get; set; }
        public string? Comentario { get; set; }
        public DateTime Fecha { get; set; }
    }

    public class CalificacionOpinion
    {
        public int UsuarioId { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string? FotoPerfil { get; set; }
        public int Calificacion { get; set; }
        public string? Comentario { get; set; }
        public DateTime Fecha { get; set; }
    }
}