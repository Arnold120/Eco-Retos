using WebApi.Modelo;

namespace WebApi.Interfaz
{
    /// <summary>
    /// Servicio de IA del backend. La clave del proveedor vive en configuración
    /// del servidor (Ia:ApiKey / variable de entorno Ia__ApiKey) y NUNCA se
    /// expone al navegador. Si no hay proveedor configurado o falla la llamada,
    /// cada método cae en las reglas deterministas existentes.
    /// </summary>
    public interface IServicioIA
    {
        /// <summary>Indica si hay un proveedor de IA configurado con clave.</summary>
        bool Configurada { get; }

        /// <summary>Decide la siguiente respuesta del chat de soporte.</summary>
        Task<ReglasSoporteDecision> AnalizarSoporteAsync(ContextoSoporteIA contexto);

        /// <summary>Evalúa la evidencia de un reto. Nunca aprueba por sí sola.</summary>
        Task<EvaluacionIAEvidencia> EvaluarEvidenciaAsync(ContextoEvidenciaIA contexto);

        /// <summary>Analiza un reporte de contenido y recomienda una acción.</summary>
        Task<AnalisisIAReporte> AnalizarReporteAsync(ContextoReporteIA contexto);
    }

    /// <summary>Resultado del chat: mismo contrato que ReglasSoporte.DecisionIA.</summary>
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
        /// <summary>ia | reglas.</summary>
        public string Proveedor { get; set; } = "reglas";
    }
}
