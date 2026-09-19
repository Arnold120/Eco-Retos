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
        /// <summary>XP que otorga el reto al completarse.</summary>
        public int ExperienciaRecompensa { get; set; }
        /// <summary>Monedas Eco que otorga el reto al completarse.</summary>
        public int MonedasRecompensa { get; set; }
        public string Dificultad { get; set; } = string.Empty;
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public string Estado { get; set; } = "ACTIVO";

        /// <summary>Subcategoría del catálogo móvil (ubicación, material, temática...).</summary>
        public string? Subcategoria { get; set; }

        /// <summary>Tipo de reto del catálogo móvil (INDIVIDUAL, FOTOGRAFIA, CANTIDAD...).</summary>
        public string? Tipo { get; set; }

        /// <summary>Duración estimada en minutos (catálogo móvil).</summary>
        public int? TiempoMin { get; set; }

        /// <summary>Materiales del catálogo móvil en JSON: [{"nombre":"...","cantidad":n}].</summary>
        public string? Materiales { get; set; }

        /// <summary>Objetivo numérico del reto (¿cuántas unidades?). Nulo si no aplica.</summary>
        public int? CantidadObjetivo { get; set; }

        /// <summary>Consejos del catálogo móvil en JSON (array de strings).</summary>
        public string? Consejos { get; set; }

        /// <summary>Advertencias del catálogo móvil en JSON (array de strings).</summary>
        public string? Advertencias { get; set; }

        /// <summary>Requisitos del catálogo móvil en JSON (array de strings).</summary>
        public string? Requisitos { get; set; }

        /// <summary>Tipo de evidencia solicitada (FOTO, GALERIA, VIDEO, TEXTO, CANTIDAD, RESPUESTA).</summary>
        public string? Evidencia { get; set; }

        /// <summary>Etiquetas del catálogo móvil en JSON (array de strings).</summary>
        public string? Etiquetas { get; set; }

        /// <summary>Reto destacado del catálogo móvil.</summary>
        public bool Destacado { get; set; }

        /// <summary>Elegible como "Reto del día" del catálogo móvil.</summary>
        public bool EsDiario { get; set; }

        /// <summary>Elegible como "Reto semanal" del catálogo móvil.</summary>
        public bool EsSemanal { get; set; }

        /// <summary>Reto especial/evento del catálogo móvil.</summary>
        public bool EsEspecial { get; set; }
    }
}
