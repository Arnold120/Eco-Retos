namespace WebApi.Modelo
{




    public class Monedero
    {
        public int MonederoId { get; set; }
        public int UsuarioId { get; set; }
        public int Saldo { get; set; }
        public DateTime FechaActualizacion { get; set; }
    }
}
