using Microsoft.Data.SqlClient;
using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IProgresoService
    {
        Task<Progreso?> ObtenerProgresoDeUsuarioAsync(int usuarioId);


        Task<Progreso> ObtenerOCrearProgresoAsync(int usuarioId);

        Task<Progreso> CrearProgresoAsync(Progreso progreso);
        Task<bool> ActualizarProgresoAsync(Progreso progreso);
        Task<IEnumerable<Progreso>> ObtenerRankingAsync(int cantidad);






        Task<Progreso> AgregarExperienciaAsync(
            int usuarioId,
            int cantidad,
            SqlConnection? conexion = null,
            SqlTransaction? transaccion = null);

        Task<bool> IncrementarRetosCompletadosAsync(int usuarioId);
        Task<bool> IncrementarTriviasCompletadasAsync(int usuarioId);
        Task<bool> IncrementarInsigniasObtenidasAsync(int usuarioId);
        Task<bool> IncrementarPublicacionesRealizadasAsync(int usuarioId);
        Task<bool> IncrementarMaterialesObtenidosAsync(int usuarioId);
    }
}
