using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface INotificacionService
    {
        Task<IEnumerable<Notificacion>> ObtenerNotificacionesDeUsuarioAsync(int usuarioId);
        Task<IEnumerable<Notificacion>> ObtenerNoLeidasAsync(int usuarioId);
        Task<Notificacion?> ObtenerPorIdAsync(int notificacionId);
        Task<Notificacion> CrearNotificacionAsync(Notificacion notificacion);





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
