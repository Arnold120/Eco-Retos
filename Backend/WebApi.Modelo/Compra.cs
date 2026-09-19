namespace WebApi.Modelo
{
    public class Compra
    {
        public int CompraId { get; set; }
        public int UsuarioId { get; set; }
        /// <summary>Total pagado en Monedas Eco.</summary>
        public int TotalMonedas { get; set; }
        public DateTime FechaCompra { get; set; }
        /// <summary>Clave opcional para evitar compras duplicadas.</summary>
        public string? ClaveIdempotencia { get; set; }
    }
}
