using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface ICompraService
    {
        Task<IEnumerable<Compra>> ObtenerComprasDeUsuarioAsync(int usuarioId);
        Task<Compra?> ObtenerPorIdAsync(int compraId);
        Task<Compra> CrearCompraAsync(Compra compra);
        Task<IEnumerable<Compra>> ObtenerRecientesAsync(int usuarioId, int cantidad);

        /// <summary>
        /// Compra completa y transaccional: valida stock contra el catálogo,
        /// cobra con MonederoService (saldo validado en el servidor), crea
        /// Compra y DetalleCompra, actualiza Inventario y descuenta stock.
        /// Todo o nada.
        /// </summary>
        Task<CompraCompletaResultado> CrearCompraCompletaAsync(
            int usuarioId,
            IEnumerable<DetalleCompraSolicitado> detalles,
            string? claveIdempotencia);

        Task<Compra?> ObtenerPorClaveIdempotenciaAsync(int usuarioId, string claveIdempotencia);
    }

    /// <summary>Detalle solicitado por el cliente: solo material y cantidad.</summary>
    public class DetalleCompraSolicitado
    {
        public int MaterialId { get; set; }
        public int Cantidad { get; set; }
    }
}
