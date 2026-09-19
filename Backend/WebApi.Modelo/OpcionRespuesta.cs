namespace WebApi.Modelo
{
    public class OpcionRespuesta
    {
        public int OpcionId { get; set; }
        public int PreguntaId { get; set; }
        public string TextoOpcion { get; set; } = string.Empty;
        public bool EsCorrecta { get; set; }
    }
}
