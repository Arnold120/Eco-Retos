using WebApi.Modelo;

namespace WebApi.Interfaz
{

    public interface IAuditoriaService
    {
        Task RegistrarAsync(
            int? actorUsuarioId,
            string actorTipo,
            string accion,
            string entidadTipo,
            int? entidadId,
            string? estadoAnterior,
            string? estadoNuevo,
            string? motivo,
            string? metadataJson = null);

        Task<IEnumerable<SupportAuditLog>> ObtenerAsync(string? entidadTipo = null, int limite = 300);
    }
}
