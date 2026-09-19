namespace WebApi.Modelo
{
    public class Jardin
    {
        public int JardinId { get; set; }
        public int UsuarioId { get; set; }
        public int NivelJardin { get; set; } = 1;
        public int Plantas { get; set; }
        public int Arboles { get; set; }
        public int Flores { get; set; }
        public int PuntosJardin { get; set; }
    }
}
