using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IJardinService
    {
        Task<Jardin?> ObtenerJardinDeUsuarioAsync(int usuarioId);
        Task<Jardin> CrearJardinAsync(Jardin jardin);
        Task<bool> ActualizarJardinAsync(Jardin jardin);
        Task<IEnumerable<Jardin>> ObtenerRankingJardinesAsync(int cantidad);
        Task<bool> AgregarPuntosJardinAsync(int usuarioId, int puntos);
    }
}
