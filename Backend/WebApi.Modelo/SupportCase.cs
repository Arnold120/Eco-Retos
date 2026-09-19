namespace WebApi.Modelo
{





    public class SupportCase
    {
        public int SupportCaseId { get; set; }
        public int UsuarioId { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public string Categoria { get; set; } = "OTRO";
        public string Prioridad { get; set; } = "NORMAL";
        public string Estado { get; set; } = "NUEVO";
        public bool Consentimiento { get; set; }
        public DateTime? FechaConsentimiento { get; set; }
        public string? TerminosVersion { get; set; }
        public int? AdminUsuarioId { get; set; }
        public string? AdminNombre { get; set; }
        public string? MotivoEscalamiento { get; set; }
        public string? Resolucion { get; set; }
        public string? NotasInternas { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime FechaActualizacion { get; set; }
        public DateTime? FechaCierre { get; set; }
        public string? UsuarioNombre { get; set; }

        public bool EsReporte { get; set; }
    }
}
