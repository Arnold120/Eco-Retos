using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IInsigniaService
    {
        Task<IEnumerable<Insignia>> ObtenerTodasAsync();
        Task<Insignia?> ObtenerPorIdAsync(int insigniaId);
        Task<Insignia?> ObtenerPorNombreAsync(string nombreInsignia);
        Task<Insignia> CrearAsync(Insignia insignia);
        Task<Insignia?> ActualizarAsync(Insignia insignia);
        Task<bool> EliminarAsync(int insigniaId);
    }
}
