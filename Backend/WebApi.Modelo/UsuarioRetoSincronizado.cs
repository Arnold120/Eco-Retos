namespace WebApi.Modelo
{




    public class UsuarioRetoSincronizado
    {
        public UsuarioReto UsuarioReto { get; set; } = new UsuarioReto();
        public string? Codigo { get; set; }
        public string TituloReto { get; set; } = string.Empty;
        public int ExperienciaRecompensaReto { get; set; }
        public int MonedasRecompensaReto { get; set; }
    }
}