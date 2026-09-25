namespace WebApi.Modelo
{
    public class UsuarioDispositivo
    {
        public int UsuarioDispositivoId { get; set; }
        public int UsuarioId { get; set; }
        public string Token { get; set; } = string.Empty;
        public string Plataforma { get; set; } = string.Empty;
        public DateTime FechaRegistro { get; set; }
        public DateTime FechaActualizacion { get; set; }
        public bool Activo { get; set; }
    }
}
