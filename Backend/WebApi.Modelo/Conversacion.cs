namespace WebApi.Modelo
{
    public class Conversacion
    {
        public int ConversacionId { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaUltimoMensaje { get; set; }
    }
}
