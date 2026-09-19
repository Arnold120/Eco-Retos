namespace WebApi.Modelo
{
    /// <summary>
    /// Resultado de una sincronizacion: la participacion del usuario junto con
    /// los datos del reto ya cargados (sin re-consultar la base por item).
    /// </summary>
    public class UsuarioRetoSincronizado
    {
        public UsuarioReto UsuarioReto { get; set; } = new UsuarioReto();
        public string? Codigo { get; set; }
        public string TituloReto { get; set; } = string.Empty;
        public int ExperienciaRecompensaReto { get; set; }
        public int MonedasRecompensaReto { get; set; }
    }
}