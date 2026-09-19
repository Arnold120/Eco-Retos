using WebApi.Modelo;

namespace WebApi.Interfaz
{
    /// <summary>Auditoría de acciones administrativas y de IA (solo inserción/lectura).</summary>
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
