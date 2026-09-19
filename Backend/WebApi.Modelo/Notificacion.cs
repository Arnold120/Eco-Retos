namespace WebApi.Modelo
{
    public class Notificacion
    {
        public int NotificacionId { get; set; }
        public int UsuarioId { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        public bool Leida { get; set; }
        public DateTime Fecha { get; set; }
        public string? ReferenciaTipo { get; set; }
        public int? ReferenciaId { get; set; }
        public int? ActorUsuarioId { get; set; }
    }
}
