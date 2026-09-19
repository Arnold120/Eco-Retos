namespace WebApi.Modelo
{
    public class Usuario
    {
        public int UsuarioId { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
        public string Correo { get; set; } = string.Empty;
        public string Contrasena { get; set; } = string.Empty;
        public byte[]? Salt { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime FechaRegistro { get; set; }
    }
}
