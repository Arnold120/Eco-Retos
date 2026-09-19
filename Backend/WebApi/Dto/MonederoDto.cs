using System.ComponentModel.DataAnnotations;

namespace WebApi.Dto
{

    public class MonederoSaldoResponseDto
    {
        public int Saldo { get; set; }
        public int Experiencia { get; set; }
        public int NivelActual { get; set; }
        public int XpEnNivel { get; set; }
        public int XpMaximoNivel { get; set; }
        public decimal PorcentajeProgreso { get; set; }
    }

    public class HistorialMonedaResponseDto
    {
        public int HistorialMonedaId { get; set; }
        public int UsuarioId { get; set; }
        public int? CategoriaId { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;

        public int Cantidad { get; set; }
        public string Tipo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public int SaldoResultante { get; set; }
        public DateTime Fecha { get; set; }
    }


    public class CategoriaMonedasResponseDto
    {
        public int CategoriaId { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;
        public int Total { get; set; }
    }

    public class ReclamarRecompensaRequestDto
    {

        [Required(ErrorMessage = "El tipo de recompensa es obligatorio.")]
        [StringLength(50, ErrorMessage = "El tipo no puede superar los 50 caracteres.")]
        public string Tipo { get; set; } = string.Empty;

        [Required(ErrorMessage = "La clave de idempotencia es obligatoria.")]
        [StringLength(120, ErrorMessage = "La clave no puede superar los 120 caracteres.")]
        public string ClaveIdempotencia { get; set; } = string.Empty;

        [Range(1, 7, ErrorMessage = "La categoría debe estar entre 1 y 7.")]
        public int? CategoriaId { get; set; }


        [Range(0, 100000, ErrorMessage = "La puntuación es inválida.")]
        public int? Puntuacion { get; set; }


        [Range(1, 100, ErrorMessage = "El total de preguntas debe estar entre 1 y 100.")]
        public int? TotalPreguntas { get; set; }


        [Range(1, int.MaxValue, ErrorMessage = "El reto es inválido.")]
        public int? RetoId { get; set; }


        [Range(1, int.MaxValue, ErrorMessage = "La insignia es inválida.")]
        public int? InsigniaId { get; set; }

        [StringLength(500, ErrorMessage = "La descripción no puede superar los 500 caracteres.")]
        public string? Descripcion { get; set; }
    }

    public class ReclamarRecompensaResponseDto
    {
        public bool Duplicado { get; set; }
        public int ExperienciaGanada { get; set; }
        public int MonedasGanadas { get; set; }
        public int Saldo { get; set; }
        public int Experiencia { get; set; }
        public int NivelActual { get; set; }
        public decimal PorcentajeProgreso { get; set; }
    }

    public class GastarMonedasRequestDto
    {
        [Range(1, 1000000, ErrorMessage = "La cantidad debe ser mayor a cero.")]
        public int Cantidad { get; set; }

        [Required(ErrorMessage = "El tipo de gasto es obligatorio.")]
        [StringLength(50, ErrorMessage = "El tipo no puede superar los 50 caracteres.")]
        public string Tipo { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La descripción no puede superar los 500 caracteres.")]
        public string Descripcion { get; set; } = string.Empty;

        [Range(1, 7, ErrorMessage = "La categoría debe estar entre 1 y 7.")]
        public int? CategoriaId { get; set; }

        [StringLength(120, ErrorMessage = "La clave no puede superar los 120 caracteres.")]
        public string? ClaveIdempotencia { get; set; }
    }

    public class GastarMonedasResponseDto
    {
        public int Saldo { get; set; }
        public int Cantidad { get; set; }
    }
}
