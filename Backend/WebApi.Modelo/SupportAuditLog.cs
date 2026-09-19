namespace WebApi.Modelo
{

    public class SupportAuditLog
    {
        public long AuditLogId { get; set; }
        public int? ActorUsuarioId { get; set; }
        public string ActorTipo { get; set; } = "USUARIO";
        public string Accion { get; set; } = string.Empty;
        public string EntidadTipo { get; set; } = string.Empty;
        public int? EntidadId { get; set; }
        public string? EstadoAnterior { get; set; }
        public string? EstadoNuevo { get; set; }
        public string? Motivo { get; set; }
        public string? MetadataJson { get; set; }
        public DateTime Fecha { get; set; }
        public string? ActorNombre { get; set; }
    }
}
