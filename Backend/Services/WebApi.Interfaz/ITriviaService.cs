using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface ITriviaService
    {
        Task<IEnumerable<Trivia>> ObtenerTodosAsync();
        Task<Trivia?> ObtenerPorIdAsync(int triviaId);
        Task<IEnumerable<Trivia>> ObtenerActivasAsync();
        Task<IEnumerable<Trivia>> ObtenerPorCategoriaAsync(int categoriaId);
        Task<IEnumerable<Trivia>> ObtenerPorDificultadAsync(string dificultad);
        Task<Trivia> CrearAsync(Trivia trivia);
        Task<Trivia?> ActualizarAsync(Trivia trivia);
        Task<bool> EliminarAsync(int triviaId);
    }
}
