namespace WebApi.Interfaz
{
    public interface IGuardadoService
    {
        /// <summary>Alterna el guardado de una publicacion. Devuelve true si quedo guardada.</summary>
        Task<bool> AlternarAsync(int usuarioId, int publicacionId);

        Task<IEnumerable<int>> ObtenerIdsGuardadosAsync(int usuarioId);
    }
}
