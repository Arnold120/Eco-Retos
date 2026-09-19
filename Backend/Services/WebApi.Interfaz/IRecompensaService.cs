using WebApi.Modelo;

namespace WebApi.Interfaz
{
    /// <summary>
    /// Recompensas de la app. Calcula XP y/o Monedas Eco desde la configuración
    /// del backend (Reto/Insignia/constantes), de forma idempotente y
    /// transaccional, y delega el saldo a IMonederoService y el XP a
    /// IProgresoService.
    /// </summary>
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
