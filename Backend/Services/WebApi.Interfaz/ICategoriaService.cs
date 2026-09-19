using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface ICategoriaService
    {
        Task<IEnumerable<Categoria>> ObtenerTodosAsync();
        Task<Categoria?> ObtenerPorIdAsync(int categoriaId);
        Task<Categoria?> ObtenerPorNombreAsync(string nombreCategoria);
        Task<Categoria> CrearAsync(Categoria categoria);
        Task<Categoria?> ActualizarAsync(Categoria categoria);
        Task<bool> EliminarAsync(int categoriaId);
    }
}
