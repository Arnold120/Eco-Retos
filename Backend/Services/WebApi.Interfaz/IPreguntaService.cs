using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IPreguntaService
    {
        Task<IEnumerable<Pregunta>> ObtenerPorTriviaAsync(int triviaId);
        Task<Pregunta?> ObtenerPorIdAsync(int preguntaId);
        Task<Pregunta> CrearAsync(Pregunta pregunta);
        Task<Pregunta?> ActualizarAsync(Pregunta pregunta);
        Task<bool> EliminarAsync(int preguntaId);
        Task<IEnumerable<Pregunta>> ObtenerConOpcionesAsync(int triviaId);
    }
}
