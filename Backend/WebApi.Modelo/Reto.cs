namespace WebApi.Modelo
{
    public class Reto
    {
        public int RetoId { get; set; }
        public string? Codigo { get; set; }
        public int CategoriaId { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Instrucciones { get; set; } = string.Empty;

        public int ExperienciaRecompensa { get; set; }

        public int MonedasRecompensa { get; set; }
        public string Dificultad { get; set; } = string.Empty;
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public string Estado { get; set; } = "ACTIVO";


        public string? Subcategoria { get; set; }


        public string? Tipo { get; set; }


        public int? TiempoMin { get; set; }


        public string? Materiales { get; set; }


        public int? CantidadObjetivo { get; set; }


        public string? Consejos { get; set; }


        public string? Advertencias { get; set; }


        public string? Requisitos { get; set; }


        public string? Evidencia { get; set; }


        public string? Etiquetas { get; set; }


        public bool Destacado { get; set; }


        public bool EsDiario { get; set; }


        public bool EsSemanal { get; set; }


        public bool EsEspecial { get; set; }
    }
}
