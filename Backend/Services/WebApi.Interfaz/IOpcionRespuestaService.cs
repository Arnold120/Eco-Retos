using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IOpcionRespuestaService
    {
        Task<IEnumerable<OpcionRespuesta>> ObtenerPorPreguntaAsync(int preguntaId);
        Task<OpcionRespuesta?> ObtenerPorIdAsync(int opcionId);
        Task<OpcionRespuesta> CrearAsync(OpcionRespuesta opcion);
        Task<OpcionRespuesta?> ActualizarAsync(OpcionRespuesta opcion);
        Task<bool> EliminarAsync(int opcionId);
    }
}
