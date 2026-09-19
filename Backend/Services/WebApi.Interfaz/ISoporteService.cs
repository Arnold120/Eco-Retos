using WebApi.Modelo;

namespace WebApi.Interfaz
{





    public interface ISoporteService
    {
        Task<Dictionary<string, string>> ObtenerConfigAsync();
        Task GuardarConfigAsync(GuardarConfigRequestDto dto, int adminUsuarioId, string adminNombre);

        Task<SupportCaseResponseDto> CrearCasoAsync(int usuarioId, string nombreUsuario, CrearCasoRequestDto dto);
        Task<IEnumerable<SupportCaseResponseDto>> ObtenerCasosUsuarioAsync(int usuarioId);
        Task<SupportCase?> ObtenerCasoAsync(int casoId);
        Task<IEnumerable<SupportMensajeResponseDto>> ObtenerMensajesAsync(int casoId);
        Task<EnviarMensajeSoporteResponseDto> AgregarMensajeUsuarioAsync(int casoId, int usuarioId, EnviarMensajeSoporteRequestDto dto);
        Task MarcarLeidosAsync(int casoId, bool porAdmin);

        Task<IEnumerable<SupportCaseResponseDto>> ObtenerCasosAdminAsync(string? estado, string? prioridad, string? categoria, string? q);
        Task<SupportCaseResponseDto?> ActualizarCasoAdminAsync(int casoId, ActualizarCasoAdminRequestDto dto, int adminUsuarioId, string adminNombre);

        Task<DashboardSoporteResponseDto> ObtenerDashboardAsync();


        Task<ResumenAdminSoporteResponseDto> ObtenerResumenAdminAsync();

        Task<IEnumerable<ReporteSoporteResponseDto>> ObtenerReportesAsync(string? estado);
        Task<ReporteSoporteResponseDto?> ObtenerReporteAsync(int denunciaId);
        Task<bool> ActualizarReporteAsync(int denunciaId, ActualizarReporteRequestDto dto, int adminUsuarioId, string adminNombre);
        Task<bool> ModerarContenidoAsync(ModerarContenidoRequestDto dto, int adminUsuarioId, string adminNombre);

        Task<AnalisisIAReporte?> AnalizarReporteAsync(int denunciaId);

        Task<IEnumerable<EvidenciaSoporteResponseDto>> ObtenerEvidenciasAsync(string? estado);
        Task<EvidenciaSoporteResponseDto?> ObtenerEvidenciaAsync(int usuarioRetoId);
        Task<bool> DecidirEvidenciaAsync(int usuarioRetoId, DecidirEvidenciaRequestDto dto, int adminUsuarioId, string adminNombre);

        Task<EvaluacionIAEvidencia?> AnalizarEvidenciaAsync(int usuarioRetoId);

        Task<IEnumerable<AdminUsuarioResponseDto>> ObtenerAdminsAsync();
        Task<CrearAdminResultDto> CrearAdminAsync(CrearAdminRequestDto dto, int adminUsuarioId, string adminNombre);
        Task<bool> CambiarEstadoAdminAsync(int usuarioId, bool activo, int adminUsuarioId, string adminNombre);
        Task<bool> QuitarAdminAsync(int usuarioId, int adminUsuarioId, string adminNombre);

        Task NotificarAdminsAsync(int casoId, string titulo, string mensaje, string tipo);

        Task NotificarAdminsReporteAsync(int denunciaId, string usuarioNombre, string motivo);
    }
}
