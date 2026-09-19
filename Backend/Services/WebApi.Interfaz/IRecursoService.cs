using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IRecursoService
    {
        Task<IEnumerable<Recurso>> ObtenerTodosAsync();
        Task<Recurso?> ObtenerPorIdAsync(int recursoId);
        Task<IEnumerable<Recurso>> ObtenerActivosAsync();
        Task<IEnumerable<Recurso>> ObtenerPorCategoriaAsync(int categoriaId);
        Task<IEnumerable<Recurso>> ObtenerPorTipoAsync(string tipo);
        Task<Recurso> CrearAsync(Recurso recurso);
        Task<Recurso?> ActualizarAsync(Recurso recurso);
        Task<bool> EliminarAsync(int recursoId);
    }
}
