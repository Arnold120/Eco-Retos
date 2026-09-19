using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Modelo;
using WebApi.Interfaz;
using WebApi.Implementacion.Helpers;

namespace WebApi.Implementacion
{
    public class RetoService : IRetoService
    {
        private readonly string _connectionString;

        public RetoService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private const string Columnas = "RetoId, Codigo, CategoriaId, Titulo, Descripcion, Instrucciones, ExperienciaRecompensa, MonedasRecompensa, Dificultad, FechaInicio, FechaFin, Estado, Subcategoria, Tipo, TiempoMin, Materiales, CantidadObjetivo, Consejos, Advertencias, Requisitos, Evidencia, Etiquetas, Destacado, EsDiario, EsSemanal, EsEspecial";

        private static string? NuloOS(string? valor) => string.IsNullOrEmpty(valor) ? null : valor;

        private Reto Mapear(SqlDataReader reader)
        {
            return new Reto
            {
                RetoId = DatabaseHelper.ReadInt(reader, "RetoId"),
                Codigo = reader.IsDBNull(reader.GetOrdinal("Codigo")) ? null : DatabaseHelper.ReadString(reader, "Codigo"),
                CategoriaId = DatabaseHelper.ReadInt(reader, "CategoriaId"),
                Titulo = DatabaseHelper.ReadString(reader, "Titulo"),
                Descripcion = DatabaseHelper.ReadString(reader, "Descripcion"),
                Instrucciones = DatabaseHelper.ReadString(reader, "Instrucciones"),
                ExperienciaRecompensa = DatabaseHelper.ReadInt(reader, "ExperienciaRecompensa"),
                MonedasRecompensa = DatabaseHelper.ReadInt(reader, "MonedasRecompensa"),
                Dificultad = DatabaseHelper.ReadString(reader, "Dificultad"),
                FechaInicio = DatabaseHelper.ReadDateTime(reader, "FechaInicio"),
                FechaFin = DatabaseHelper.ReadNullableDateTime(reader, "FechaFin"),
                Estado = DatabaseHelper.ReadString(reader, "Estado"),
                Subcategoria = !reader.IsDBNull(reader.GetOrdinal("Subcategoria")) ? DatabaseHelper.ReadString(reader, "Subcategoria") : null,
                Tipo = !reader.IsDBNull(reader.GetOrdinal("Tipo")) ? DatabaseHelper.ReadString(reader, "Tipo") : null,
                TiempoMin = DatabaseHelper.ReadNullableInt(reader, "TiempoMin"),
                Materiales = NuloOS(!reader.IsDBNull(reader.GetOrdinal("Materiales")) ? DatabaseHelper.ReadString(reader, "Materiales") : null),
                CantidadObjetivo = DatabaseHelper.ReadNullableInt(reader, "CantidadObjetivo"),
                Consejos = NuloOS(!reader.IsDBNull(reader.GetOrdinal("Consejos")) ? DatabaseHelper.ReadString(reader, "Consejos") : null),
                Advertencias = NuloOS(!reader.IsDBNull(reader.GetOrdinal("Advertencias")) ? DatabaseHelper.ReadString(reader, "Advertencias") : null),
                Requisitos = NuloOS(!reader.IsDBNull(reader.GetOrdinal("Requisitos")) ? DatabaseHelper.ReadString(reader, "Requisitos") : null),
                Evidencia = !reader.IsDBNull(reader.GetOrdinal("Evidencia")) ? DatabaseHelper.ReadString(reader, "Evidencia") : null,
                Etiquetas = NuloOS(!reader.IsDBNull(reader.GetOrdinal("Etiquetas")) ? DatabaseHelper.ReadString(reader, "Etiquetas") : null),
                Destacado = DatabaseHelper.ReadBool(reader, "Destacado"),
                EsDiario = DatabaseHelper.ReadBool(reader, "EsDiario"),
                EsSemanal = DatabaseHelper.ReadBool(reader, "EsSemanal"),
                EsEspecial = DatabaseHelper.ReadBool(reader, "EsEspecial")
            };
        }

        public async Task<IEnumerable<Reto>> ObtenerTodosAsync()
        {
            var lista = new List<Reto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Reto", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Reto?> ObtenerPorIdAsync(int retoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Reto WHERE RetoId = @RetoId", connection);
            command.Parameters.AddWithValue("@RetoId", retoId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<Reto?> ObtenerPorCodigoAsync(string codigo)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Reto WHERE Codigo = @Codigo", connection);
            command.Parameters.AddWithValue("@Codigo", codigo);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? Mapear(reader) : null;
        }

        public async Task<IEnumerable<Reto>> ObtenerActivosAsync()
        {
            var lista = new List<Reto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Reto WHERE Estado = 'ACTIVO'", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Reto>> ObtenerPorCategoriaAsync(int categoriaId)
        {
            var lista = new List<Reto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Reto WHERE CategoriaId = @CategoriaId", connection);
            command.Parameters.AddWithValue("@CategoriaId", categoriaId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Reto>> ObtenerPorDificultadAsync(string dificultad)
        {
            var lista = new List<Reto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Reto WHERE Dificultad = @Dificultad", connection);
            command.Parameters.AddWithValue("@Dificultad", dificultad);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<IEnumerable<Reto>> ObtenerPorEstadoAsync(string estado)
        {
            var lista = new List<Reto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand($"SELECT {Columnas} FROM Reto WHERE Estado = @Estado", connection);
            command.Parameters.AddWithValue("@Estado", estado);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<Reto> CrearAsync(Reto reto)
        {
            if (reto.CategoriaId < 1 || reto.CategoriaId > 7)
                throw new InvalidOperationException("La categoria debe ser una de las 7 categorias oficiales (1-7).");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                $"INSERT INTO Reto (Codigo, CategoriaId, Titulo, Descripcion, Instrucciones, ExperienciaRecompensa, MonedasRecompensa, Dificultad, FechaInicio, FechaFin, Estado) OUTPUT INSERTED.RetoId VALUES (@Codigo, @CategoriaId, @Titulo, @Descripcion, @Instrucciones, @ExperienciaRecompensa, @MonedasRecompensa, @Dificultad, @FechaInicio, @FechaFin, @Estado)", connection);
            command.Parameters.AddWithValue("@Codigo", (object?)reto.Codigo ?? DBNull.Value);
            command.Parameters.AddWithValue("@CategoriaId", reto.CategoriaId);
            command.Parameters.AddWithValue("@Titulo", reto.Titulo);
            command.Parameters.AddWithValue("@Descripcion", reto.Descripcion);
            command.Parameters.AddWithValue("@Instrucciones", reto.Instrucciones);
            command.Parameters.AddWithValue("@ExperienciaRecompensa", reto.ExperienciaRecompensa);
            command.Parameters.AddWithValue("@MonedasRecompensa", reto.MonedasRecompensa);
            command.Parameters.AddWithValue("@Dificultad", reto.Dificultad);
            command.Parameters.AddWithValue("@FechaInicio", reto.FechaInicio);
            command.Parameters.AddWithValue("@FechaFin", (object?)reto.FechaFin ?? DBNull.Value);
            command.Parameters.AddWithValue("@Estado", reto.Estado);
            reto.RetoId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return reto;
        }

        public async Task<Reto?> ActualizarAsync(Reto reto)
        {
            if (reto.CategoriaId < 1 || reto.CategoriaId > 7)
                throw new InvalidOperationException("La categoria debe ser una de las 7 categorias oficiales (1-7).");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "UPDATE Reto SET CategoriaId = @CategoriaId, Titulo = @Titulo, Descripcion = @Descripcion, Instrucciones = @Instrucciones, ExperienciaRecompensa = @ExperienciaRecompensa, MonedasRecompensa = @MonedasRecompensa, Dificultad = @Dificultad, FechaInicio = @FechaInicio, FechaFin = @FechaFin, Estado = @Estado WHERE RetoId = @RetoId", connection);
            command.Parameters.AddWithValue("@RetoId", reto.RetoId);
            command.Parameters.AddWithValue("@CategoriaId", reto.CategoriaId);
            command.Parameters.AddWithValue("@Titulo", reto.Titulo);
            command.Parameters.AddWithValue("@Descripcion", reto.Descripcion);
            command.Parameters.AddWithValue("@Instrucciones", reto.Instrucciones);
            command.Parameters.AddWithValue("@ExperienciaRecompensa", reto.ExperienciaRecompensa);
            command.Parameters.AddWithValue("@MonedasRecompensa", reto.MonedasRecompensa);
            command.Parameters.AddWithValue("@Dificultad", reto.Dificultad);
            command.Parameters.AddWithValue("@FechaInicio", reto.FechaInicio);
            command.Parameters.AddWithValue("@FechaFin", (object?)reto.FechaFin ?? DBNull.Value);
            command.Parameters.AddWithValue("@Estado", reto.Estado);
            return await command.ExecuteNonQueryAsync() > 0 ? reto : null;
        }

        public async Task<bool> EliminarAsync(int retoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("DELETE FROM Reto WHERE RetoId = @RetoId", connection);
            command.Parameters.AddWithValue("@RetoId", retoId);
            return await command.ExecuteNonQueryAsync() > 0;
        }

        /// <summary>
        /// Upsert por Codigo reutilizando una sola conexion: primero consulta
        /// (donde el indice unico IX_Reto_Codigo lo hace instantaneo) y, si no
        /// existe, inserta. Evita abrir una conexion nueva por consulta.
        /// </summary>
        public async Task<Reto> ObtenerOCrearPorCodigoAsync(
            string codigo,
            int categoriaId,
            string titulo,
            string descripcion,
            string instrucciones,
            int experienciaRecompensa,
            int monedasRecompensa,
            string dificultad)
        {
            if (categoriaId < 1 || categoriaId > 7)
                throw new InvalidOperationException("La categoria debe ser una de las 7 categorias oficiales (1-7).");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using (var select = new SqlCommand($"SELECT {Columnas} FROM Reto WHERE Codigo = @Codigo", connection))
            {
                select.Parameters.AddWithValue("@Codigo", codigo);
                using var reader = await select.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    var existente = Mapear(reader);
                    reader.Close();
                    // Corrige la categoría si el reto existía con CategoriaId nulo
                    // (datos viejos sincronizados antes de que el móvil enviara la categoría).
                    if (existente.CategoriaId == 0)
                    {
                        using var update = new SqlCommand(
                            "UPDATE Reto SET CategoriaId = @CategoriaId WHERE RetoId = @RetoId AND (CategoriaId IS NULL OR CategoriaId = 0)",
                            connection);
                        update.Parameters.AddWithValue("@RetoId", existente.RetoId);
                        update.Parameters.AddWithValue("@CategoriaId", categoriaId);
                        await update.ExecuteNonQueryAsync();
                        existente.CategoriaId = categoriaId;
                    }
                    // Mantiene las recompensas alineadas con el catálogo local:
                    // los retos creados antes del Monedero quedaron con 0 monedas.
                    if (existente.ExperienciaRecompensa != experienciaRecompensa ||
                        existente.MonedasRecompensa != monedasRecompensa)
                    {
                        using var updateRecompensa = new SqlCommand(
                            "UPDATE Reto SET ExperienciaRecompensa = @ExperienciaRecompensa, MonedasRecompensa = @MonedasRecompensa WHERE RetoId = @RetoId",
                            connection);
                        updateRecompensa.Parameters.AddWithValue("@RetoId", existente.RetoId);
                        updateRecompensa.Parameters.AddWithValue("@ExperienciaRecompensa", experienciaRecompensa);
                        updateRecompensa.Parameters.AddWithValue("@MonedasRecompensa", monedasRecompensa);
                        await updateRecompensa.ExecuteNonQueryAsync();
                        existente.ExperienciaRecompensa = experienciaRecompensa;
                        existente.MonedasRecompensa = monedasRecompensa;
                    }
                    return existente;
                }
            }

            using var insert = new SqlCommand(
                "INSERT INTO Reto (Codigo, CategoriaId, Titulo, Descripcion, Instrucciones, ExperienciaRecompensa, MonedasRecompensa, Dificultad, FechaInicio, FechaFin, Estado) OUTPUT INSERTED.RetoId VALUES (@Codigo, @CategoriaId, @Titulo, @Descripcion, @Instrucciones, @ExperienciaRecompensa, @MonedasRecompensa, @Dificultad, @FechaInicio, @FechaFin, @Estado)",
                connection);
            insert.Parameters.AddWithValue("@Codigo", codigo);
            insert.Parameters.AddWithValue("@CategoriaId", categoriaId);
            insert.Parameters.AddWithValue("@Titulo", titulo);
            insert.Parameters.AddWithValue("@Descripcion", descripcion);
            insert.Parameters.AddWithValue("@Instrucciones", instrucciones);
            insert.Parameters.AddWithValue("@ExperienciaRecompensa", experienciaRecompensa);
            insert.Parameters.AddWithValue("@MonedasRecompensa", monedasRecompensa);
            insert.Parameters.AddWithValue("@Dificultad", dificultad);
            insert.Parameters.AddWithValue("@FechaInicio", DateTime.Now);
            insert.Parameters.AddWithValue("@FechaFin", DBNull.Value);
            insert.Parameters.AddWithValue("@Estado", "ACTIVO");

            return new Reto
            {
                RetoId = Convert.ToInt32(await insert.ExecuteScalarAsync()),
                Codigo = codigo,
                CategoriaId = categoriaId,
                Titulo = titulo,
                Descripcion = descripcion,
                Instrucciones = instrucciones,
                ExperienciaRecompensa = experienciaRecompensa,
                MonedasRecompensa = monedasRecompensa,
                Dificultad = dificultad,
                FechaInicio = DateTime.Now,
                Estado = "ACTIVO"
            };
        }
    }
}