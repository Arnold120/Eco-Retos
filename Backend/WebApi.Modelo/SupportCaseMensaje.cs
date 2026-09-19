namespace WebApi.Modelo
{
    /// <summary>Mensaje de un caso de soporte (USUARIO, IA o ADMIN).</summary>
    public class SupportCaseMensaje
    {
        public int SupportCaseMensajeId { get; set; }
        public int SupportCaseId { get; set; }
        public string TipoRemitente { get; set; } = "USUARIO";
        public int? RemitenteUsuarioId { get; set; }
        public string Contenido { get; set; } = string.Empty;
        public string? AdjuntosJson { get; set; }
        public string? SugerenciasJson { get; set; }
        public bool Leido { get; set; }
        public DateTime Fecha { get; set; }
    }
}
