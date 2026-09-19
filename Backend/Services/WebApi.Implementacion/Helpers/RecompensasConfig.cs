namespace WebApi.Implementacion.Helpers
{
    /// <summary>
    /// Configuración central de recompensas. Las cantidades viven en el backend
    /// (no las decide el cliente).
    /// </summary>
    public static class RecompensasConfig
    {
        public const int XpSemanaCompletada = 100;
        public const int MonedasSemanaCompletada = 50;

        /// <summary>Puntos máximos que puede valer una pregunta de trivia.</summary>
        public const int PuntosMaximosPorPregunta = 100;

        /// <summary>Máximo de preguntas que puede tener una trivia reportada.</summary>
        public const int MaximoPreguntasPorTrivia = 100;

        /// <summary>Trivias: 1 Moneda Eco por cada 10 puntos obtenidos.</summary>
        public static int MonedasPorPuntuacion(int puntuacion)
        {
            return puntuacion <= 0 ? 0 : puntuacion / 10;
        }

        public static int ClampPuntuacion(int puntuacion, int totalPreguntas)
        {
            var maximo = totalPreguntas * PuntosMaximosPorPregunta;
            if (puntuacion < 0) return 0;
            return puntuacion > maximo ? maximo : puntuacion;
        }
    }
}
