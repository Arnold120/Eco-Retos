using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IPublicacionService
    {
        Task<IEnumerable<Publicacion>> ObtenerTodasAsync();
        Task<IEnumerable<Publicacion>> ObtenerPublicacionesActivasAsync(int? espectadorId = null);
        Task<IEnumerable<Publicacion>> ObtenerRecientesAsync(int cantidad, int? espectadorId = null);






        Task<IEnumerable<Publicacion>> ObtenerFeedAsync(int pagina, int tamanoPagina, int? autorId, int? seguidosDe, int? espectadorId = null);


        Task<IEnumerable<Publicacion>> BuscarAsync(string termino, int limite, int? espectadorId = null);
        Task<IEnumerable<Publicacion>> ObtenerPorTipoAsync(string tipo, int? espectadorId = null);
        Task<Publicacion?> ObtenerPorIdAsync(int publicacionId);


        Task<Dictionary<int, Publicacion>> ObtenerPorIdsAsync(IEnumerable<int> publicacionIds);
        Task<IEnumerable<Publicacion>> ObtenerPublicacionesDeUsuarioAsync(int usuarioId, int? espectadorId = null);
        Task<IEnumerable<Publicacion>> ObtenerMencionesAsync(int usuarioId, string nombreUsuario, int? espectadorId = null);
        Task<Publicacion> CrearAsync(Publicacion publicacion);
        Task<Publicacion?> ActualizarAsync(Publicacion publicacion);
        Task<bool> EliminarAsync(int publicacionId);
        Task<int> ContarPublicacionesAsync(int usuarioId);


        Task<Dictionary<int, int>> ContarCompartidosAsync(IEnumerable<int> publicacionIds);
    }
}
