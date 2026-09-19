namespace WebApi.Implementacion.Helpers
{
    /// <summary>
    /// Cálculo único de nivel y porcentaje a partir de la experiencia (XP).
    /// Misma regla que usa la app: 100 XP por nivel.
    /// </summary>
    public static class ProgresoCalculator
    {
        public const int XpPorNivel = 100;

        public static (int Nivel, decimal Porcentaje) Calcular(int experiencia)
        {
            var xp = experiencia < 0 ? 0 : experiencia;
            var nivel = (xp / XpPorNivel) + 1;
            var porcentaje = (decimal)(xp % XpPorNivel);
            return (nivel, porcentaje);
        }
    }
}
