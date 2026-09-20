using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public class ConversacionResumen
    {
        public Conversacion Conversacion { get; set; } = new();
        public Usuario OtroUsuario { get; set; } = new();
        public string? UltimoMensaje { get; set; }
        public DateTime? FechaUltimoMensaje { get; set; }
        public int NoLeidos { get; set; }
    }

    public interface IMensajeService
    {
        Task<IEnumerable<ConversacionResumen>> ObtenerConversacionesAsync(int usuarioId);


        Task<int> ObtenerOCrearConversacionAsync(int usuarioA, int usuarioB);

        Task<bool> EsParticipanteAsync(int conversacionId, int usuarioId);

        Task<IEnumerable<Mensaje>> ObtenerMensajesAsync(int conversacionId, int usuarioId, int? antesDeMensajeId, int limite);

        Task<Mensaje> EnviarMensajeAsync(
            int conversacionId,
            int remitenteId,
            string contenido,
            string? tipo = null,
            string? archivoUrl = null,
            int? publicacionId = null,
            int? respuestaAId = null);

        Task<Mensaje?> EditarMensajeAsync(int conversacionId, int mensajeId, int usuarioId, string contenido);

        Task<bool> EliminarMensajeAsync(int conversacionId, int mensajeId, int usuarioId, bool paraTodos);

        Task<bool> MarcarLeidosAsync(int conversacionId, int usuarioId);

        Task<int> ContarNoLeidosAsync(int usuarioId);


        Task<int?> ObtenerOtroParticipanteAsync(int conversacionId, int usuarioId);
    }
}
