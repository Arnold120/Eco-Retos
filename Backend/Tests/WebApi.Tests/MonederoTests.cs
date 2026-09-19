using Microsoft.Extensions.Configuration;
using WebApi.Implementacion;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using Xunit;

namespace WebApi.Tests
{
    public class ProgresoCalculatorTests
    {
        [Theory]
        [InlineData(0, 1, 0)]
        [InlineData(1, 1, 1)]
        [InlineData(99, 1, 99)]
        [InlineData(100, 2, 0)]
        [InlineData(250, 3, 50)]
        [InlineData(999, 10, 99)]
        public void Calcular_devuelve_nivel_y_porcentaje(int experiencia, int nivelEsperado, decimal porcentajeEsperado)
        {
            var (nivel, porcentaje) = ProgresoCalculator.Calcular(experiencia);
            Assert.Equal(nivelEsperado, nivel);
            Assert.Equal(porcentajeEsperado, porcentaje);
        }

        [Fact]
        public void Calcular_nunca_es_negativo()
        {
            var (nivel, porcentaje) = ProgresoCalculator.Calcular(-50);
            Assert.Equal(1, nivel);
            Assert.Equal(0, porcentaje);
        }
    }

    public class RecompensasConfigTests
    {
        [Theory]
        [InlineData(150, 15)]
        [InlineData(99, 9)]
        [InlineData(9, 0)]
        [InlineData(0, 0)]
        [InlineData(-20, 0)]
        public void MonedasPorPuntuacion_es_una_por_cada_diez(int puntuacion, int monedasEsperadas)
        {
            Assert.Equal(monedasEsperadas, RecompensasConfig.MonedasPorPuntuacion(puntuacion));
        }

        [Fact]
        public void ClampPuntuacion_limita_al_maximo_de_preguntas()
        {
            Assert.Equal(500, RecompensasConfig.ClampPuntuacion(9999, 5));
            Assert.Equal(0, RecompensasConfig.ClampPuntuacion(-5, 5));
            Assert.Equal(320, RecompensasConfig.ClampPuntuacion(320, 5));
        }
    }

    public class MonederoServiceValidacionesTests
    {
        private static MonederoService CrearServicio()
        {
            var configuration = new ConfigurationBuilder()
                .AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["ConnectionStrings:DefaultConnection"] =
                        "Server=(local);Database=inexistente;Trusted_Connection=true;TrustServerCertificate=true"
                })
                .Build();
            return new MonederoService(configuration);
        }

        [Fact]
        public async Task Agregar_con_cantidad_cero_falla_sin_tocar_la_base()
        {
            var servicio = CrearServicio();
            var resultado = await servicio.AgregarMonedasAsync(1, 0, "TRIVIA", "Prueba");
            Assert.False(resultado.Exito);
            Assert.Contains("mayor a cero", resultado.Mensaje);
        }

        [Fact]
        public async Task Agregar_con_cantidad_negativa_falla()
        {
            var servicio = CrearServicio();
            var resultado = await servicio.AgregarMonedasAsync(1, -100, "TRIVIA", "Prueba");
            Assert.False(resultado.Exito);
        }

        [Fact]
        public async Task Gastar_con_cantidad_cero_falla()
        {
            var servicio = CrearServicio();
            var resultado = await servicio.GastarMonedasAsync(1, 0, "COMPRA", "Prueba");
            Assert.False(resultado.Exito);
        }

        [Fact]
        public async Task Movimiento_con_usuario_invalido_falla()
        {
            var servicio = CrearServicio();
            var resultado = await servicio.AgregarMonedasAsync(0, 10, "TRIVIA", "Prueba");
            Assert.False(resultado.Exito);
        }

        [Fact]
        public async Task Movimiento_sin_tipo_falla()
        {
            var servicio = CrearServicio();
            var resultado = await servicio.AgregarMonedasAsync(1, 10, "  ", "Prueba");
            Assert.False(resultado.Exito);
        }

        [Fact]
        public async Task Movimiento_sin_descripcion_falla()
        {
            var servicio = CrearServicio();
            var resultado = await servicio.AgregarMonedasAsync(1, 10, "TRIVIA", "");
            Assert.False(resultado.Exito);
        }

        [Fact]
        public void CategoriaMonedas_representa_totales_por_categoria()
        {
            var categoria = new CategoriaMonedas { CategoriaId = 3, Total = 250 };
            Assert.Equal(3, categoria.CategoriaId);
            Assert.Equal(250, categoria.Total);
        }
    }
}
