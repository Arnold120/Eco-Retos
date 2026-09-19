using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IPublicacionService
    {
        Task<IEnumerable<Publicacion>> ObtenerTodasAsync();
        Task<IEnumerable<Publicacion>> ObtenerPublicacionesActivasAsync(int? espectadorId = null);
        Task<IEnumerable<Publicacion>> ObtenerRecientesAsync(int cantidad, int? espectadorId = null);

        /// <summary>
        /// Feed paginado. Si autorId tiene valor, solo publicaciones de ese autor;
        /// si seguidosDe tiene valor, solo de los usuarios que sigue.
        /// Respeta la visibilidad respecto al espectador.
        /// </summary>
        Task<IEnumerable<Publicacion>> ObtenerFeedAsync(int pagina, int tamanoPagina, int? autorId, int? seguidosDe, int? espectadorId = null);

        /// <summary>Busca publicaciones publicadas cuyo contenido coincida con el termino.</summary>
        Task<IEnumerable<Publicacion>> BuscarAsync(string termino, int limite, int? espectadorId = null);
        Task<IEnumerable<Publicacion>> ObtenerPorTipoAsync(string tipo, int? espectadorId = null);
        Task<Publicacion?> ObtenerPorIdAsync(int publicacionId);

        /// <summary>Publicaciones por lote en una sola consulta (clave: PublicacionId).</summary>
        Task<Dictionary<int, Publicacion>> ObtenerPorIdsAsync(IEnumerable<int> publicacionIds);
        Task<IEnumerable<Publicacion>> ObtenerPublicacionesDeUsuarioAsync(int usuarioId, int? espectadorId = null);
        Task<Publicacion> CrearAsync(Publicacion publicacion);
        Task<Publicacion?> ActualizarAsync(Publicacion publicacion);
        Task<bool> EliminarAsync(int publicacionId);
        Task<int> ContarPublicacionesAsync(int usuarioId);

        /// <summary>Conteo de compartidos por publicacion en una sola consulta.</summary>
        Task<Dictionary<int, int>> ContarCompartidosAsync(IEnumerable<int> publicacionIds);
    }
}
