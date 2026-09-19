namespace WebApi.Modelo
{




    public class RetoSincronizacion
    {
        public string Codigo { get; set; } = string.Empty;
        public int CategoriaId { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Instrucciones { get; set; } = string.Empty;

        public int ExperienciaRecompensa { get; set; }

        public int MonedasRecompensa { get; set; }
        public string Dificultad { get; set; } = string.Empty;
        public string Estado { get; set; } = "INICIADO";
        public string? Evidencia { get; set; }

        public int PuntosObtenidos { get; set; }
    }
}