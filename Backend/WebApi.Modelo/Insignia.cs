namespace WebApi.Modelo
{
    public class Insignia
    {
        public int InsigniaId { get; set; }
        public string NombreInsignia { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Requisito { get; set; } = string.Empty;
        public string? Imagen { get; set; }

        public int MonedasRecompensa { get; set; }
    }
}
