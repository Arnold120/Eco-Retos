namespace WebApi.Modelo
{
    /// <summary>Configuración de soporte (clave/valor): términos, versión, advertencias.</summary>
    public class SoporteConfig
    {
        public string Clave { get; set; } = string.Empty;
        public string Valor { get; set; } = string.Empty;
        public DateTime Actualizado { get; set; }
    }
}
