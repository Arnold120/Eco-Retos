namespace WebApi.Modelo
{
    public class Denuncia
    {
        public int DenunciaId { get; set; }
        public int UsuarioId { get; set; }
        public int? PublicacionId { get; set; }
        public int? ComentarioId { get; set; }
        public string Motivo { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public string Estado { get; set; } = "PENDIENTE";
        public DateTime Fecha { get; set; }

        /* Resolución administrativa (columnas agregadas por Soporte_Mejoras.sql) */
        public string? Accion { get; set; }
        public string? MotivoResolucion { get; set; }
        public int? AdminUsuarioId { get; set; }
        public DateTime? FechaResolucion { get; set; }
        public string? EvidenciaUrl { get; set; }
        public string ReporteOrigen { get; set; } = "APP";
    }
}
