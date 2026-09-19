namespace WebApi.Implementacion.Helpers
{




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
