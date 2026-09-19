namespace WebApi.Modelo
{
    public class Material
    {
        public int MaterialId { get; set; }
        public string NombreMaterial { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Tipo { get; set; } = string.Empty;
        /// <summary>Precio de venta en Monedas Eco.</summary>
        public int PrecioMonedas { get; set; }
        public int CantidadDisponible { get; set; }
        public string? Imagen { get; set; }
        public string Estado { get; set; } = "DISPONIBLE";
    }
}
