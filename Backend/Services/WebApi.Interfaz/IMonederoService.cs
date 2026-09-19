using Microsoft.Data.SqlClient;
using WebApi.Modelo;

namespace WebApi.Interfaz
{




    public interface IMonederoService
    {

        Task CrearMonederoAsync(int usuarioId);

        Task<Monedero?> ObtenerMonederoAsync(int usuarioId);

        Task<int> ObtenerSaldoAsync(int usuarioId);

        Task<IEnumerable<HistorialMoneda>> ObtenerHistorialAsync(int usuarioId, int? cantidad = null);


        Task<IEnumerable<CategoriaMonedas>> ObtenerPorCategoriaAsync(int usuarioId);





        Task<MovimientoMonedasResultado> AgregarMonedasAsync(
            int usuarioId,
            int cantidad,
            string tipo,
            string descripcion,
            int? categoriaId = null,
            string? claveIdempotencia = null,
            SqlConnection? conexion = null,
            SqlTransaction? transaccion = null);





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


    public class CategoriaMonedas
    {
        public int CategoriaId { get; set; }
        public int Total { get; set; }
    }
}
