namespace WebApi.Dto
{
    public class ProgresoResponseDto
    {
        public int ProgresoId { get; set; }
        public int UsuarioId { get; set; }

        public int Experiencia { get; set; }
        public int RetosCompletados { get; set; }
        public int TriviasCompletadas { get; set; }
        public int InsigniasObtenidas { get; set; }
        public int PublicacionesRealizadas { get; set; }
        public int MaterialesObtenidos { get; set; }
        public int NivelActual { get; set; }
        public decimal PorcentajeProgreso { get; set; }
    }
}