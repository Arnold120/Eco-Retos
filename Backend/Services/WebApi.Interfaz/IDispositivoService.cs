using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IDispositivoService
    {
        Task<UsuarioDispositivo> RegistrarAsync(UsuarioDispositivo dispositivo);
        Task<IEnumerable<UsuarioDispositivo>> ObtenerActivosAsync(int usuarioId);
        Task<bool> DesactivarAsync(int usuarioId, string token);
    }
}
