using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IDenunciaService
    {
        Task<Denuncia> CrearAsync(Denuncia denuncia);
        Task<bool> ExisteDenunciaAsync(int usuarioId, int? publicacionId, int? comentarioId);
    }
}
