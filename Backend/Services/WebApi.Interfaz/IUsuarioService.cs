using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IUsuarioService
    {
        Task<IEnumerable<Usuario>> ObtenerTodosAsync();
        Task<IEnumerable<Usuario>> ObtenerActivosAsync();
        Task<IEnumerable<Usuario>> ObtenerInactivosAsync();
        Task<Usuario?> ObtenerPorIdAsync(int usuarioId);


        Task<Dictionary<int, Usuario>> ObtenerPorIdsAsync(IEnumerable<int> usuarioIds);
        Task<Usuario?> ObtenerPorCorreoAsync(string correo);
        Task<Usuario?> ObtenerPorNombreUsuarioAsync(string nombreUsuario);
        Task<Usuario> CrearAsync(Usuario usuario);
        Task<Usuario?> ActualizarAsync(Usuario usuario);
        Task<bool> EliminarAsync(int usuarioId);
        Task<bool> ActivarAsync(int usuarioId);
        Task<bool> DesactivarAsync(int usuarioId);
        Task<Usuario?> AutenticarAsync(string correo, string contrasena);
        Task<bool> CambiarContrasenaAsync(int usuarioId, string contrasenaActual, string nuevaContrasena);
        Task<bool> ExisteCorreoAsync(string correo);
        Task<bool> ExisteNombreUsuarioAsync(string nombreUsuario);


        Task<IEnumerable<Usuario>> BuscarAsync(string termino, int limite);
        Task<int> ObtenerTotalActivosAsync();
        Task<int> ObtenerTotalAsync();
    }
}
