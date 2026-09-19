using WebApi.Modelo;

namespace WebApi.Interfaz
{






    public interface IServicioIA
    {

        bool Configurada { get; }


        Task<ReglasSoporteDecision> AnalizarSoporteAsync(ContextoSoporteIA contexto);


        Task<EvaluacionIAEvidencia> EvaluarEvidenciaAsync(ContextoEvidenciaIA contexto);


        Task<AnalisisIAReporte> AnalizarReporteAsync(ContextoReporteIA contexto);
    }


    public class ReglasSoporteDecision
    {
        public string MensajeIA { get; set; } = string.Empty;
        public string Estado { get; set; } = "IA_ATENDIENDO";
        public string Categoria { get; set; } = "OTRO";
        public string Prioridad { get; set; } = "NORMAL";
        public bool CrearReporte { get; set; }
        public bool Escalar { get; set; }
        public bool Resolver { get; set; }
        public string? MotivoEscalamiento { get; set; }
        public List<string> Sugerencias { get; set; } = new();

        public string Proveedor { get; set; } = "reglas";
    }
}
