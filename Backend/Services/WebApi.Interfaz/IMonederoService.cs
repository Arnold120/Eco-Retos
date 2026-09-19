using Microsoft.Data.SqlClient;
using WebApi.Modelo;

namespace WebApi.Interfaz
{
    /// <summary>
    /// Servicio centralizado del saldo de Monedas Eco. Toda modificación del
    /// saldo pasa por aquí (nunca se hace "Saldo += x" en otros servicios).
    /// </summary>
    public interface IMonederoService
    {
        /// <summary>Crea el monedero del usuario si no existe (saldo 0).</summary>
        Task CrearMonederoAsync(int usuarioId);

        Task<Monedero?> ObtenerMonederoAsync(int usuarioId);

        Task<int> ObtenerSaldoAsync(int usuarioId);

        Task<IEnumerable<HistorialMoneda>> ObtenerHistorialAsync(int usuarioId, int? cantidad = null);

        /// <summary>Totales de monedas (ganadas/gastadas) agrupados por categoría.</summary>
        Task<IEnumerable<CategoriaMonedas>> ObtenerPorCategoriaAsync(int usuarioId);

        /// <summary>
        /// Suma monedas y registra el movimiento. Cantidad debe ser mayor a cero.
        /// Si se recibe conexión/transacción, participa de la transacción del llamador.
        /// </summary>
        Task<MovimientoMonedasResultado> AgregarMonedasAsync(
            int usuarioId,
            int cantidad,
            string tipo,
            string descripcion,
            int? categoriaId = null,
            string? claveIdempotencia = null,
            SqlConnection? conexion = null,
            SqlTransaction? transaccion = null);

        /// <summary>
        /// Resta monedas validando el saldo (atómico, anti-concurrencia) y registra
        /// el movimiento. Cantidad debe ser mayor a cero.
        /// </summary>
        Task<MovimientoMonedasResultado> GastarMonedasAsync(
            int usuarioId,
            int cantidad,
            string tipo,
            string descripcion,
            int? categoriaId = null,
            string? claveIdempotencia = null,
            SqlConnection? conexion = null,
            SqlTransaction? transaccion = null);
    }

    /// <summary>Total de monedas por categoría oficial (CategoriaId 0 = sin categoría).</summary>
    public class CategoriaMonedas
    {
        public int CategoriaId { get; set; }
        public int Total { get; set; }
    }
}
