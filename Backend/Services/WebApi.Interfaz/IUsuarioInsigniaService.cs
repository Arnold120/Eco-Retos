using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IUsuarioInsigniaService
    {
        Task<IEnumerable<UsuarioInsignia>> ObtenerInsigniasDeUsuarioAsync(int usuarioId);
        Task<IEnumerable<UsuarioInsignia>> ObtenerTodosAsync();
        Task<UsuarioInsignia> OtorgarInsigniaAsync(UsuarioInsignia usuarioInsignia);
        Task<bool> UsuarioTieneInsigniaAsync(int usuarioId, int insigniaId);
        Task<int> ContarInsigniasAsync(int usuarioId);
    }
}
