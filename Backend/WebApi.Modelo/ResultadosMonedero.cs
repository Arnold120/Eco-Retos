namespace WebApi.Modelo
{

    public class MovimientoMonedasResultado
    {
        public bool Exito { get; set; }
        public bool Duplicado { get; set; }
        public string? Mensaje { get; set; }
        public int Saldo { get; set; }
        public HistorialMoneda? Movimiento { get; set; }
    }


    public class RecompensaResultado
    {
        public bool Exito { get; set; }
        public bool Duplicado { get; set; }
        public string? Mensaje { get; set; }
        public int ExperienciaGanada { get; set; }
        public int MonedasGanadas { get; set; }
        public int Saldo { get; set; }
        public int Experiencia { get; set; }
        public int NivelActual { get; set; }
        public decimal PorcentajeProgreso { get; set; }
    }


    public class CompraCompletaResultado
    {
        public bool Exito { get; set; }
        public string? Mensaje { get; set; }
        public int Saldo { get; set; }
        public Compra? Compra { get; set; }
        public List<DetalleCompra> Detalles { get; set; } = new();
    }
}
