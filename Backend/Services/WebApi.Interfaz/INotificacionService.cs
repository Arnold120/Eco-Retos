using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface INotificacionService
    {
        Task<IEnumerable<Notificacion>> ObtenerNotificacionesDeUsuarioAsync(int usuarioId);
        Task<IEnumerable<Notificacion>> ObtenerNoLeidasAsync(int usuarioId);
        Task<Notificacion?> ObtenerPorIdAsync(int notificacionId);
        Task<Notificacion> CrearNotificacionAsync(Notificacion notificacion);

        /// <summary>
        /// Crea una notificacion de interaccion social. No genera nada si el
        /// destinatario es el mismo actor (evita auto-notificaciones).
        /// </summary>
        Task CrearInteraccionAsync(
            int destinatarioId,
            int actorUsuarioId,
            string titulo,
            string mensaje,
            string tipo,
            string? referenciaTipo,
            int? referenciaId);
        Task<bool> MarcarComoLeidaAsync(int notificacionId);
        Task<bool> MarcarTodasComoLeidasAsync(int usuarioId);
        Task<int> ContarNoLeidasAsync(int usuarioId);
        Task<bool> EliminarAsync(int notificacionId);
        Task<bool> EliminarTodasAsync(int usuarioId);
    }
}
