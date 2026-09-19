namespace WebApi.Modelo
{
    public class Progreso
    {
        public int ProgresoId { get; set; }
        public int UsuarioId { get; set; }
        /// <summary>Experiencia (XP) total. Independiente de las Monedas Eco.</summary>
        public int Experiencia { get; set; }
        public int RetosCompletados { get; set; }
        public int TriviasCompletadas { get; set; }
        public int InsigniasObtenidas { get; set; }
        public int PublicacionesRealizadas { get; set; }
        public int MaterialesObtenidos { get; set; }
        public int NivelActual { get; set; } = 1;
        public decimal PorcentajeProgreso { get; set; }
    }
}
