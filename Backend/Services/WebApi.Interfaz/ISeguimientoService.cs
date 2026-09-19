namespace WebApi.Interfaz
{
    public interface ISeguimientoService
    {
        /// <summary>Sigue a un usuario. Devuelve true si la relacion quedo activa.</summary>
        Task<bool> SeguirAsync(int seguidorId, int seguidoId);

        /// <summary>Deja de seguir a un usuario. Devuelve true si la relacion fue eliminada.</summary>
        Task<bool> DejarDeSeguirAsync(int seguidorId, int seguidoId);

        Task<bool> EstaSiguiendoAsync(int seguidorId, int seguidoId);
        Task<int> ContarSeguidoresAsync(int usuarioId);
        Task<int> ContarSeguidosAsync(int usuarioId);
        Task<IEnumerable<int>> ObtenerIdsSeguidosAsync(int seguidorId);
        Task<IEnumerable<int>> ObtenerIdsSeguidoresAsync(int usuarioId);
    }
}
