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

        /// <summary>
        /// Sincroniza un lote de retos del catalogo local en UNA sola conexion
        /// y UNA transaccion: crea los retos inexistentes (por Codigo), asigna
        /// la participacion al usuario y aplica el estado final de cada item.
        /// Reutilizando la conexion evita el lag de abrir N conexiones por lote.
        /// </summary>
        Task<IEnumerable<UsuarioRetoSincronizado>> SincronizarParticipacionesAsync(
            int usuarioId,
            IEnumerable<RetoSincronizacion> participaciones);
    }
}
