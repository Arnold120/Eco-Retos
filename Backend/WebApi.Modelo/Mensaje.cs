namespace WebApi.Modelo
{
    public class Mensaje
    {
        public int MensajeId { get; set; }
        public int ConversacionId { get; set; }
        public int RemitenteId { get; set; }
        public string Contenido { get; set; } = string.Empty;
        public DateTime Fecha { get; set; }
        public bool Leido { get; set; }
    }
}
