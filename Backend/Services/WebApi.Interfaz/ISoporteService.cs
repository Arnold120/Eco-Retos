using WebApi.Modelo;

namespace WebApi.Interfaz
{
    /// <summary>
    /// Módulo de soporte asistido por IA. Todas las operaciones son aditivas:
    /// usan tablas nuevas (Scripts/Soporte_IA.sql) y reutilizan Usuario, Rol,
    /// UsuarioRol, Notificacion, UsuarioReto, Denuncia, Publicacion y Comentario.
    /// </summary>
    public interface ISoporteService
    {
        /* Configuración */
        Task<Dictionary<string, string>> ObtenerConfigAsync();
        Task GuardarConfigAsync(GuardarConfigRequestDto dto, int adminUsuarioId, string adminNombre);

        /* Casos (usuario) */
        Task<SupportCaseResponseDto> CrearCasoAsync(int usuarioId, string nombreUsuario, CrearCasoRequestDto dto);
        Task<IEnumerable<SupportCaseResponseDto>> ObtenerCasosUsuarioAsync(int usuarioId);
        Task<SupportCase?> ObtenerCasoAsync(int casoId);
        Task<IEnumerable<SupportMensajeResponseDto>> ObtenerMensajesAsync(int casoId);
        Task<EnviarMensajeSoporteResponseDto> AgregarMensajeUsuarioAsync(int casoId, int usuarioId, EnviarMensajeSoporteRequestDto dto);
        Task MarcarLeidosAsync(int casoId, bool porAdmin);

        /* Casos (admin) */
        Task<IEnumerable<SupportCaseResponseDto>> ObtenerCasosAdminAsync(string? estado, string? prioridad, string? categoria, string? q);
        Task<SupportCaseResponseDto?> ActualizarCasoAdminAsync(int casoId, ActualizarCasoAdminRequestDto dto, int adminUsuarioId, string adminNombre);

        /* Dashboard */
        Task<DashboardSoporteResponseDto> ObtenerDashboardAsync();

        /// <summary>Resumen ligero para el sondeo automático del panel.</summary>
        Task<ResumenAdminSoporteResponseDto> ObtenerResumenAdminAsync();

        /* Reportes y moderación */
        Task<IEnumerable<ReporteSoporteResponseDto>> ObtenerReportesAsync(string? estado);
        Task<ReporteSoporteResponseDto?> ObtenerReporteAsync(int denunciaId);
        Task<bool> ActualizarReporteAsync(int denunciaId, ActualizarReporteRequestDto dto, int adminUsuarioId, string adminNombre);
        Task<bool> ModerarContenidoAsync(ModerarContenidoRequestDto dto, int adminUsuarioId, string adminNombre);
        /// <summary>Análisis de IA del reporte. No aplica acciones por sí solo.</summary>
        Task<AnalisisIAReporte?> AnalizarReporteAsync(int denunciaId);

        /* Evidencias de retos */
        Task<IEnumerable<EvidenciaSoporteResponseDto>> ObtenerEvidenciasAsync(string? estado);
        Task<EvidenciaSoporteResponseDto?> ObtenerEvidenciaAsync(int usuarioRetoId);
        Task<bool> DecidirEvidenciaAsync(int usuarioRetoId, DecidirEvidenciaRequestDto dto, int adminUsuarioId, string adminNombre);
        /// <summary>Evalúa la evidencia con IA y guarda el resultado en auditoría.</summary>
        Task<EvaluacionIAEvidencia?> AnalizarEvidenciaAsync(int usuarioRetoId);

        /* Administradores (usuarios reales con rol ADMIN) */
        Task<IEnumerable<AdminUsuarioResponseDto>> ObtenerAdminsAsync();
        Task<CrearAdminResultDto> CrearAdminAsync(CrearAdminRequestDto dto, int adminUsuarioId, string adminNombre);
        Task<bool> CambiarEstadoAdminAsync(int usuarioId, bool activo, int adminUsuarioId, string adminNombre);
        Task<bool> QuitarAdminAsync(int usuarioId, int adminUsuarioId, string adminNombre);

        /* Notificaciones internas */
        Task NotificarAdminsAsync(int casoId, string titulo, string mensaje, string tipo);
        /// <summary>Notifica a los ADMIN activos que llegó un reporte nuevo.</summary>
        Task NotificarAdminsReporteAsync(int denunciaId, string usuarioNombre, string motivo);
    }
}
