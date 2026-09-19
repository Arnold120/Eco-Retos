namespace WebApi.Interfaz
{
    public interface IReaccionService
    {




        Task<(bool Activa, string Tipo, int Total)> AlternarAsync(int usuarioId, int? publicacionId, int? comentarioId, string tipo);

        Task<int> ContarPorPublicacionAsync(int publicacionId);
        Task<int> ContarPorComentarioAsync(int comentarioId);


        Task<Dictionary<int, int>> ContarPorPublicacionesAsync(IEnumerable<int> publicacionIds);


        Task<Dictionary<int, int>> ContarPorComentariosAsync(IEnumerable<int> comentarioIds);


        Task<IEnumerable<int>> ObtenerPublicacionesReaccionadasAsync(int usuarioId);


        Task<IEnumerable<int>> ObtenerComentariosReaccionadosAsync(int usuarioId);
    }
}
