using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IRetoService
    {
        Task<IEnumerable<Reto>> ObtenerTodosAsync();
        Task<Reto?> ObtenerPorIdAsync(int retoId);
        Task<Reto?> ObtenerPorCodigoAsync(string codigo);
        Task<IEnumerable<Reto>> ObtenerActivosAsync();
        Task<IEnumerable<Reto>> ObtenerPorCategoriaAsync(int categoriaId);
        Task<IEnumerable<Reto>> ObtenerPorDificultadAsync(string dificultad);
        Task<IEnumerable<Reto>> ObtenerPorEstadoAsync(string estado);
        Task<Reto> CrearAsync(Reto reto);
        Task<Reto?> ActualizarAsync(Reto reto);
        Task<bool> EliminarAsync(int retoId);





        Task<Reto> ObtenerOCrearPorCodigoAsync(
            string codigo,
            int categoriaId,
            string titulo,
            string descripcion,
            string instrucciones,
            int experienciaRecompensa,
            int monedasRecompensa,
            string dificultad);
    }
}
