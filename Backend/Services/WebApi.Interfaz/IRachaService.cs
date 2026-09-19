using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IRachaService
    {
        Task<IEnumerable<Racha>> ObtenerHistorialRachasAsync(int usuarioId);
        Task<int> ObtenerRachaActualAsync(int usuarioId);
        Task<Racha> RegistrarAccesoAsync(int usuarioId, DateTime fechaAcceso);
        Task<bool> ActualizarRachaAsync(Racha racha);
        Task<IEnumerable<Racha>> ObtenerTopRachasAsync(int cantidad);
    }
}
