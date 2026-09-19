using Microsoft.Data.SqlClient;
using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IProgresoService
    {
        Task<Progreso?> ObtenerProgresoDeUsuarioAsync(int usuarioId);

        /// <summary>Crea la fila de progreso del usuario si no existe.</summary>
        Task<Progreso> ObtenerOCrearProgresoAsync(int usuarioId);

        Task<Progreso> CrearProgresoAsync(Progreso progreso);
        Task<bool> ActualizarProgresoAsync(Progreso progreso);
        Task<IEnumerable<Progreso>> ObtenerRankingAsync(int cantidad);

        /// <summary>
        /// Suma experiencia (XP) y recalcula nivel/porcentaje en la misma
        /// operación. Cantidad debe ser mayor a cero. Acepta conexión/transacción
        /// para participar de operaciones compuestas (recompensas).
        /// </summary>
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
