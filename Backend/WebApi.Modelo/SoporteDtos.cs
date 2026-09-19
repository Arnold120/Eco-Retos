namespace WebApi.Modelo
{



    public class AdjuntoSoporteDto
    {
        public string Url { get; set; } = string.Empty;
        public string Tipo { get; set; } = "imagen";
        public string Nombre { get; set; } = string.Empty;
    }


    public class CrearCasoRequestDto
    {
        public string Titulo { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public string? Categoria { get; set; }
        public bool Consentimiento { get; set; }
        public string? TerminosVersion { get; set; }
    }

    public class EnviarMensajeSoporteRequestDto
    {
        public string Contenido { get; set; } = string.Empty;
        public List<AdjuntoSoporteDto> Adjuntos { get; set; } = new();
    }

    public class SupportMensajeResponseDto
    {
        public int Id { get; set; }
        public int CasoId { get; set; }
        public string Remitente { get; set; } = "USUARIO";
        public string Contenido { get; set; } = string.Empty;
        public List<AdjuntoSoporteDto> Adjuntos { get; set; } = new();
        public List<string> Sugerencias { get; set; } = new();
        public DateTime Fecha { get; set; }
        public bool Leido { get; set; }
    }

    public class SupportCaseResponseDto
    {
        public int Id { get; set; }
        public int UsuarioId { get; set; }
        public string UsuarioNombre { get; set; } = string.Empty;
        public string Titulo { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public string Categoria { get; set; } = "OTRO";
        public string Prioridad { get; set; } = "NORMAL";
        public string Estado { get; set; } = "NUEVO";
        public bool Consentimiento { get; set; }
        public string? TerminosVersion { get; set; }
        public int? AdminId { get; set; }
        public string? AdminNombre { get; set; }
        public string? MotivoEscalamiento { get; set; }
        public string? Resolucion { get; set; }
        public string? NotasInternas { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime FechaActualizacion { get; set; }
        public DateTime? FechaCierre { get; set; }
    }

    public class DecisionIAResponseDto
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
    }

    public class EnviarMensajeSoporteResponseDto
    {
        public SupportCaseResponseDto? Caso { get; set; }
        public List<SupportMensajeResponseDto> Mensajes { get; set; } = new();
        public DecisionIAResponseDto? Ia { get; set; }
    }


    public class ActualizarCasoAdminRequestDto
    {
        public string? Estado { get; set; }
        public string? Prioridad { get; set; }
        public string? Categoria { get; set; }
        public int? AdminUsuarioId { get; set; }
        public string? MotivoEscalamiento { get; set; }
        public string? Resolucion { get; set; }
        public string? NotasInternas { get; set; }
        public string? RespuestaAdmin { get; set; }
        public List<AdjuntoSoporteDto> Adjuntos { get; set; } = new();
    }


    public class ReporteSoporteResponseDto
    {
        public int Id { get; set; }
        public string Tipo { get; set; } = "DENUNCIA"; 
        public int UsuarioId { get; set; }
        public string UsuarioNombre { get; set; } = string.Empty;
        public string? UsuarioCorreo { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Categoria { get; set; } = "CONTENIDO";
        public string Prioridad { get; set; } = "NORMAL";
        public string Estado { get; set; } = "PENDIENTE";
        public int? PublicacionId { get; set; }
        public int? ComentarioId { get; set; }
        public string? Motivo { get; set; }
        public string? EvidenciaUrl { get; set; }
        public string? Accion { get; set; }
        public int? AdminId { get; set; }
        public string? AdminNombre { get; set; }
        public DateTime Fecha { get; set; }


        public string? ContenidoTipo { get; set; }
        public int? ContenidoId { get; set; }
        public string? ContenidoTexto { get; set; }
        public int? ContenidoAutorId { get; set; }
        public string? ContenidoAutorNombre { get; set; }
        public string? ContenidoAutorCorreo { get; set; }
        public string? ContenidoEstado { get; set; }
        public string? ContenidoImagen { get; set; }
        public List<AdjuntoSoporteDto> ContenidoMultimedia { get; set; } = new();
        public string? Enlace { get; set; }

        public string? MotivoResolucion { get; set; }
        public DateTime? FechaResolucion { get; set; }
        public int? CasoId { get; set; }
    }

    public class ActualizarReporteRequestDto
    {
        public string? Estado { get; set; }
        public string? Accion { get; set; }
        public string? Motivo { get; set; }
    }

    public class ModerarContenidoRequestDto
    {

        public string Objetivo { get; set; } = string.Empty;
        public int Id { get; set; }

        public string Accion { get; set; } = string.Empty;
        public string? Motivo { get; set; }
        public int? ReporteId { get; set; }
    }


    public class EvidenciaSoporteResponseDto
    {
        public int Id { get; set; }
        public int UsuarioId { get; set; }
        public string Usuario { get; set; } = string.Empty;
        public string? UsuarioCorreo { get; set; }
        public int RetoId { get; set; }
        public string Reto { get; set; } = string.Empty;

        public string? RetoDescripcion { get; set; }

        public string? RetoInstrucciones { get; set; }

        public string? RetoRequisitos { get; set; }

        public string? RetoTipoEvidencia { get; set; }
        public int? RetoCantidadObjetivo { get; set; }
        public string Estado { get; set; } = "EN_REVISION";

        public string? Evidencia { get; set; }

        public string? EvidenciaTexto { get; set; }

        public List<AdjuntoSoporteDto> EvidenciaAdjuntos { get; set; } = new();
        public string? MotivoRechazo { get; set; }
        public int PuntosObtenidos { get; set; }
        public DateTime Fecha { get; set; }
        public DateTime? FechaCompletado { get; set; }

        public EvaluacionIAEvidencia? EvaluacionIA { get; set; }
    }

    public class DecidirEvidenciaRequestDto
    {
        public string Estado { get; set; } = "COMPLETADO"; 
        public string? MotivoRechazo { get; set; }
        public int PuntosObtenidos { get; set; }
    }


    public class AdminUsuarioResponseDto
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Correo { get; set; } = string.Empty;
        public string Estado { get; set; } = "ACTIVO";
        public DateTime FechaCreacion { get; set; }
        public DateTime? UltimaActividad { get; set; }
    }

    public class CrearAdminRequestDto
    {
        public string Correo { get; set; } = string.Empty;
        public string? Nombre { get; set; }
        public string? Contrasena { get; set; }
    }

    public class CrearAdminResultDto
    {
        public AdminUsuarioResponseDto? Admin { get; set; }

        public string? ContrasenaTemporal { get; set; }
        public bool UsuarioExistente { get; set; }
    }

    public class CambiarEstadoAdminRequestDto
    {
        public bool Activo { get; set; }
    }


    public class GuardarConfigRequestDto
    {
        public string? TerminosTexto { get; set; }
        public string? TerminosVersion { get; set; }
        public string? AdvertenciaContenido { get; set; }
    }

    public class DashboardSoporteResponseDto
    {
        public int CasosNuevos { get; set; }
        public int Escalados { get; set; }
        public int EnAtencion { get; set; }
        public int Urgencias { get; set; }
        public int ReportesPendientes { get; set; }
        public int EvidenciasPendientes { get; set; }
        public int CasosTotales { get; set; }
        public int AdminsActivos { get; set; }
        public double HorasPromedioResolucion { get; set; }
        public List<SupportCaseResponseDto> UltimosCasos { get; set; } = new();
        public List<SupportAuditLogDto> ActividadReciente { get; set; } = new();
    }






    public class ResumenAdminSoporteResponseDto
    {
        public int CasosNuevos { get; set; }
        public int Escalados { get; set; }
        public int EnAtencion { get; set; }
        public int Urgencias { get; set; }
        public int ReportesPendientes { get; set; }
        public int EvidenciasPendientes { get; set; }
        public int CasosTotales { get; set; }
        public int UltimoCasoId { get; set; }
        public int UltimoReporteId { get; set; }
        public int UltimaEvidenciaId { get; set; }
        public DateTime? UltimoCasoFecha { get; set; }
        public DateTime? UltimoReporteFecha { get; set; }
        public DateTime? UltimaEvidenciaFecha { get; set; }
        public DateTime FechaConsulta { get; set; } = DateTime.Now;

        public string Firma { get; set; } = string.Empty;
    }

    public class SupportAuditLogDto
    {
        public long Id { get; set; }
        public string Actor { get; set; } = "SISTEMA";
        public string Accion { get; set; } = string.Empty;
        public string EntidadTipo { get; set; } = string.Empty;
        public int? EntidadId { get; set; }
        public string? EstadoAnterior { get; set; }
        public string? EstadoNuevo { get; set; }
        public string? Motivo { get; set; }
        public DateTime Fecha { get; set; }
    }

    public class CodigoSesionResponseDto
    {
        public string Codigo { get; set; } = string.Empty;
        public int ExpiraEnSegundos { get; set; }
    }

    public class CanjearCodigoRequestDto
    {
        public string Codigo { get; set; } = string.Empty;
    }
}
