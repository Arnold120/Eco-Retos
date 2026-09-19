namespace WebApi.Implementacion.Helpers
{




    public static class RecompensasConfig
    {
        public const int XpSemanaCompletada = 100;
        public const int MonedasSemanaCompletada = 50;


        public const int PuntosMaximosPorPregunta = 100;


        public const int MaximoPreguntasPorTrivia = 100;


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
