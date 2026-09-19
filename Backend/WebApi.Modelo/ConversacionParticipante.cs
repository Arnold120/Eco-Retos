namespace WebApi.Modelo
{
    public class ConversacionParticipante
    {
        public int ConversacionId { get; set; }
        public int UsuarioId { get; set; }
        public DateTime? FechaUltimoLeido { get; set; }
    }
}
