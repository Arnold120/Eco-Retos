namespace WebApi.Modelo
{
    public class DetalleCompra
    {
        public int DetalleCompraId { get; set; }
        public int CompraId { get; set; }
        public int MaterialId { get; set; }
        public int Cantidad { get; set; }

        public int PrecioUnitarioMonedas { get; set; }
    }
}
