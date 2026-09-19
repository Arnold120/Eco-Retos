namespace WebApi.Modelo
{
    public class RespuestaUsuario
    {
        public int RespuestaId { get; set; }
        public int IntentoId { get; set; }
        public int PreguntaId { get; set; }
        public int OpcionId { get; set; }
        public bool EsCorrecta { get; set; }
    }
}
