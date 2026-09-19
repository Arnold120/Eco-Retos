namespace WebApi.Modelo
{
    public class UsuarioReto
    {
        public int UsuarioRetoId { get; set; }
        public int UsuarioId { get; set; }
        public int RetoId { get; set; }
        public string Estado { get; set; } = "INICIADO";
        public string? Evidencia { get; set; }
        public string? MotivoRechazo { get; set; }
        public int PuntosObtenidos { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaCompletado { get; set; }
    }
}
