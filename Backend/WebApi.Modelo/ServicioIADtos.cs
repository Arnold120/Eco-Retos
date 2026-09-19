namespace WebApi.Modelo
{
    /* DTOs del servicio de IA.
       Viven en WebApi.Modelo para que la capa WebApi.Interfaz los use sin
       dependencia circular. El backend llama al proveedor (OpenAI compatible)
       y la web SOLO recibe resultados; ninguna clave viaja al navegador. */

    /// <summary>Evaluación estructurada de la evidencia de un reto.</summary>
    public class EvaluacionIAEvidencia
    {
        public bool Cumple { get; set; }
        public int Confianza { get; set; }
        public bool RequiereRevisionHumana { get; set; } = true;
        public string Motivo { get; set; } = string.Empty;
        public List<string> ElementosFaltantes { get; set; } = new();
        public string Observaciones { get; set; } = string.Empty;
        /// <summary>Proveedor que emitió el análisis: ia | reglas.</summary>
        public string Proveedor { get; set; } = "reglas";
        public DateTime Fecha { get; set; } = DateTime.Now;
    }

    /// <summary>Análisis de un reporte de contenido (moderación).</summary>
    public class AnalisisIAReporte
    {
        public string Recomendacion { get; set; } = "REVISAR";
        public bool PosibleContenidoAdultos { get; set; }
        public int Confianza { get; set; }
        public bool RequiereRevisionHumana { get; set; } = true;
        public string Motivo { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public string CategoriaSugerida { get; set; } = "CONTENIDO";
        /// <summary>Proveedor que emitió el análisis: ia | reglas.</summary>
        public string Proveedor { get; set; } = "reglas";
        public DateTime Fecha { get; set; } = DateTime.Now;
    }

    /// <summary>Contexto que recibe la IA para atender un caso de soporte.</summary>
    public class ContextoSoporteIA
    {
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Categoria { get; set; } = "OTRO";
        public string Estado { get; set; } = "NUEVO";
        public int CantidadMensajesUsuario { get; set; }
        public bool TieneAdjuntos { get; set; }
        public List<MensajeContextoIA> Historial { get; set; } = new();
    }

    public class MensajeContextoIA
    {
        public string Remitente { get; set; } = "USUARIO";
        public string Contenido { get; set; } = string.Empty;
        public List<string> Adjuntos { get; set; } = new();
    }

    /// <summary>Contexto que recibe la IA para validar una evidencia de reto.</summary>
    public class ContextoEvidenciaIA
    {
        public int UsuarioRetoId { get; set; }
        public string RetoTitulo { get; set; } = string.Empty;
        public string RetoDescripcion { get; set; } = string.Empty;
        public string RetoInstrucciones { get; set; } = string.Empty;
        public string RetoRequisitos { get; set; } = string.Empty;
        /// <summary>Tipo de evidencia solicitada por el reto (FOTO, TEXTO, VIDEO...).</summary>
        public string RetoTipoEvidencia { get; set; } = string.Empty;
        public int? RetoCantidadObjetivo { get; set; }
        public string UsuarioNombre { get; set; } = string.Empty;
        public string UsuarioCorreo { get; set; } = string.Empty;
        public string EvidenciaTexto { get; set; } = string.Empty;
        public List<string> Imagenes { get; set; } = new();
        public List<string> Videos { get; set; } = new();
        public DateTime? FechaCompletado { get; set; }
    }

    /// <summary>Contexto que recibe la IA para analizar un reporte de contenido.</summary>
    public class ContextoReporteIA
    {
        public int ReporteId { get; set; }
        public string? Motivo { get; set; }
        public string? Descripcion { get; set; }
        public string TipoContenido { get; set; } = string.Empty;
        public int? ContenidoId { get; set; }
        public string? ContenidoTexto { get; set; }
        public List<string> ContenidoImagenes { get; set; } = new();
        public string? Enlace { get; set; }
    }
}
