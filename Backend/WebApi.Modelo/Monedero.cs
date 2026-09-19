namespace WebApi.Modelo
{
    /// <summary>
    /// Saldo actual de Monedas Eco del usuario. Relación 1 a 1 con Usuario.
    /// Fuente única de verdad del saldo; se modifica solo desde MonederoService.
    /// </summary>
    public class Monedero
    {
        public int MonederoId { get; set; }
        public int UsuarioId { get; set; }
        public int Saldo { get; set; }
        public DateTime FechaActualizacion { get; set; }
    }
}
