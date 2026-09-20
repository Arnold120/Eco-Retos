using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface ICalificacionService
    {
        Task<List<CalificacionOpinion>> ObtenerOpinionesAsync(int usuarioCalificadoId, int limite = 50, int offset = 0);
        Task<(decimal Promedio, int Total)> ObtenerResumenAsync(int usuarioCalificadoId);
        Task<int?> ObtenerCalificacionPropiaAsync(int espectadorId, int usuarioCalificadoId);
        Task<bool> GuardarAsync(int espectadorId, int usuarioCalificadoId, int calificacion, string? comentario);
        Task<bool> EliminarAsync(int espectadorId, int usuarioCalificadoId);
    }
}