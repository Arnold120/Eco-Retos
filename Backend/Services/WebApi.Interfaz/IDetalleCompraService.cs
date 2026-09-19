using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IDetalleCompraService
    {
        Task<IEnumerable<DetalleCompra>> ObtenerDetallesDeCompraAsync(int compraId);
        Task<DetalleCompra> CrearDetalleAsync(DetalleCompra detalle);
    }
}
