namespace WebApi.Modelo
{
    /// <summary>
    /// Item de sincronizacion de un reto del catalogo local: si el reto no
    /// existe en la base se crea (por Codigo) y se asigna al usuario.
    /// </summary>
    public class RetoSincronizacion
    {
        public string Codigo { get; set; } = string.Empty;
        public int CategoriaId { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Instrucciones { get; set; } = string.Empty;
        /// <summary>XP que otorga el reto (config del catálogo).</summary>
        public int ExperienciaRecompensa { get; set; }
        /// <summary>Monedas Eco que otorga el reto (config del catálogo).</summary>
        public int MonedasRecompensa { get; set; }
        public string Dificultad { get; set; } = string.Empty;
        public string Estado { get; set; } = "INICIADO";
        public string? Evidencia { get; set; }
        /// <summary>XP efectivamente reconocida al aprobar la evidencia (informativo).</summary>
        public int PuntosObtenidos { get; set; }
    }
}