using WebApi.Modelo;

namespace WebApi.Interfaz
{
    public interface IRespuestaUsuarioService
    {
        Task<IEnumerable<RespuestaUsuario>> ObtenerRespuestasDeIntentoAsync(int intentoId);
        Task<RespuestaUsuario> RegistrarRespuestaAsync(RespuestaUsuario respuesta);
        Task<int> ContarCorrectasAsync(int intentoId);
    }
}
