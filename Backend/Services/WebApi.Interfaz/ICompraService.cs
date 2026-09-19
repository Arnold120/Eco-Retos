using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface ICompraService
    {
        Task<IEnumerable<Compra>> ObtenerComprasDeUsuarioAsync(int usuarioId);
        Task<Compra?> ObtenerPorIdAsync(int compraId);
        Task<Compra> CrearCompraAsync(Compra compra);
        Task<IEnumerable<Compra>> ObtenerRecientesAsync(int usuarioId, int cantidad);







        Task<CompraCompletaResultado> CrearCompraCompletaAsync(
            int usuarioId,
            IEnumerable<DetalleCompraSolicitado> detalles,
            string? claveIdempotencia);

        Task<Compra?> ObtenerPorClaveIdempotenciaAsync(int usuarioId, string claveIdempotencia);
    }


    public class DetalleCompraSolicitado
    {
        public int MaterialId { get; set; }
        public int Cantidad { get; set; }
    }
}
