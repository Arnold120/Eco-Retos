namespace WebApi.Modelo
{
    /// <summary>
    /// Movimiento monetario (auditoría). Cantidad firmada: positiva = ganancia,
    /// negativa = gasto.
    /// </summary>
    public class HistorialMoneda
    {
        public int HistorialMonedaId { get; set; }
        public int UsuarioId { get; set; }
        public int? CategoriaId { get; set; }
        public int Cantidad { get; set; }
        public string Tipo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public int SaldoResultante { get; set; }
        public string? ClaveIdempotencia { get; set; }
        public DateTime Fecha { get; set; }
    }
}
