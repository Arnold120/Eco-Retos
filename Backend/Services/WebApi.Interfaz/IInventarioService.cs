using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IInventarioService
    {
        Task<IEnumerable<Inventario>> ObtenerInventarioDeUsuarioAsync(int usuarioId);
        Task<Inventario?> ObtenerPorMaterialAsync(int usuarioId, int materialId);
        Task<Inventario> AgregarMaterialAsync(Inventario inventario);
        Task<bool> ActualizarCantidadAsync(int inventarioId, int cantidad);
        Task<bool> QuitarMaterialAsync(int usuarioId, int materialId);
    }
}
