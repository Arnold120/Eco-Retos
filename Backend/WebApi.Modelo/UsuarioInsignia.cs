namespace WebApi.Modelo
{
    public class UsuarioInsignia
    {
        public int UsuarioInsigniaId { get; set; }
        public int UsuarioId { get; set; }
        public int InsigniaId { get; set; }
        public DateTime FechaObtencion { get; set; }
    }
}
