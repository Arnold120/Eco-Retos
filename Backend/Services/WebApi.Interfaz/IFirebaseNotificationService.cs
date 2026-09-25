using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IFirebaseNotificationService
    {
        Task EnviarAsync(Notificacion notificacion);
    }
}
