namespace WebApi.Modelo
{
    public class Racha
    {
        public int RachaId { get; set; }
        public int UsuarioId { get; set; }
        public DateTime FechaAcceso { get; set; }
        public int NumeroRacha { get; set; } = 1;
    }
}
