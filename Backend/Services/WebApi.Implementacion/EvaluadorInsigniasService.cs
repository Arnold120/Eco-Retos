using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    /// <summary>
    /// Evalua el requisito de cada insignia del catalogo contra las metricas reales del
    /// usuario y otorga automaticamente las que aun no posee (INSERT idempotente sobre
    /// UsuarioInsignia + recompensa de monedas). Ejecutar DESPUES de un evento de logro
    /// real (ej. evidencia de reto aprobada/validada por un admin = reto aceptado).
    /// </summary>
    public class EvaluadorInsigniasService : IEvaluadorInsigniasService
    {
        private readonly string _connectionString;
        private readonly IInsigniaService _insigniaService;
        private readonly IUsuarioInsigniaService _usuarioInsigniaService;

        public EvaluadorInsigniasService(
            IConfiguration configuration,
            IInsigniaService insigniaService,
            IUsuarioInsigniaService usuarioInsigniaService)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
            _insigniaService = insigniaService;
            _usuarioInsigniaService = usuarioInsigniaService;
        }

        public async Task<int> EvaluarYOtorgarAsync(int usuarioId)
        {
            var otorgadas = 0;
            var catalogo = await _insigniaService.ObtenerTodasAsync();

            foreach (var insignia in catalogo)
            {
                if (await _usuarioInsigniaService.UsuarioTieneInsigniaAsync(usuarioId, insignia.InsigniaId))
                    continue;

                if (!await CumpleRequisitoAsync(usuarioId, insignia))
                    continue;

                otorgadas += await OtorgarAsync(usuarioId, insignia);
            }
            return otorgadas;
        }

        /// <summary>
        /// Interpreta el campo Requisito (texto libre, ej. "Completa 7 trivias consecutivas",
        /// "Completa 10 retos", "Mantiene una racha de 7 dias", "Gana 100 puntos de experiencia")
        /// contra las estadisticas reales. Devuelve false si el formato no es reconocible.
        /// </summary>
        private async Task<bool> CumpleRequisitoAsync(int usuarioId, Insignia insignia)
        {
            var texto = string.Join(" ",
                new[] { insignia.Requisito, insignia.NombreInsignia, insignia.Descripcion })
                .ToLowerInvariant();

            // Retos validados/aceptados (COMPLETADO se alcanza SOLO tras aprobar la evidencia)
            var matchRetos = System.Text.RegularExpressions.Regex.Match(texto, @"(\d+)\s*retos?\b");
            if (matchRetos.Success)
            {
                var total = await ContarRetosCompletadosAsync(usuarioId);
                return total >= int.Parse(matchRetos.Groups[1].Value);
            }

            // Trivias completadas (intentos finalizados)
            var matchTrivias = System.Text.RegularExpressions.Regex.Match(texto, @"(\d+)\s*trivias?\b(?!\s*consecutivas?)");
            if (matchTrivias.Success)
            {
                var total = await ContarTriviasCompletadasAsync(usuarioId);
                return total >= int.Parse(matchTrivias.Groups[1].Value);
            }

            // Trivias consecutivas (dias calendario consecutivos con trivia finalizada)
            var matchConsecutivas = System.Text.RegularExpressions.Regex.Match(texto, @"(\d+)\s*trivias?\s*consecutivas?\b");
            if (matchConsecutivas.Success)
            {
                var total = await ContarTriviasConsecutivasAsync(usuarioId);
                return total >= int.Parse(matchConsecutivas.Groups[1].Value);
            }

            // Racha de N dias de acceso
            var matchRacha = System.Text.RegularExpressions.Regex.Match(texto, @"racha\s+de\s+(\d+)\s*(?:d[ií]as?\b)?");
            if (matchRacha.Success)
            {
                var racha = await ObtenerRachaActualAsync(usuarioId);
                return racha >= int.Parse(matchRacha.Groups[1].Value);
            }

            // Puntos de experiencia
            var matchExperiencia = System.Text.RegularExpressions.Regex.Match(texto,
                @"(?:gana|acumula|consigue)?\s*(\d+)\s*(?:puntos?|pts?|xp|exp)\s*(?:de\s*experiencia\b)?");
            if (matchExperiencia.Success)
            {
                var experiencia = await ObtenerExperienciaAsync(usuarioId);
                return experiencia >= int.Parse(matchExperiencia.Groups[1].Value);
            }

            // Primer reto / primer logro / novato (cualquier reto ya validado)
            if (texto.Contains("primer reto") || texto.Contains("primer eco") ||
                texto.Contains("novato") || texto.Contains("iniciador") || texto.Contains("un reto"))
            {
                return await ContarRetosCompletadosAsync(usuarioId) >= 1;
            }

            return false;
        }

        private async Task<int> OtorgarAsync(int usuarioId, Insignia insignia)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using (var command = new SqlCommand(
                "INSERT INTO UsuarioInsignia (UsuarioId, InsigniaId, FechaObtencion) " +
                "SELECT @UsuarioId, @InsigniaId, SYSDATETIME() " +
                "WHERE NOT EXISTS (SELECT 1 FROM UsuarioInsignia WHERE UsuarioId = @UsuarioId AND InsigniaId = @InsigniaId)",
                connection))
            {
                command.Parameters.AddWithValue("@UsuarioId", usuarioId);
                command.Parameters.AddWithValue("@InsigniaId", insignia.InsigniaId);
                var filas = await command.ExecuteNonQueryAsync();
                if (filas == 0) return 0;
            }

            if (insignia.MonedasRecompensa > 0)
            {
                using var command = new SqlCommand(
                    "UPDATE Monedero SET Saldo = ISNULL(Saldo, 0) + @Monedas, FechaActualizacion = SYSDATETIME() " +
                    "WHERE UsuarioId = @UsuarioId",
                    connection);
                command.Parameters.AddWithValue("@Monedas", insignia.MonedasRecompensa);
                command.Parameters.AddWithValue("@UsuarioId", usuarioId);
                await command.ExecuteNonQueryAsync();
            }

            return 1;
        }

        private async Task<int> ContarRetosCompletadosAsync(int usuarioId)
        {
            return await EscalarAsync(
                "SELECT COUNT(*) FROM UsuarioReto WHERE UsuarioId = @UsuarioId AND Estado = 'COMPLETADO'",
                usuarioId);
        }

        private async Task<int> ContarTriviasCompletadasAsync(int usuarioId)
        {
            return await EscalarAsync(
                "SELECT COUNT(*) FROM IntentoTrivia WHERE UsuarioId = @UsuarioId AND FechaFinalizacion IS NOT NULL",
                usuarioId);
        }

        private async Task<int> ObtenerRachaActualAsync(int usuarioId)
        {
            return await EscalarAsync(
                "SELECT ISNULL(MAX(NumeroRacha), 0) FROM Racha WHERE UsuarioId = @UsuarioId",
                usuarioId);
        }

        private async Task<int> ObtenerExperienciaAsync(int usuarioId)
        {
            return await EscalarAsync(
                "SELECT ISNULL(Experiencia, 0) FROM Progreso WHERE UsuarioId = @UsuarioId",
                usuarioId);
        }

        private async Task<int> ContarTriviasConsecutivasAsync(int usuarioId)
        {
            var dias = new List<DateTime>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT DISTINCT CONVERT(date, FechaFinalizacion) AS Dia " +
                "FROM IntentoTrivia WHERE UsuarioId = @UsuarioId AND FechaFinalizacion IS NOT NULL ORDER BY Dia",
                connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                dias.Add(reader.GetDateTime(0));

            var racha = 0;
            var mejor = 0;
            for (var i = 0; i < dias.Count; i++)
            {
                if (i > 0 && dias[i].Date == dias[i - 1].Date.AddDays(1))
                    racha++;
                else
                    racha = 1;
                if (racha > mejor) mejor = racha;
            }
            return mejor;
        }

        private async Task<int> EscalarAsync(string sql, int usuarioId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(sql, connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            var valor = await command.ExecuteScalarAsync();
            return valor == null || valor == DBNull.Value ? 0 : Convert.ToInt32(valor);
        }
    }
}
