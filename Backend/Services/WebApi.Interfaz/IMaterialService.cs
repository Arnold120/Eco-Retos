using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IMaterialService
    {
        Task<IEnumerable<Material>> ObtenerTodosAsync();
        Task<Material?> ObtenerPorIdAsync(int materialId);
        Task<IEnumerable<Material>> ObtenerDisponiblesAsync();
        Task<IEnumerable<Material>> ObtenerPorTipoAsync(string tipo);
        Task<Material> CrearAsync(Material material);
        Task<Material?> ActualizarAsync(Material material);
        Task<bool> EliminarAsync(int materialId);
    }
}
