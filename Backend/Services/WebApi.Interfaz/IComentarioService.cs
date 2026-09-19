using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IComentarioService
    {
        Task<IEnumerable<Comentario>> ObtenerComentariosDePublicacionAsync(int publicacionId);
        Task<Comentario?> ObtenerPorIdAsync(int comentarioId);
        Task<Comentario> CrearComentarioAsync(Comentario comentario);
        Task<Comentario?> ActualizarAsync(Comentario comentario);
        Task<bool> EliminarAsync(int comentarioId);
        Task<int> ContarComentariosAsync(int publicacionId);

        /// <summary>Conteo de comentarios por publicacion en una sola consulta.</summary>
        Task<Dictionary<int, int>> ContarPorPublicacionesAsync(IEnumerable<int> publicacionIds);
    }
}
