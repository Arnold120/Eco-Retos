namespace WebApi.Modelo
{
    public class Compra
    {
        public int CompraId { get; set; }
        public int UsuarioId { get; set; }

        public int TotalMonedas { get; set; }
        public DateTime FechaCompra { get; set; }

        public string? ClaveIdempotencia { get; set; }
    }
}
