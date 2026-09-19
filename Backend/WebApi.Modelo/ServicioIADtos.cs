namespace WebApi.Modelo
{





    public class EvaluacionIAEvidencia
    {
        public bool Cumple { get; set; }
        public int Confianza { get; set; }
        public bool RequiereRevisionHumana { get; set; } = true;
        public string Motivo { get; set; } = string.Empty;
        public List<string> ElementosFaltantes { get; set; } = new();
        public string Observaciones { get; set; } = string.Empty;

        public string Proveedor { get; set; } = "reglas";
        public DateTime Fecha { get; set; } = DateTime.Now;
    }


    public class AnalisisIAReporte
    {
        public string Recomendacion { get; set; } = "REVISAR";
        public bool PosibleContenidoAdultos { get; set; }
        public int Confianza { get; set; }
        public bool RequiereRevisionHumana { get; set; } = true;
        public string Motivo { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public string CategoriaSugerida { get; set; } = "CONTENIDO";

        public string Proveedor { get; set; } = "reglas";
        public DateTime Fecha { get; set; } = DateTime.Now;
    }


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


    public class ContextoEvidenciaIA
    {
        public int UsuarioRetoId { get; set; }
        public string RetoTitulo { get; set; } = string.Empty;
        public string RetoDescripcion { get; set; } = string.Empty;
        public string RetoInstrucciones { get; set; } = string.Empty;
        public string RetoRequisitos { get; set; } = string.Empty;

        public string RetoTipoEvidencia { get; set; } = string.Empty;
        public int? RetoCantidadObjetivo { get; set; }
        public string UsuarioNombre { get; set; } = string.Empty;
        public string UsuarioCorreo { get; set; } = string.Empty;
        public string EvidenciaTexto { get; set; } = string.Empty;
        public List<string> Imagenes { get; set; } = new();
        public List<string> Videos { get; set; } = new();
        public DateTime? FechaCompletado { get; set; }
    }


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
