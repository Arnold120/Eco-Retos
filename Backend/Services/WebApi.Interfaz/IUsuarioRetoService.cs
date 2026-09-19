using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IUsuarioRetoService
    {
        Task<IEnumerable<UsuarioReto>> ObtenerRetosDeUsuarioAsync(int usuarioId);
        Task<IEnumerable<UsuarioReto>> ObtenerActivosDeUsuarioAsync(int usuarioId);
        Task<IEnumerable<UsuarioReto>> ObtenerCompletadosDeUsuarioAsync(int usuarioId);
        Task<IEnumerable<UsuarioReto>> ObtenerEvidenciasPendientesAsync();
        Task<IEnumerable<UsuarioReto>> ObtenerEvidenciasAsync();
        Task<UsuarioReto?> ObtenerPorIdAsync(int usuarioRetoId);
        Task<UsuarioReto?> ObtenerPorUsuarioYRetoAsync(int usuarioId, int retoId);
        Task<UsuarioReto> RegistrarParticipacionAsync(UsuarioReto usuarioReto);
        Task<bool> ActualizarEstadoAsync(int usuarioRetoId, string estado);
        Task<bool> CompletarRetoAsync(int usuarioRetoId, int puntosObtenidos);
        Task<bool> RegistrarEvidenciaAsync(int usuarioRetoId, string evidencia);
        Task<bool> AprobarEvidenciaAsync(int usuarioRetoId, int puntosObtenidos);
        Task<bool> RechazarEvidenciaAsync(int usuarioRetoId, string motivo);
        Task<IEnumerable<UsuarioReto>> ObtenerTodosAsync();







        Task<IEnumerable<UsuarioRetoSincronizado>> SincronizarParticipacionesAsync(
            int usuarioId,
            IEnumerable<RetoSincronizacion> participaciones);
    }
}
