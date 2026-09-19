using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IMultimediaService
    {
        Task<IEnumerable<PublicacionMultimedia>> ObtenerPorPublicacionAsync(int publicacionId);


        Task<Dictionary<int, List<PublicacionMultimedia>>> ObtenerPorPublicacionesAsync(IEnumerable<int> publicacionIds);

        Task ReemplazarAsync(int publicacionId, IEnumerable<PublicacionMultimedia> items);
    }
}
