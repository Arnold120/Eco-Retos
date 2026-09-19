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

        /// <summary>Devuelve la conversacion existente entre dos usuarios o crea una nueva.</summary>
        Task<int> ObtenerOCrearConversacionAsync(int usuarioA, int usuarioB);

        Task<bool> EsParticipanteAsync(int conversacionId, int usuarioId);

        Task<IEnumerable<Mensaje>> ObtenerMensajesAsync(int conversacionId, int? antesDeMensajeId, int limite);

        Task<Mensaje> EnviarMensajeAsync(int conversacionId, int remitenteId, string contenido);

        Task<bool> MarcarLeidosAsync(int conversacionId, int usuarioId);

        Task<int> ContarNoLeidosAsync(int usuarioId);

        /// <summary>Marca como leidos los mensajes de la conversacion y devuelve el usuario destinatario.</summary>
        Task<int?> ObtenerOtroParticipanteAsync(int conversacionId, int usuarioId);
    }
}
