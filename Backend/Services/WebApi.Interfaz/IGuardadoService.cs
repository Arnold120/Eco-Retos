namespace WebApi.Interfaz
{
    public interface IGuardadoService
    {

        Task<bool> AlternarAsync(int usuarioId, int publicacionId);

        Task<IEnumerable<int>> ObtenerIdsGuardadosAsync(int usuarioId);
    }
}
