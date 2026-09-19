namespace WebApi.Interfaz
{
    public interface ISeguimientoService
    {

        Task<bool> SeguirAsync(int seguidorId, int seguidoId);


        Task<bool> DejarDeSeguirAsync(int seguidorId, int seguidoId);

        Task<bool> EstaSiguiendoAsync(int seguidorId, int seguidoId);
        Task<int> ContarSeguidoresAsync(int usuarioId);
        Task<int> ContarSeguidosAsync(int usuarioId);
        Task<IEnumerable<int>> ObtenerIdsSeguidosAsync(int seguidorId);
        Task<IEnumerable<int>> ObtenerIdsSeguidoresAsync(int usuarioId);
    }
}
