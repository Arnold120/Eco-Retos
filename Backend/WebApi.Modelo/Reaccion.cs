namespace WebApi.Modelo
{
    public class Reaccion
    {
        public int ReaccionId { get; set; }
        public int? PublicacionId { get; set; }
        public int? ComentarioId { get; set; }
        public int UsuarioId { get; set; }
        public string Tipo { get; set; } = "ME_GUSTA";
        public DateTime Fecha { get; set; }
    }
}
