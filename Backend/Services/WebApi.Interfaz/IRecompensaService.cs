using WebApi.Modelo;

namespace WebApi.Interfaz
{






    public interface IRecompensaService
    {
        Task<RecompensaResultado> ReclamarAsync(
            int usuarioId,
            string tipo,
            string claveIdempotencia,
            int? categoriaId = null,
            int? puntuacion = null,
            int? totalPreguntas = null,
            int? retoId = null,
            int? insigniaId = null,
            string? descripcion = null);

        Task<bool> YaReclamadaAsync(int usuarioId, string claveIdempotencia);
    }
}
