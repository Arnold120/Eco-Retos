namespace WebApi.Interfaz
{
    public interface IReaccionService
    {
        /// <summary>
        /// Alterna la reaccion del usuario sobre una publicacion o un comentario.
        /// Devuelve el estado resultante y el total de reacciones del objetivo.
        /// </summary>
        Task<(bool Activa, string Tipo, int Total)> AlternarAsync(int usuarioId, int? publicacionId, int? comentarioId, string tipo);

        Task<int> ContarPorPublicacionAsync(int publicacionId);
        Task<int> ContarPorComentarioAsync(int comentarioId);

        /// <summary>Conteo de reacciones por publicacion en una sola consulta.</summary>
        Task<Dictionary<int, int>> ContarPorPublicacionesAsync(IEnumerable<int> publicacionIds);

        /// <summary>Conteo de reacciones por comentario en una sola consulta.</summary>
        Task<Dictionary<int, int>> ContarPorComentariosAsync(IEnumerable<int> comentarioIds);

        /// <summary>Ids de publicaciones en las que el usuario reaccionó (para marcar "me gusta").</summary>
        Task<IEnumerable<int>> ObtenerPublicacionesReaccionadasAsync(int usuarioId);

        /// <summary>Ids de comentarios en los que el usuario reaccionó.</summary>
        Task<IEnumerable<int>> ObtenerComentariosReaccionadosAsync(int usuarioId);
    }
}
