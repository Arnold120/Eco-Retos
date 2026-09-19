using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IIntentoTriviaService
    {
        Task<IEnumerable<IntentoTrivia>> ObtenerIntentosDeUsuarioAsync(int usuarioId);
        Task<IEnumerable<IntentoTrivia>> ObtenerPorTriviaAsync(int triviaId);
        Task<IntentoTrivia?> ObtenerPorIdAsync(int intentoId);
        Task<IntentoTrivia> IniciarIntentoAsync(IntentoTrivia intento);
        Task<bool> FinalizarIntentoAsync(int intentoId, int puntuacion);
        Task<int?> ObtenerMejorPuntuacionAsync(int usuarioId, int triviaId);
    }
}
