namespace WebApi.Modelo
{
    /// <summary>
    /// Registro de recompensas ya reclamadas. La clave es única por usuario y
    /// evita entregar dos veces la recompensa de un reto, trivia o insignia.
    /// </summary>
    public class RecompensaReclamada
    {
        public int RecompensaId { get; set; }
        public int UsuarioId { get; set; }
        public string Clave { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        public DateTime Fecha { get; set; }
    }
}
