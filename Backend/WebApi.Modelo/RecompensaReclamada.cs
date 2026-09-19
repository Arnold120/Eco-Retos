namespace WebApi.Modelo
{




    public class RecompensaReclamada
    {
        public int RecompensaId { get; set; }
        public int UsuarioId { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        public DateTime Fecha { get; set; }
    }
}
