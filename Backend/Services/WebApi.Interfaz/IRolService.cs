using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IRolService
    {
        Task<IEnumerable<Rol>> ObtenerTodosAsync();
        Task<Rol?> ObtenerPorIdAsync(int rolId);
        Task<Rol?> ObtenerPorNombreAsync(string nombreRol);
        Task<Rol> CrearAsync(Rol rol);
        Task<Rol?> ActualizarAsync(Rol rol);
        Task<bool> EliminarAsync(int rolId);
    }
}
