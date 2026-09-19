namespace WebApi.Modelo
{
    /// <summary>
    /// Resultado de la agregación de puntos por categoria oficial (Ids 1-7).
    /// CategoriaId = 0 agrupa los movimientos sin categoria asociada.
    /// </summary>
    public class CategoriaPuntos
    {
        public int CategoriaId { get; set; }
        public int Puntos { get; set; }
    }
}