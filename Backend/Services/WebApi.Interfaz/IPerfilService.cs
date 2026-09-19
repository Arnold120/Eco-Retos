using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IPerfilService
    {
        Task<Perfil?> ObtenerPerfilPorUsuarioAsync(int usuarioId);
        Task<Perfil?> ObtenerPorIdAsync(int perfilId);
        Task<Perfil> CrearAsync(Perfil perfil);
        Task<Perfil?> ActualizarAsync(Perfil perfil);
        Task<bool> EliminarAsync(int perfilId);
        Task<IEnumerable<Perfil>> ObtenerPorCentroEducativoAsync(string centroEducativo);


        Task<Dictionary<int, Perfil>> ObtenerPorUsuariosAsync(IEnumerable<int> usuarioIds);
    }
}
