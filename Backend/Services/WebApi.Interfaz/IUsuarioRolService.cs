using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IUsuarioRolService
    {
        Task<IEnumerable<UsuarioRol>> ObtenerTodosAsync();
        Task<IEnumerable<UsuarioRol>> ObtenerRolesPorUsuarioAsync(int usuarioId);
        Task<IEnumerable<UsuarioRol>> ObtenerUsuariosPorRolAsync(int rolId);
        Task<UsuarioRol> AsignarRolAsync(UsuarioRol usuarioRol);
        Task<bool> QuitarRolAsync(int usuarioId, int rolId);
        Task<bool> UsuarioTieneRolAsync(int usuarioId, int rolId);
    }
}
