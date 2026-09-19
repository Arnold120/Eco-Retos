namespace WebApi.Modelo
{
    public class Perfil
    {
        public int PerfilId { get; set; }
        public int UsuarioId { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Apellido { get; set; } = string.Empty;
        public string Carnet { get; set; } = string.Empty;
        public string CentroEducativo { get; set; } = string.Empty;
        public string Grado { get; set; } = string.Empty;
        public string? FotoPerfil { get; set; }
    }
}
