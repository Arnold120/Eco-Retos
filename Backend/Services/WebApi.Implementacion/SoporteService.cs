using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{





    public class SoporteService : ISoporteService
    {
        private readonly string _connectionString;
        private readonly INotificacionService _notificaciones;
        private readonly IUsuarioRetoService _usuarioRetoService;
        private readonly IUsuarioService _usuarioService;
        private readonly IUsuarioRolService _usuarioRolService;
        private readonly IRolService _rolService;
        private readonly IPerfilService _perfilService;
        private readonly IProgresoService _progresoService;
        private readonly IJardinService _jardinService;
        private readonly IMonederoService _monederoService;
        private readonly IAuditoriaService _auditoria;
        private readonly IServicioIA _ia;

        private static readonly string[] EstadosValidos =
            { "NUEVO", "IA_ATENDIENDO", "EN_REVISION", "RESUELTO_POR_IA", "ESCALADO", "ASIGNADO", "RESUELTO", "CERRADO" };
        private static readonly string[] PrioridadesValidas = { "BAJA", "NORMAL", "ALTA", "URGENTE" };
        private static readonly string[] CategoriasValidas = { "RETO", "EVIDENCIA", "CONTENIDO", "CUENTA", "MONEDERO", "OTRO" };

        private const string SelectCaso =
            "SELECT c.SupportCaseId, c.UsuarioId, u.NombreUsuario AS UsuarioNombre, c.Titulo, c.Descripcion, c.Categoria, " +
            "c.Prioridad, c.Estado, c.Consentimiento, c.TerminosVersion, c.AdminUsuarioId, a.NombreUsuario AS AdminNombre, " +
            "c.MotivoEscalamiento, c.Resolucion, c.NotasInternas, c.FechaCreacion, c.FechaActualizacion, c.FechaCierre, c.EsReporte " +
            "FROM SupportCase c " +
            "INNER JOIN Usuario u ON u.UsuarioId = c.UsuarioId " +
            "LEFT JOIN Usuario a ON a.UsuarioId = c.AdminUsuarioId ";

        public SoporteService(
            IConfiguration configuration,
            INotificacionService notificaciones,
            IUsuarioRetoService usuarioRetoService,
            IUsuarioService usuarioService,
            IUsuarioRolService usuarioRolService,
            IRolService rolService,
            IPerfilService perfilService,
            IProgresoService progresoService,
            IJardinService jardinService,
            IMonederoService monederoService,
            IAuditoriaService auditoria,
            IServicioIA ia)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
            _notificaciones = notificaciones;
            _usuarioRetoService = usuarioRetoService;
            _usuarioService = usuarioService;
            _usuarioRolService = usuarioRolService;
            _rolService = rolService;
            _perfilService = perfilService;
            _progresoService = progresoService;
            _jardinService = jardinService;
            _monederoService = monederoService;
            _auditoria = auditoria;
            _ia = ia;
        }


        private static string Normalizar(string? valor, string[] validos, string porDefecto)
        {
            var v = (valor ?? string.Empty).Trim().ToUpperInvariant();
            return validos.Contains(v) ? v : porDefecto;
        }

        private static List<AdjuntoSoporteDto> DeserializarAdjuntos(string? json)
        {
            if (string.IsNullOrWhiteSpace(json)) return new List<AdjuntoSoporteDto>();
            try
            {
                return JsonSerializer.Deserialize<List<AdjuntoSoporteDto>>(json!) ?? new List<AdjuntoSoporteDto>();
            }
            catch
            {
                return new List<AdjuntoSoporteDto>();
            }
        }

        private static List<string> DeserializarSugerencias(string? json)
        {
            if (string.IsNullOrWhiteSpace(json)) return new List<string>();
            try
            {
                return JsonSerializer.Deserialize<List<string>>(json!) ?? new List<string>();
            }
            catch
            {
                return new List<string>();
            }
        }

        private static string? Serializar<T>(T? valor)
        {
            if (valor is null) return null;
            if (valor is System.Collections.ICollection col && col.Count == 0) return null;
            return JsonSerializer.Serialize(valor);
        }

        internal static SupportCase MapearCaso(SqlDataReader reader)
        {
            return new SupportCase
            {
                SupportCaseId = DatabaseHelper.ReadInt(reader, "SupportCaseId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                UsuarioNombre = DatabaseHelper.ReadString(reader, "UsuarioNombre"),
                Titulo = DatabaseHelper.ReadString(reader, "Titulo"),
                Descripcion = reader.IsDBNull(reader.GetOrdinal("Descripcion")) ? null : DatabaseHelper.ReadString(reader, "Descripcion"),
                Categoria = DatabaseHelper.ReadString(reader, "Categoria"),
                Prioridad = DatabaseHelper.ReadString(reader, "Prioridad"),
                Estado = DatabaseHelper.ReadString(reader, "Estado"),
                Consentimiento = DatabaseHelper.ReadBool(reader, "Consentimiento"),
                TerminosVersion = reader.IsDBNull(reader.GetOrdinal("TerminosVersion")) ? null : DatabaseHelper.ReadString(reader, "TerminosVersion"),
                AdminUsuarioId = DatabaseHelper.ReadNullableInt(reader, "AdminUsuarioId"),
                AdminNombre = reader.IsDBNull(reader.GetOrdinal("AdminNombre")) ? null : DatabaseHelper.ReadString(reader, "AdminNombre"),
                MotivoEscalamiento = reader.IsDBNull(reader.GetOrdinal("MotivoEscalamiento")) ? null : DatabaseHelper.ReadString(reader, "MotivoEscalamiento"),
                Resolucion = reader.IsDBNull(reader.GetOrdinal("Resolucion")) ? null : DatabaseHelper.ReadString(reader, "Resolucion"),
                NotasInternas = reader.IsDBNull(reader.GetOrdinal("NotasInternas")) ? null : DatabaseHelper.ReadString(reader, "NotasInternas"),
                FechaCreacion = DatabaseHelper.ReadDateTime(reader, "FechaCreacion"),
                FechaActualizacion = DatabaseHelper.ReadDateTime(reader, "FechaActualizacion"),
                FechaCierre = DatabaseHelper.ReadNullableDateTime(reader, "FechaCierre"),
                EsReporte = !reader.IsDBNull(reader.GetOrdinal("EsReporte")) && DatabaseHelper.ReadBool(reader, "EsReporte")
            };
        }

        private static SupportCaseResponseDto ACasoDto(SupportCase c) => new()
        {
            Id = c.SupportCaseId,
            UsuarioId = c.UsuarioId,
            UsuarioNombre = c.UsuarioNombre ?? string.Empty,
            Titulo = c.Titulo,
            Descripcion = c.Descripcion,
            Categoria = c.Categoria,
            Prioridad = c.Prioridad,
            Estado = c.Estado,
            Consentimiento = c.Consentimiento,
            TerminosVersion = c.TerminosVersion,
            AdminId = c.AdminUsuarioId,
            AdminNombre = c.AdminNombre,
            MotivoEscalamiento = c.MotivoEscalamiento,
            Resolucion = c.Resolucion,
            NotasInternas = c.NotasInternas,
            FechaCreacion = c.FechaCreacion,
            FechaActualizacion = c.FechaActualizacion,
            FechaCierre = c.FechaCierre
        };

        private static SupportMensajeResponseDto AMensajeDto(SupportCaseMensaje m) => new()
        {
            Id = m.SupportCaseMensajeId,
            CasoId = m.SupportCaseId,
            Remitente = m.TipoRemitente,
            Contenido = m.Contenido,
            Adjuntos = DeserializarAdjuntos(m.AdjuntosJson),
            Sugerencias = DeserializarSugerencias(m.SugerenciasJson),
            Fecha = m.Fecha,
            Leido = m.Leido
        };

        private async Task<SupportCase?> ObtenerCasoInternoAsync(int casoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(SelectCaso + "WHERE c.SupportCaseId = @Id", connection);
            command.Parameters.AddWithValue("@Id", casoId);
            using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapearCaso(reader) : null;
        }


        public async Task<Dictionary<string, string>> ObtenerConfigAsync()
        {
            var config = new Dictionary<string, string>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT Clave, Valor FROM SoporteConfig", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                config[DatabaseHelper.ReadString(reader, "Clave")] = DatabaseHelper.ReadString(reader, "Valor");
            return config;
        }

        public async Task GuardarConfigAsync(GuardarConfigRequestDto dto, int adminUsuarioId, string adminNombre)
        {
            var cambios = new List<(string Clave, string Valor)>();
            if (dto.TerminosTexto is not null) cambios.Add(("TerminosTexto", dto.TerminosTexto));
            if (dto.TerminosVersion is not null) cambios.Add(("TerminosVersion", dto.TerminosVersion));
            if (dto.AdvertenciaContenido is not null) cambios.Add(("AdvertenciaContenido", dto.AdvertenciaContenido));

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            foreach (var (clave, valor) in cambios)
            {
                using var command = new SqlCommand(
                    "IF EXISTS (SELECT 1 FROM SoporteConfig WHERE Clave = @Clave) " +
                    "UPDATE SoporteConfig SET Valor = @Valor, Actualizado = GETDATE() WHERE Clave = @Clave " +
                    "ELSE INSERT INTO SoporteConfig (Clave, Valor) VALUES (@Clave, @Valor)", connection);
                command.Parameters.AddWithValue("@Clave", clave);
                command.Parameters.AddWithValue("@Valor", valor);
                await command.ExecuteNonQueryAsync();
            }

            await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "GUARDAR_CONFIG", "SoporteConfig", null, null, null,
                "Configuración de soporte actualizada");
        }


        public async Task<SupportCaseResponseDto> CrearCasoAsync(int usuarioId, string nombreUsuario, CrearCasoRequestDto dto)
        {
            dto ??= new CrearCasoRequestDto();
            if (!dto.Consentimiento)
                throw new InvalidOperationException("Debes aceptar los términos del servicio de soporte para iniciar la conversación.");
            if (string.IsNullOrWhiteSpace(dto.Titulo))
                throw new InvalidOperationException("El título del caso es obligatorio.");
            if (dto.Titulo.Length > 200)
                throw new InvalidOperationException("El título no puede superar 200 caracteres.");

            var categoria = Normalizar(dto.Categoria, CategoriasValidas, "OTRO");
            string descripcion = dto.Descripcion?.Trim() ?? string.Empty;
            if (descripcion.Length > 1000) descripcion = descripcion[..1000];

            var config = await ObtenerConfigAsync();
            var version = dto.TerminosVersion ?? (config.TryGetValue("TerminosVersion", out var v) ? v : "v1");

            int casoId;
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand(
                    "INSERT INTO SupportCase (UsuarioId, Titulo, Descripcion, Categoria, Prioridad, Estado, Consentimiento, FechaConsentimiento, TerminosVersion, FechaCreacion, FechaActualizacion) " +
                    "OUTPUT INSERTED.SupportCaseId VALUES (@UsuarioId, @Titulo, @Descripcion, @Categoria, 'NORMAL', 'NUEVO', 1, @FechaConsentimiento, @TerminosVersion, @Fecha, @Fecha)", connection);
                command.Parameters.AddWithValue("@UsuarioId", usuarioId);
                command.Parameters.AddWithValue("@Titulo", dto.Titulo.Trim());
                command.Parameters.AddWithValue("@Descripcion", (object?)descripcion ?? DBNull.Value);
                command.Parameters.AddWithValue("@Categoria", categoria);
                command.Parameters.AddWithValue("@FechaConsentimiento", DateTime.Now);
                command.Parameters.AddWithValue("@TerminosVersion", version);
                command.Parameters.AddWithValue("@Fecha", DateTime.Now);
                casoId = Convert.ToInt32(await command.ExecuteScalarAsync());
            }


            var primerMensaje = descripcion.Length > 0 ? descripcion : dto!.Titulo.Trim();
            await InsertarMensajeAsync(casoId, "USUARIO", usuarioId, primerMensaje, null, null, false);
            var decision = await _ia.AnalizarSoporteAsync(new ContextoSoporteIA
            {
                Titulo = dto.Titulo.Trim(),
                Descripcion = primerMensaje,
                Categoria = categoria,
                Estado = "NUEVO",
                CantidadMensajesUsuario = 1,
                TieneAdjuntos = false,
                Historial = new List<MensajeContextoIA>
                {
                    new() { Remitente = "USUARIO", Contenido = primerMensaje }
                }
            });
            await AplicarDecisionIAAsync(casoId, decision);

            await _auditoria.RegistrarAsync(null, "IA", "CREAR_CASO", "SupportCase", casoId, null, "NUEVO",
                "Apertura automática por chat IA");

            return ACasoDto((await ObtenerCasoInternoAsync(casoId))!);
        }

        public async Task<IEnumerable<SupportCaseResponseDto>> ObtenerCasosUsuarioAsync(int usuarioId)
        {
            var lista = new List<SupportCaseResponseDto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(SelectCaso + "WHERE c.UsuarioId = @UsuarioId ORDER BY c.FechaActualizacion DESC", connection);
            command.Parameters.AddWithValue("@UsuarioId", usuarioId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(ACasoDto(MapearCaso(reader)));
            return lista;
        }

        public Task<SupportCase?> ObtenerCasoAsync(int casoId) => ObtenerCasoInternoAsync(casoId);

        public async Task<IEnumerable<SupportMensajeResponseDto>> ObtenerMensajesAsync(int casoId)
        {
            var lista = new List<SupportMensajeResponseDto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT SupportCaseMensajeId, SupportCaseId, TipoRemitente, RemitenteUsuarioId, Contenido, AdjuntosJson, SugerenciasJson, Leido, Fecha " +
                "FROM SupportCaseMensaje WHERE SupportCaseId = @Id ORDER BY Fecha ASC", connection);
            command.Parameters.AddWithValue("@Id", casoId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                lista.Add(new SupportMensajeResponseDto
                {
                    Id = DatabaseHelper.ReadInt(reader, "SupportCaseMensajeId"),
                    CasoId = DatabaseHelper.ReadInt(reader, "SupportCaseId"),
                    Remitente = DatabaseHelper.ReadString(reader, "TipoRemitente"),
                    Contenido = DatabaseHelper.ReadString(reader, "Contenido"),
                    Adjuntos = DeserializarAdjuntos(reader.IsDBNull(reader.GetOrdinal("AdjuntosJson")) ? null : DatabaseHelper.ReadString(reader, "AdjuntosJson")),
                    Sugerencias = DeserializarSugerencias(reader.IsDBNull(reader.GetOrdinal("SugerenciasJson")) ? null : DatabaseHelper.ReadString(reader, "SugerenciasJson")),
                    Fecha = DatabaseHelper.ReadDateTime(reader, "Fecha"),
                    Leido = DatabaseHelper.ReadBool(reader, "Leido")
                });
            }
            return lista;
        }

        public async Task<EnviarMensajeSoporteResponseDto> AgregarMensajeUsuarioAsync(int casoId, int usuarioId, EnviarMensajeSoporteRequestDto dto)
        {
            var caso = await ObtenerCasoInternoAsync(casoId)
                ?? throw new InvalidOperationException("Caso no encontrado.");

            var contenido = (dto.Contenido ?? string.Empty).Trim();
            if (contenido.Length == 0 && dto.Adjuntos.Count == 0)
                throw new InvalidOperationException("El mensaje no puede estar vacío.");
            if (contenido.Length > 4000) contenido = contenido[..4000];

            await InsertarMensajeAsync(casoId, "USUARIO", usuarioId, contenido, dto.Adjuntos, null, false);

            var cantidadUsuario = await ContarMensajesUsuarioAsync(casoId);
            var historial = (await ObtenerMensajesAsync(casoId))
                .Select(m => new MensajeContextoIA
                {
                    Remitente = m.Remitente,
                    Contenido = m.Contenido,
                    Adjuntos = m.Adjuntos.Select(a => a.Url).ToList()
                })
                .ToList();

            var decision = await _ia.AnalizarSoporteAsync(new ContextoSoporteIA
            {
                Titulo = caso.Titulo,
                Descripcion = contenido,
                Categoria = caso.Categoria,
                Estado = caso.Estado,
                CantidadMensajesUsuario = cantidadUsuario,
                TieneAdjuntos = dto.Adjuntos.Count > 0,
                Historial = historial
            });
            await AplicarDecisionIAAsync(casoId, decision);

            var actualizado = await ObtenerCasoInternoAsync(casoId);
            return new EnviarMensajeSoporteResponseDto
            {
                Caso = ACasoDto(actualizado!),
                Mensajes = (await ObtenerMensajesAsync(casoId)).ToList(),
                Ia = new DecisionIAResponseDto
                {
                    MensajeIA = decision.MensajeIA,
                    Estado = decision.Estado,
                    Categoria = decision.Categoria,
                    Prioridad = decision.Prioridad,
                    CrearReporte = decision.CrearReporte,
                    Escalar = decision.Escalar,
                    Resolver = decision.Resolver,
                    MotivoEscalamiento = decision.MotivoEscalamiento,
                    Sugerencias = decision.Sugerencias
                }
            };
        }

        private async Task<int> ContarMensajesUsuarioAsync(int casoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT COUNT(1) FROM SupportCaseMensaje WHERE SupportCaseId = @Id AND TipoRemitente = 'USUARIO'", connection);
            command.Parameters.AddWithValue("@Id", casoId);
            return Convert.ToInt32(await command.ExecuteScalarAsync());
        }

        private async Task InsertarMensajeAsync(int casoId, string tipo, int? usuarioId, string contenido, List<AdjuntoSoporteDto>? adjuntos, List<string>? sugerencias, bool leido)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO SupportCaseMensaje (SupportCaseId, TipoRemitente, RemitenteUsuarioId, Contenido, AdjuntosJson, SugerenciasJson, Leido, Fecha) " +
                "VALUES (@CasoId, @Tipo, @UsuarioId, @Contenido, @Adjuntos, @Sugerencias, @Leido, @Fecha)", connection);
            command.Parameters.AddWithValue("@CasoId", casoId);
            command.Parameters.AddWithValue("@Tipo", tipo);
            command.Parameters.AddWithValue("@UsuarioId", (object?)usuarioId ?? DBNull.Value);
            command.Parameters.AddWithValue("@Contenido", contenido);
            command.Parameters.AddWithValue("@Adjuntos", (object?)Serializar(adjuntos) ?? DBNull.Value);
            command.Parameters.AddWithValue("@Sugerencias", (object?)Serializar(sugerencias) ?? DBNull.Value);
            command.Parameters.AddWithValue("@Leido", leido);
            command.Parameters.AddWithValue("@Fecha", DateTime.Now);
            await command.ExecuteNonQueryAsync();
        }

        private async Task AplicarDecisionIAAsync(int casoId, ReglasSoporteDecision decision)
        {
            var casoPrevio = await ObtenerCasoInternoAsync(casoId);
            await InsertarMensajeAsync(casoId, "IA", null, decision.MensajeIA, null, decision.Sugerencias, false);

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand(
                    "UPDATE SupportCase SET Estado = @Estado, Categoria = @Categoria, Prioridad = @Prioridad, " +
                    "MotivoEscalamiento = CASE WHEN @Motivo IS NULL THEN MotivoEscalamiento ELSE @Motivo END, " +
                    "Resolucion = CASE WHEN @Resolver = 1 THEN @Mensaje ELSE Resolucion END, " +
                    "EsReporte = CASE WHEN @CrearReporte = 1 THEN 1 ELSE EsReporte END, " +
                    "FechaActualizacion = @Fecha WHERE SupportCaseId = @Id", connection);
                command.Parameters.AddWithValue("@Estado", decision.Estado);
                command.Parameters.AddWithValue("@Categoria", decision.Categoria);
                command.Parameters.AddWithValue("@Prioridad", decision.Prioridad);
                command.Parameters.AddWithValue("@Motivo", (object?)decision.MotivoEscalamiento ?? DBNull.Value);
                command.Parameters.AddWithValue("@Resolver", decision.Resolver ? 1 : 0);
                command.Parameters.AddWithValue("@CrearReporte", decision.CrearReporte ? 1 : 0);
                command.Parameters.AddWithValue("@Mensaje", decision.MensajeIA);
                command.Parameters.AddWithValue("@Fecha", DateTime.Now);
                command.Parameters.AddWithValue("@Id", casoId);
                await command.ExecuteNonQueryAsync();
            }

            if (decision.CrearReporte && (casoPrevio is null || !casoPrevio.EsReporte))
            {
                await _auditoria.RegistrarAsync(null, decision.Proveedor == "ia" ? "IA" : "SISTEMA", "CREAR_REPORTE",
                    "SupportCase", casoId, null, decision.Categoria,
                    decision.MotivoEscalamiento ?? "Reporte estructurado creado desde el chat de soporte.",
                    JsonSerializer.Serialize(new
                    {
                        casoId,
                        usuarioId = casoPrevio?.UsuarioId,
                        categoria = decision.Categoria,
                        prioridad = decision.Prioridad,
                        proveedor = decision.Proveedor
                    }));
            }

            if (decision.Escalar)
            {
                await _auditoria.RegistrarAsync(null, "IA", "ESCALAR_CASO", "SupportCase", casoId, "IA_ATENDIENDO", "ESCALADO",
                    decision.MotivoEscalamiento);
                await NotificarAdminsAsync(casoId, "Nuevo caso escalado",
                    "Un caso de soporte requiere atención humana.", "CASO_ESCALADO");
            }

            if (decision.Resolver)
            {
                var caso = await ObtenerCasoInternoAsync(casoId);
                if (caso is not null)
                {
                    await CrearNotificacionAsync(caso.UsuarioId, "Caso resuelto por IA",
                        decision.MensajeIA, "SOPORTE", casoId);
                }
            }
        }

        public async Task MarcarLeidosAsync(int casoId, bool porAdmin)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            var filtro = porAdmin ? "TipoRemitente = 'USUARIO'" : "TipoRemitente IN ('IA','ADMIN')";
            using var command = new SqlCommand($"UPDATE SupportCaseMensaje SET Leido = 1 WHERE SupportCaseId = @Id AND {filtro} AND Leido = 0", connection);
            command.Parameters.AddWithValue("@Id", casoId);
            await command.ExecuteNonQueryAsync();
        }


        public async Task<IEnumerable<SupportCaseResponseDto>> ObtenerCasosAdminAsync(string? estado, string? prioridad, string? categoria, string? q)
        {
            var lista = new List<SupportCaseResponseDto>();
            var filtros = new List<string>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand();
            command.Connection = connection;

            if (!string.IsNullOrWhiteSpace(estado))
            {
                filtros.Add("c.Estado = @Estado");
                command.Parameters.AddWithValue("@Estado", estado.Trim().ToUpperInvariant());
            }
            if (!string.IsNullOrWhiteSpace(prioridad))
            {
                filtros.Add("c.Prioridad = @Prioridad");
                command.Parameters.AddWithValue("@Prioridad", prioridad.Trim().ToUpperInvariant());
            }
            if (!string.IsNullOrWhiteSpace(categoria))
            {
                filtros.Add("c.Categoria = @Categoria");
                command.Parameters.AddWithValue("@Categoria", categoria.Trim().ToUpperInvariant());
            }
            if (!string.IsNullOrWhiteSpace(q))
            {
                filtros.Add("(c.Titulo LIKE @Q OR u.NombreUsuario LIKE @Q OR CAST(c.SupportCaseId AS NVARCHAR(20)) LIKE @Q)");
                command.Parameters.AddWithValue("@Q", $"%{q.Trim()}%");
            }

            command.CommandText = SelectCaso + (filtros.Count > 0 ? "WHERE " + string.Join(" AND ", filtros) + " " : string.Empty) +
                "ORDER BY c.FechaActualizacion DESC";
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(ACasoDto(MapearCaso(reader)));
            return lista;
        }

        public async Task<SupportCaseResponseDto?> ActualizarCasoAdminAsync(int casoId, ActualizarCasoAdminRequestDto dto, int adminUsuarioId, string adminNombre)
        {
            var caso = await ObtenerCasoInternoAsync(casoId);
            if (caso is null) return null;

            var nuevoEstado = caso.Estado;
            if (!string.IsNullOrWhiteSpace(dto.Estado))
                nuevoEstado = Normalizar(dto.Estado, EstadosValidos, caso.Estado);

            var nuevaPrioridad = string.IsNullOrWhiteSpace(dto.Prioridad)
                ? caso.Prioridad
                : Normalizar(dto.Prioridad, PrioridadesValidas, caso.Prioridad);

            var nuevaCategoria = string.IsNullOrWhiteSpace(dto.Categoria)
                ? caso.Categoria
                : Normalizar(dto.Categoria, CategoriasValidas, caso.Categoria);

            var adminId = dto.AdminUsuarioId ?? caso.AdminUsuarioId;
            if (nuevoEstado == "ASIGNADO" && adminId is null) adminId = adminUsuarioId;


            var respondioAdmin = !string.IsNullOrWhiteSpace(dto.RespuestaAdmin);
            if (respondioAdmin)
            {
                if (nuevoEstado is "NUEVO" or "IA_ATENDIENDO" or "EN_REVISION" or "ESCALADO")
                    nuevoEstado = "ASIGNADO";
                adminId ??= adminUsuarioId;
            }

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand(
                    "UPDATE SupportCase SET Estado = @Estado, Prioridad = @Prioridad, Categoria = @Categoria, " +
                    "AdminUsuarioId = @AdminId, MotivoEscalamiento = COALESCE(@Motivo, MotivoEscalamiento), " +
                    "Resolucion = COALESCE(@Resolucion, Resolucion), NotasInternas = COALESCE(@Notas, NotasInternas), " +
                    "FechaCierre = CASE WHEN @Estado IN ('RESUELTO','RESUELTO_POR_IA','CERRADO') THEN COALESCE(FechaCierre, @Fecha) ELSE FechaCierre END, " +
                    "FechaActualizacion = @Fecha WHERE SupportCaseId = @Id", connection);
                command.Parameters.AddWithValue("@Estado", nuevoEstado);
                command.Parameters.AddWithValue("@Prioridad", nuevaPrioridad);
                command.Parameters.AddWithValue("@Categoria", nuevaCategoria);
                command.Parameters.AddWithValue("@AdminId", (object?)adminId ?? DBNull.Value);
                command.Parameters.AddWithValue("@Motivo", (object?)dto.MotivoEscalamiento ?? DBNull.Value);
                command.Parameters.AddWithValue("@Resolucion", (object?)dto.Resolucion ?? DBNull.Value);
                command.Parameters.AddWithValue("@Notas", (object?)dto.NotasInternas ?? DBNull.Value);
                command.Parameters.AddWithValue("@Fecha", DateTime.Now);
                command.Parameters.AddWithValue("@Id", casoId);
                await command.ExecuteNonQueryAsync();
            }

            if (!string.IsNullOrWhiteSpace(dto.RespuestaAdmin))
            {
                await InsertarMensajeAsync(casoId, "ADMIN", adminUsuarioId, dto.RespuestaAdmin!.Trim(), dto.Adjuntos, null, false);
                await CrearNotificacionAsync(caso.UsuarioId, "Respuesta del soporte",
                    "Un administrador respondió tu caso de soporte.", "SOPORTE", casoId);
                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "RESPONDER_CASO", "SupportCase", casoId,
                    caso.Estado, nuevoEstado, "Respuesta del administrador");
            }

            if (caso.Estado != nuevoEstado)
            {
                var accion = nuevoEstado switch
                {
                    "ASIGNADO" => "ASIGNAR_CASO",
                    "RESUELTO" => "RESOLVER_CASO",
                    "RESUELTO_POR_IA" => "RESOLVER_CASO",
                    "CERRADO" => "CERRAR_CASO",
                    "ESCALADO" => "ESCALAR_CASO",
                    _ => "CAMBIAR_ESTADO"
                };
                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", accion, "SupportCase", casoId,
                    caso.Estado, nuevoEstado, dto.Resolucion ?? dto.MotivoEscalamiento);

                var titulo = nuevoEstado switch
                {
                    "ASIGNADO" => "Caso asignado",
                    "RESUELTO" or "RESUELTO_POR_IA" => "Caso resuelto",
                    "CERRADO" => "Caso cerrado",
                    "ESCALADO" => "Caso escalado",
                    _ => "Actualización de tu caso"
                };
                var mensaje = nuevoEstado switch
                {
                    "ASIGNADO" => $"Un administrador ({adminNombre}) está atendiendo tu caso.",
                    "RESUELTO" or "RESUELTO_POR_IA" => dto.Resolucion ?? "Tu caso fue resuelto.",
                    "CERRADO" => "Tu caso fue cerrado.",
                    _ => $"El estado de tu caso cambió a {nuevoEstado}."
                };
                var tipo = nuevoEstado switch
                {
                    "ASIGNADO" => "CASO_ASIGNADO",
                    "RESUELTO" or "RESUELTO_POR_IA" => "CASO_RESUELTO",
                    _ => "SOPORTE"
                };
                await CrearNotificacionAsync(caso.UsuarioId, titulo, mensaje, tipo, casoId);

                if (nuevoEstado == "ESCALADO")
                    await NotificarAdminsAsync(casoId, "Caso escalado", "Un caso volvió a la bandeja de escalados.", "CASO_ESCALADO");
            }

            if (nuevaPrioridad != caso.Prioridad)
                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "CAMBIAR_PRIORIDAD", "SupportCase", casoId,
                    caso.Prioridad, nuevaPrioridad, null);

            if (nuevaCategoria != caso.Categoria)
                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "CAMBIAR_CATEGORIA", "SupportCase", casoId,
                    caso.Categoria, nuevaCategoria, null);

            if (adminId != caso.AdminUsuarioId)
                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "ASIGNAR_ADMIN", "SupportCase", casoId,
                    caso.AdminUsuarioId?.ToString(), adminId?.ToString(), $"Asignado a {adminNombre}");

            var actualizado = await ObtenerCasoInternoAsync(casoId);
            return actualizado is null ? null : ACasoDto(actualizado);
        }


        public async Task<DashboardSoporteResponseDto> ObtenerDashboardAsync()
        {
            var d = new DashboardSoporteResponseDto();
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand(
                    "SELECT COUNT(*) AS Total, " +
                    "SUM(CASE WHEN Estado IN ('NUEVO','IA_ATENDIENDO') THEN 1 ELSE 0 END) AS Nuevos, " +
                    "SUM(CASE WHEN Estado = 'ESCALADO' THEN 1 ELSE 0 END) AS Escalados, " +
                    "SUM(CASE WHEN Estado IN ('ASIGNADO','EN_REVISION') THEN 1 ELSE 0 END) AS EnAtencion, " +
                    "SUM(CASE WHEN Prioridad = 'URGENTE' AND Estado <> 'CERRADO' THEN 1 ELSE 0 END) AS Urgencias, " +
                    "AVG(CASE WHEN FechaCierre IS NOT NULL THEN DATEDIFF(MINUTE, FechaCreacion, FechaCierre) END) AS MinutosPromedio " +
                    "FROM SupportCase", connection))
                {
                    using var reader = await command.ExecuteReaderAsync();
                    if (await reader.ReadAsync())
                    {
                        d.CasosTotales = DatabaseHelper.ReadInt(reader, "Total");
                        d.CasosNuevos = DatabaseHelper.ReadInt(reader, "Nuevos");
                        d.Escalados = DatabaseHelper.ReadInt(reader, "Escalados");
                        d.EnAtencion = DatabaseHelper.ReadInt(reader, "EnAtencion");
                        d.Urgencias = DatabaseHelper.ReadInt(reader, "Urgencias");
                        var minutos = reader.IsDBNull(reader.GetOrdinal("MinutosPromedio")) ? 0 : Convert.ToDouble(reader.GetValue(reader.GetOrdinal("MinutosPromedio")));
                        d.HorasPromedioResolucion = Math.Round(minutos / 60.0, 1);
                    }
                }

                using (var command = new SqlCommand(
                    "SELECT (SELECT COUNT(*) FROM Denuncia WHERE Estado IN ('PENDIENTE','EN_REVISION')) AS Reportes, " +
                    "(SELECT COUNT(*) FROM UsuarioReto WHERE Estado NOT IN ('COMPLETADO','RECHAZADO') AND Evidencia IS NOT NULL AND Evidencia <> '') AS Evidencias, " +
                    "(SELECT COUNT(DISTINCT u.UsuarioId) FROM Usuario u INNER JOIN UsuarioRol ur ON ur.UsuarioId = u.UsuarioId INNER JOIN Rol r ON r.RolId = ur.RolId WHERE r.NombreRol = 'ADMIN' AND u.Activo = 1) AS Admins", connection))
                {
                    using var reader = await command.ExecuteReaderAsync();
                    if (await reader.ReadAsync())
                    {
                        d.ReportesPendientes = DatabaseHelper.ReadInt(reader, "Reportes");
                        d.EvidenciasPendientes = DatabaseHelper.ReadInt(reader, "Evidencias");
                        d.AdminsActivos = DatabaseHelper.ReadInt(reader, "Admins");
                    }
                }

                d.UltimosCasos = (await ObtenerCasosAdminAsync(null, null, null, null)).Take(6).ToList();
            }

            var audit = (await _auditoria.ObtenerAsync(null, 8)).ToList();
            d.ActividadReciente = audit.Select(a => new SupportAuditLogDto
            {
                Id = a.AuditLogId,
                Actor = a.ActorTipo == "IA" ? "IA" : (a.ActorNombre ?? "Sistema"),
                Accion = a.Accion,
                EntidadTipo = a.EntidadTipo,
                EntidadId = a.EntidadId,
                EstadoAnterior = a.EstadoAnterior,
                EstadoNuevo = a.EstadoNuevo,
                Motivo = a.Motivo,
                Fecha = a.Fecha
            }).ToList();
            return d;
        }


        private const string SelectReporteDenuncia =
            "SELECT d.DenunciaId, d.UsuarioId, u.NombreUsuario AS UsuarioNombre, u.Correo AS UsuarioCorreo, " +
            "d.PublicacionId, d.ComentarioId, d.Motivo, d.Descripcion, d.Estado, d.Fecha, " +
            "d.Accion, d.MotivoResolucion, d.AdminUsuarioId, au.NombreUsuario AS AdminNombre, d.FechaResolucion, d.EvidenciaUrl, " +
            "p.UsuarioId AS PublicacionAutorId, pu.NombreUsuario AS PublicacionAutorNombre, pu.Correo AS PublicacionAutorCorreo, " +
            "p.Contenido AS PublicacionContenido, p.Imagen AS PublicacionImagen, p.Estado AS PublicacionEstado, " +
            "c.UsuarioId AS ComentarioAutorId, cu.NombreUsuario AS ComentarioAutorNombre, cu.Correo AS ComentarioAutorCorreo, " +
            "c.ComentarioTexto, c.Estado AS ComentarioEstado, c.PublicacionId AS ComentarioPublicacionId " +
            "FROM Denuncia d " +
            "INNER JOIN Usuario u ON u.UsuarioId = d.UsuarioId " +
            "LEFT JOIN Usuario au ON au.UsuarioId = d.AdminUsuarioId " +
            "LEFT JOIN Publicacion p ON p.PublicacionId = d.PublicacionId " +
            "LEFT JOIN Usuario pu ON pu.UsuarioId = p.UsuarioId " +
            "LEFT JOIN Comentario c ON c.ComentarioId = d.ComentarioId " +
            "LEFT JOIN Usuario cu ON cu.UsuarioId = c.UsuarioId ";

        private static string? LeerTextoOpcional(SqlDataReader reader, string columna)
            => reader.IsDBNull(reader.GetOrdinal(columna)) ? null : DatabaseHelper.ReadString(reader, columna);

        private static int? LeerEnteroOpcional(SqlDataReader reader, string columna)
            => reader.IsDBNull(reader.GetOrdinal(columna)) ? null : DatabaseHelper.ReadInt(reader, columna);

        private static ReporteSoporteResponseDto MapearReporteDenuncia(SqlDataReader reader)
        {
            var publicacionId = LeerEnteroOpcional(reader, "PublicacionId");
            var comentarioId = LeerEnteroOpcional(reader, "ComentarioId");
            var contenidoTexto = publicacionId is not null
                ? LeerTextoOpcional(reader, "PublicacionContenido")
                : LeerTextoOpcional(reader, "ComentarioTexto");

            return new ReporteSoporteResponseDto
            {
                Id = DatabaseHelper.ReadInt(reader, "DenunciaId"),
                Tipo = "DENUNCIA",
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                UsuarioNombre = DatabaseHelper.ReadString(reader, "UsuarioNombre"),
                UsuarioCorreo = LeerTextoOpcional(reader, "UsuarioCorreo"),
                PublicacionId = publicacionId,
                ComentarioId = comentarioId,
                Motivo = LeerTextoOpcional(reader, "Motivo"),
                Descripcion = LeerTextoOpcional(reader, "Descripcion") ?? string.Empty,
                Estado = DatabaseHelper.ReadString(reader, "Estado"),
                Fecha = DatabaseHelper.ReadDateTime(reader, "Fecha"),
                Categoria = "CONTENIDO",
                Prioridad = "NORMAL",
                Accion = LeerTextoOpcional(reader, "Accion"),
                MotivoResolucion = LeerTextoOpcional(reader, "MotivoResolucion"),
                AdminId = LeerEnteroOpcional(reader, "AdminUsuarioId"),
                AdminNombre = LeerTextoOpcional(reader, "AdminNombre"),
                FechaResolucion = reader.IsDBNull(reader.GetOrdinal("FechaResolucion")) ? null : DatabaseHelper.ReadDateTime(reader, "FechaResolucion"),
                EvidenciaUrl = LeerTextoOpcional(reader, "EvidenciaUrl"),
                ContenidoTipo = publicacionId is not null ? "PUBLICACION" : "COMENTARIO",
                ContenidoId = publicacionId ?? comentarioId,
                ContenidoTexto = contenidoTexto,
                ContenidoAutorId = publicacionId is not null
                    ? LeerEnteroOpcional(reader, "PublicacionAutorId")
                    : LeerEnteroOpcional(reader, "ComentarioAutorId"),
                ContenidoAutorNombre = publicacionId is not null
                    ? LeerTextoOpcional(reader, "PublicacionAutorNombre")
                    : LeerTextoOpcional(reader, "ComentarioAutorNombre"),
                ContenidoAutorCorreo = publicacionId is not null
                    ? LeerTextoOpcional(reader, "PublicacionAutorCorreo")
                    : LeerTextoOpcional(reader, "ComentarioAutorCorreo"),
                ContenidoEstado = publicacionId is not null
                    ? LeerTextoOpcional(reader, "PublicacionEstado")
                    : LeerTextoOpcional(reader, "ComentarioEstado"),
                ContenidoImagen = publicacionId is not null ? LeerTextoOpcional(reader, "PublicacionImagen") : null,
                Enlace = ExtraerEnlace(contenidoTexto)
            };
        }

        private static async Task<Dictionary<int, List<AdjuntoSoporteDto>>> CargarMultimediaAsync(
            SqlConnection connection, List<int> publicacionIds)
        {
            var mapa = new Dictionary<int, List<AdjuntoSoporteDto>>();
            var ids = publicacionIds.Distinct().Take(100).ToList();
            if (ids.Count == 0) return mapa;

            var parametros = string.Join(",", ids.Select((_, i) => $"@M{i}"));
            using var command = new SqlCommand(
                $"SELECT PublicacionId, Url, Tipo FROM PublicacionMultimedia WHERE PublicacionId IN ({parametros}) ORDER BY Orden", connection);
            for (var i = 0; i < ids.Count; i++)
                command.Parameters.AddWithValue($"@M{i}", ids[i]);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var publicacionId = DatabaseHelper.ReadInt(reader, "PublicacionId");
                if (!mapa.TryGetValue(publicacionId, out var lista))
                {
                    lista = new List<AdjuntoSoporteDto>();
                    mapa[publicacionId] = lista;
                }
                lista.Add(new AdjuntoSoporteDto
                {
                    Url = DatabaseHelper.ReadString(reader, "Url"),
                    Tipo = (LeerTextoOpcional(reader, "Tipo") ?? "imagen").ToLowerInvariant(),
                    Nombre = string.Empty
                });
            }
            return mapa;
        }

        private static string? ExtraerEnlace(string? texto)
        {
            if (string.IsNullOrWhiteSpace(texto)) return null;
            var match = Regex.Match(texto, @"https?://[^\s]+", RegexOptions.IgnoreCase);
            return match.Success ? match.Value.TrimEnd('.', ',', ';', ')', ']') : null;
        }

        public async Task<IEnumerable<ReporteSoporteResponseDto>> ObtenerReportesAsync(string? estado)
        {
            var lista = new List<ReporteSoporteResponseDto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using (var command = new SqlCommand(SelectReporteDenuncia +
                "WHERE (@Estado IS NULL OR d.Estado = @Estado) ORDER BY d.Fecha DESC", connection))
            {
                command.Parameters.AddWithValue("@Estado", (object?)estado ?? DBNull.Value);
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                    lista.Add(MapearReporteDenuncia(reader));
            }

            var idsPublicacion = lista
                .Where(r => r.PublicacionId is not null)
                .Select(r => r.PublicacionId!.Value)
                .Distinct()
                .ToList();
            var multimedia = await CargarMultimediaAsync(connection, idsPublicacion);
            foreach (var reporte in lista)
            {
                if (reporte.PublicacionId is int publicacionId && multimedia.TryGetValue(publicacionId, out var adjuntos))
                    reporte.ContenidoMultimedia = adjuntos;
            }

            using (var command = new SqlCommand(SelectCaso +
                "WHERE (c.Categoria = 'CONTENIDO' OR c.EsReporte = 1) " +
                "ORDER BY c.FechaActualizacion DESC", connection))
            {
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    var c = MapearCaso(reader);
                    lista.Add(new ReporteSoporteResponseDto
                    {
                        Id = c.SupportCaseId,
                        Tipo = "SOPORTE",
                        UsuarioId = c.UsuarioId,
                        UsuarioNombre = c.UsuarioNombre ?? string.Empty,
                        Descripcion = c.Descripcion ?? c.Titulo,
                        Categoria = "CONTENIDO",
                        Prioridad = c.Prioridad,
                        Estado = MapearEstadoReporte(c.Estado),
                        Motivo = c.MotivoEscalamiento,
                        AdminId = c.AdminUsuarioId,
                        AdminNombre = c.AdminNombre,
                        MotivoResolucion = c.Resolucion,
                        Fecha = c.FechaActualizacion,
                        FechaResolucion = c.FechaCierre,
                        CasoId = c.SupportCaseId
                    });
                }
            }



            var estadoFiltro = (estado ?? string.Empty).Trim().ToUpperInvariant();
            if (estadoFiltro.Length > 0)
                lista = lista.Where(r => r.Tipo != "SOPORTE" || r.Estado == estadoFiltro).ToList();

            return lista.OrderByDescending(r => r.Fecha).ToList();
        }

        private static string MapearEstadoReporte(string? estadoCaso) => (estadoCaso ?? string.Empty).ToUpperInvariant() switch
        {
            "NUEVO" or "IA_ATENDIENDO" => "PENDIENTE",
            "EN_REVISION" or "ESCALADO" or "ASIGNADO" => "EN_REVISION",
            "RESUELTO" or "RESUELTO_POR_IA" or "CERRADO" => "RESUELTA",
            _ => "PENDIENTE"
        };

        public async Task<ReporteSoporteResponseDto?> ObtenerReporteAsync(int denunciaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            ReporteSoporteResponseDto? reporte = null;
            using (var command = new SqlCommand(SelectReporteDenuncia + "WHERE d.DenunciaId = @Id", connection))
            {
                command.Parameters.AddWithValue("@Id", denunciaId);
                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync()) reporte = MapearReporteDenuncia(reader);
            }
            if (reporte is null) return null;

            if (reporte.PublicacionId is int publicacionId)
            {
                var multimedia = await CargarMultimediaAsync(connection, new List<int> { publicacionId });
                if (multimedia.TryGetValue(publicacionId, out var adjuntos)) reporte.ContenidoMultimedia = adjuntos;
            }
            return reporte;
        }

        public async Task<bool> ActualizarReporteAsync(int denunciaId, ActualizarReporteRequestDto dto, int adminUsuarioId, string adminNombre)
        {
            var estado = Normalizar(dto.Estado, new[] { "PENDIENTE", "EN_REVISION", "RESUELTA", "DESCARTADA" }, "RESUELTA");
            var accion = (dto.Accion ?? string.Empty).Trim().ToUpperInvariant();
            if (accion.Length > 40) accion = accion[..40];
            var motivo = (dto.Motivo ?? string.Empty).Trim();
            if (motivo.Length == 0)
                motivo = estado == "DESCARTADA"
                    ? "El reporte no presentó fundamento suficiente tras la revisión."
                    : "Reporte revisado por el equipo de moderación.";
            if (motivo.Length > 500) motivo = motivo[..500];

            int usuarioId;
            string estadoAnterior;
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("SELECT UsuarioId, Estado FROM Denuncia WHERE DenunciaId = @Id", connection))
                {
                    command.Parameters.AddWithValue("@Id", denunciaId);
                    using var reader = await command.ExecuteReaderAsync();
                    if (!await reader.ReadAsync()) return false;
                    usuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId");
                    estadoAnterior = DatabaseHelper.ReadString(reader, "Estado");
                }

                using (var command = new SqlCommand(
                    "UPDATE Denuncia SET Estado = @Estado, " +
                    "Accion = CASE WHEN @Accion = '' THEN Accion ELSE @Accion END, " +
                    "MotivoResolucion = @Motivo, AdminUsuarioId = @AdminUsuarioId, " +
                    "FechaResolucion = CASE WHEN @Estado IN ('RESUELTA','DESCARTADA') THEN COALESCE(FechaResolucion, GETDATE()) ELSE FechaResolucion END " +
                    "WHERE DenunciaId = @Id", connection))
                {
                    command.Parameters.AddWithValue("@Estado", estado);
                    command.Parameters.AddWithValue("@Accion", accion);
                    command.Parameters.AddWithValue("@Motivo", motivo);
                    command.Parameters.AddWithValue("@AdminUsuarioId", adminUsuarioId);
                    command.Parameters.AddWithValue("@Id", denunciaId);
                    await command.ExecuteNonQueryAsync();
                }
            }

            await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "RESOLVER_REPORTE", "Denuncia", denunciaId,
                estadoAnterior, estado, motivo,
                JsonSerializer.Serialize(new { accion, admin = adminNombre, estado, motivo }));

            var etiquetaAccion = accion.Length > 0 ? accion.Replace('_', ' ').ToLowerInvariant() : "revisado";
            await CrearNotificacionAsync(usuarioId, "Tu reporte fue revisado",
                $"El estado de tu reporte cambió a {estado.ToLowerInvariant()}. Acción aplicada: {etiquetaAccion}. Motivo: {motivo}",
                "SOPORTE", denunciaId, "REPORTE");


            if (accion == "ADVERTENCIA")
            {
                var autorId = await ObtenerAutorContenidoDenunciaAsync(denunciaId);
                if (autorId is int autor && autor != usuarioId)
                {
                    var config = await ObtenerConfigAsync();
                    config.TryGetValue("AdvertenciaContenido", out var advertencia);
                    advertencia ??= "Tu contenido fue revisado y no cumple las reglas de la comunidad. " +
                                    "Por favor evita repetir este comportamiento.";
                    await CrearNotificacionAsync(autor, "Advertencia de contenido", $"{advertencia} Motivo: {motivo}",
                        "CONTENIDO", denunciaId, "REPORTE");
                    await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "ADVERTIR_USUARIO", "Usuario", autor,
                        null, null, motivo, JsonSerializer.Serialize(new { reporteId = denunciaId, accion, admin = adminNombre }));
                }
            }

            return true;
        }

        private async Task<int?> ObtenerAutorContenidoDenunciaAsync(int denunciaId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT COALESCE(p.UsuarioId, c.UsuarioId) AS AutorId " +
                "FROM Denuncia d " +
                "LEFT JOIN Publicacion p ON p.PublicacionId = d.PublicacionId " +
                "LEFT JOIN Comentario c ON c.ComentarioId = d.ComentarioId " +
                "WHERE d.DenunciaId = @Id", connection);
            command.Parameters.AddWithValue("@Id", denunciaId);
            var resultado = await command.ExecuteScalarAsync();
            return resultado is null || resultado == DBNull.Value ? null : Convert.ToInt32(resultado);
        }

        public async Task<AnalisisIAReporte?> AnalizarReporteAsync(int denunciaId)
        {
            var reporte = await ObtenerReporteAsync(denunciaId);
            if (reporte is null) return null;

            var imagenes = new List<string>();
            if (!string.IsNullOrWhiteSpace(reporte.ContenidoImagen)) imagenes.Add(reporte.ContenidoImagen!);
            imagenes.AddRange(reporte.ContenidoMultimedia
                .Where(a => !string.Equals(a.Tipo, "video", StringComparison.OrdinalIgnoreCase))
                .Select(a => a.Url));

            var analisis = await _ia.AnalizarReporteAsync(new ContextoReporteIA
            {
                ReporteId = denunciaId,
                Motivo = reporte.Motivo,
                Descripcion = reporte.Descripcion,
                TipoContenido = reporte.ContenidoTipo ?? "DESCONOCIDO",
                ContenidoId = reporte.ContenidoId,
                ContenidoTexto = reporte.ContenidoTexto,
                ContenidoImagenes = imagenes,
                Enlace = reporte.Enlace
            });

            await _auditoria.RegistrarAsync(null, analisis.Proveedor == "ia" ? "IA" : "SISTEMA", "EVALUACION_IA",
                "Denuncia", denunciaId, null, analisis.Recomendacion,
                analisis.Motivo, JsonSerializer.Serialize(analisis));

            return analisis;
        }

        public async Task<bool> ModerarContenidoAsync(ModerarContenidoRequestDto dto, int adminUsuarioId, string adminNombre)
        {
            var objetivo = (dto.Objetivo ?? string.Empty).Trim().ToUpperInvariant();
            var accion = (dto.Accion ?? string.Empty).Trim().ToUpperInvariant();
            if (dto.Id <= 0) return false;

            var config = await ObtenerConfigAsync();
            config.TryGetValue("AdvertenciaContenido", out var advertencia);
            advertencia ??= "Tu contenido fue revisado y no cumple las reglas de la comunidad. " +
                            "Por favor evita repetir este comportamiento.";

            if (objetivo == "PUBLICACION" && (accion == "OCULTAR" || accion == "ELIMINAR"))
            {
                int autorId;
                string estadoAnterior;
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("SELECT UsuarioId, Estado FROM Publicacion WHERE PublicacionId = @Id", connection))
                    {
                        command.Parameters.AddWithValue("@Id", dto.Id);
                        using var reader = await command.ExecuteReaderAsync();
                        if (!await reader.ReadAsync()) return false;
                        autorId = DatabaseHelper.ReadInt(reader, "UsuarioId");
                        estadoAnterior = DatabaseHelper.ReadString(reader, "Estado");
                    }
                    using (var command = new SqlCommand("UPDATE Publicacion SET Estado = 'OCULTA' WHERE PublicacionId = @Id", connection))
                    {
                        command.Parameters.AddWithValue("@Id", dto.Id);
                        await command.ExecuteNonQueryAsync();
                    }
                }

                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "OCULTAR_PUBLICACION", "Publicacion", dto.Id,
                    estadoAnterior, "OCULTA", dto.Motivo);
                await CrearNotificacionAsync(autorId, "Publicación retirada", advertencia, "CONTENIDO", dto.Id, "PUBLICACION");
                await ResolverReporteVinculadoAsync(dto.ReporteId, "OCULTAR_PUBLICACION", dto.Motivo, adminUsuarioId);
                return true;
            }



            if (objetivo == "COMENTARIO" && (accion == "OCULTAR" || accion == "ELIMINAR"))
            {
                int autorId;
                using (var connection = new SqlConnection(_connectionString))
                {
                    await connection.OpenAsync();
                    using (var command = new SqlCommand("SELECT UsuarioId FROM Comentario WHERE ComentarioId = @Id", connection))
                    {
                        command.Parameters.AddWithValue("@Id", dto.Id);
                        var resultado = await command.ExecuteScalarAsync();
                        if (resultado is null) return false;
                        autorId = Convert.ToInt32(resultado);
                    }

                    using (var command = new SqlCommand(
                        "UPDATE Comentario SET Estado = 'OCULTA' WHERE ComentarioId = @Id OR ComentarioPadreId = @Id", connection))
                    {
                        command.Parameters.AddWithValue("@Id", dto.Id);
                        await command.ExecuteNonQueryAsync();
                    }
                }

                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "OCULTAR_COMENTARIO", "Comentario", dto.Id,
                    "ACTIVO", "OCULTA", dto.Motivo);
                await CrearNotificacionAsync(autorId, "Comentario retirado", advertencia, "CONTENIDO", dto.Id, "COMENTARIO");
                await ResolverReporteVinculadoAsync(dto.ReporteId, "OCULTAR_COMENTARIO", dto.Motivo, adminUsuarioId);
                return true;
            }

            return false;
        }


        private async Task ResolverReporteVinculadoAsync(int? denunciaId, string accion, string? motivo, int adminUsuarioId)
        {
            if (denunciaId is not int id || id <= 0) return;
            var motivoFinal = string.IsNullOrWhiteSpace(motivo)
                ? "Contenido revisado y ocultado por incumplir las reglas de la comunidad."
                : motivo!.Trim();
            if (motivoFinal.Length > 500) motivoFinal = motivoFinal[..500];

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using (var command = new SqlCommand(
                "UPDATE Denuncia SET Estado = 'RESUELTA', Accion = @Accion, MotivoResolucion = @Motivo, " +
                "AdminUsuarioId = @Admin, FechaResolucion = COALESCE(FechaResolucion, GETDATE()) WHERE DenunciaId = @Id", connection))
            {
                command.Parameters.AddWithValue("@Accion", accion);
                command.Parameters.AddWithValue("@Motivo", motivoFinal);
                command.Parameters.AddWithValue("@Admin", adminUsuarioId);
                command.Parameters.AddWithValue("@Id", id);
                await command.ExecuteNonQueryAsync();
            }

            await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "RESOLVER_REPORTE", "Denuncia", id,
                null, "RESUELTA", motivoFinal);
        }


        private const string SelectEvidencia =
            "SELECT ur.UsuarioRetoId, ur.UsuarioId, u.NombreUsuario, u.Correo AS UsuarioCorreo, ur.RetoId, " +
            "r.Titulo AS RetoTitulo, r.Descripcion AS RetoDescripcion, r.Instrucciones AS RetoInstrucciones, " +
            "r.Requisitos AS RetoRequisitos, r.Evidencia AS RetoTipoEvidencia, r.CantidadObjetivo AS RetoCantidadObjetivo, " +
            "ur.Estado, ur.Evidencia, ur.MotivoRechazo, ur.PuntosObtenidos, ur.FechaInicio, ur.FechaCompletado " +
            "FROM UsuarioReto ur INNER JOIN Usuario u ON u.UsuarioId = ur.UsuarioId " +
            "INNER JOIN Reto r ON r.RetoId = ur.RetoId ";

        private static EvidenciaSoporteResponseDto MapearEvidencia(SqlDataReader reader)
        {
            var cruda = reader.IsDBNull(reader.GetOrdinal("Evidencia")) ? null : DatabaseHelper.ReadString(reader, "Evidencia");
            var parseada = EvidenciaParser.Parse(cruda);
            var adjuntos = new List<AdjuntoSoporteDto>();
            adjuntos.AddRange(parseada.Imagenes.Select(url => new AdjuntoSoporteDto { Url = url, Tipo = "imagen" }));
            adjuntos.AddRange(parseada.Videos.Select(url => new AdjuntoSoporteDto { Url = url, Tipo = "video" }));

            return new EvidenciaSoporteResponseDto
            {
                Id = DatabaseHelper.ReadInt(reader, "UsuarioRetoId"),
                UsuarioId = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                Usuario = DatabaseHelper.ReadString(reader, "NombreUsuario"),
                UsuarioCorreo = LeerTextoOpcional(reader, "UsuarioCorreo"),
                RetoId = DatabaseHelper.ReadInt(reader, "RetoId"),
                Reto = DatabaseHelper.ReadString(reader, "RetoTitulo"),
                RetoDescripcion = LeerTextoOpcional(reader, "RetoDescripcion"),
                RetoInstrucciones = LeerTextoOpcional(reader, "RetoInstrucciones"),
                RetoRequisitos = LeerTextoOpcional(reader, "RetoRequisitos"),
                RetoTipoEvidencia = LeerTextoOpcional(reader, "RetoTipoEvidencia"),
                RetoCantidadObjetivo = LeerEnteroOpcional(reader, "RetoCantidadObjetivo"),
                Estado = DatabaseHelper.ReadString(reader, "Estado"),
                Evidencia = cruda,
                EvidenciaTexto = parseada.Texto,
                EvidenciaAdjuntos = adjuntos,
                MotivoRechazo = LeerTextoOpcional(reader, "MotivoRechazo"),
                PuntosObtenidos = DatabaseHelper.ReadInt(reader, "PuntosObtenidos"),
                Fecha = DatabaseHelper.ReadDateTime(reader, "FechaInicio"),
                FechaCompletado = DatabaseHelper.ReadNullableDateTime(reader, "FechaCompletado")
            };
        }

        private static async Task<Dictionary<int, EvaluacionIAEvidencia>> CargarEvaluacionesIAAsync(
            SqlConnection connection, List<int> usuarioRetoIds)
        {
            var mapa = new Dictionary<int, EvaluacionIAEvidencia>();
            if (usuarioRetoIds.Count == 0) return mapa;

            using var command = new SqlCommand(
                "SELECT a.EntidadId, a.MetadataJson FROM SupportAuditLog a " +
                "INNER JOIN (SELECT EntidadId, MAX(AuditLogId) AS MaxId FROM SupportAuditLog " +
                "WHERE EntidadTipo = 'UsuarioReto' AND Accion = 'EVALUACION_IA' GROUP BY EntidadId) t " +
                "ON t.MaxId = a.AuditLogId", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var entidadId = DatabaseHelper.ReadInt(reader, "EntidadId");
                if (!usuarioRetoIds.Contains(entidadId)) continue;
                var json = LeerTextoOpcional(reader, "MetadataJson");
                if (string.IsNullOrWhiteSpace(json)) continue;
                try
                {
                    var evaluacion = JsonSerializer.Deserialize<EvaluacionIAEvidencia>(json!,
                        new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                    if (evaluacion is not null) mapa[entidadId] = evaluacion;
                }
                catch
                {

                }
            }
            return mapa;
        }

        public async Task<IEnumerable<EvidenciaSoporteResponseDto>> ObtenerEvidenciasAsync(string? estado)
        {
            var lista = new List<EvidenciaSoporteResponseDto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using (var command = new SqlCommand(
                SelectEvidencia +
                "WHERE ur.Evidencia IS NOT NULL AND ur.Evidencia <> '' AND (@Estado IS NULL OR ur.Estado = @Estado) " +
                "ORDER BY ur.FechaInicio DESC", connection))
            {
                command.Parameters.AddWithValue("@Estado", (object?)estado ?? DBNull.Value);
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync()) lista.Add(MapearEvidencia(reader));
            }

            var evaluaciones = await CargarEvaluacionesIAAsync(connection, lista.Select(e => e.Id).ToList());
            foreach (var evidencia in lista)
            {
                if (evaluaciones.TryGetValue(evidencia.Id, out var evaluacion))
                    evidencia.EvaluacionIA = evaluacion;
            }
            return lista;
        }

        public async Task<EvidenciaSoporteResponseDto?> ObtenerEvidenciaAsync(int usuarioRetoId)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            EvidenciaSoporteResponseDto? evidencia = null;
            using (var command = new SqlCommand(SelectEvidencia + "WHERE ur.UsuarioRetoId = @Id", connection))
            {
                command.Parameters.AddWithValue("@Id", usuarioRetoId);
                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync()) evidencia = MapearEvidencia(reader);
            }
            if (evidencia is null) return null;

            var evaluaciones = await CargarEvaluacionesIAAsync(connection, new List<int> { usuarioRetoId });
            if (evaluaciones.TryGetValue(usuarioRetoId, out var evaluacion)) evidencia.EvaluacionIA = evaluacion;
            return evidencia;
        }

        public async Task<EvaluacionIAEvidencia?> AnalizarEvidenciaAsync(int usuarioRetoId)
        {
            var evidencia = await ObtenerEvidenciaAsync(usuarioRetoId);
            if (evidencia is null) return null;

            var imagenes = evidencia.EvidenciaAdjuntos
                .Where(a => !string.Equals(a.Tipo, "video", StringComparison.OrdinalIgnoreCase))
                .Select(a => a.Url)
                .ToList();
            var videos = evidencia.EvidenciaAdjuntos
                .Where(a => string.Equals(a.Tipo, "video", StringComparison.OrdinalIgnoreCase))
                .Select(a => a.Url)
                .ToList();

            var evaluacion = await _ia.EvaluarEvidenciaAsync(new ContextoEvidenciaIA
            {
                UsuarioRetoId = usuarioRetoId,
                RetoTitulo = evidencia.Reto,
                RetoDescripcion = evidencia.RetoDescripcion ?? string.Empty,
                RetoInstrucciones = evidencia.RetoInstrucciones ?? string.Empty,
                RetoRequisitos = evidencia.RetoRequisitos ?? string.Empty,
                RetoTipoEvidencia = evidencia.RetoTipoEvidencia ?? string.Empty,
                RetoCantidadObjetivo = evidencia.RetoCantidadObjetivo,
                UsuarioNombre = evidencia.Usuario,
                UsuarioCorreo = evidencia.UsuarioCorreo ?? string.Empty,
                EvidenciaTexto = evidencia.EvidenciaTexto ?? string.Empty,
                Imagenes = imagenes,
                Videos = videos,
                FechaCompletado = evidencia.FechaCompletado
            });

            await _auditoria.RegistrarAsync(null, evaluacion.Proveedor == "ia" ? "IA" : "SISTEMA", "EVALUACION_IA",
                "UsuarioReto", usuarioRetoId, null, evaluacion.Cumple ? "CUMPLE" : "NO_CUMPLE",
                evaluacion.Motivo, JsonSerializer.Serialize(evaluacion));

            return evaluacion;
        }

        public async Task<bool> DecidirEvidenciaAsync(int usuarioRetoId, DecidirEvidenciaRequestDto dto, int adminUsuarioId, string adminNombre)
        {
            var usuarioReto = await _usuarioRetoService.ObtenerPorIdAsync(usuarioRetoId);
            if (usuarioReto is null) return false;

            var estado = (dto.Estado ?? string.Empty).Trim().ToUpperInvariant();
            bool ok;
            if (estado == "COMPLETADO")
            {

                var puntos = dto.PuntosObtenidos;
                if (puntos <= 0)
                {
                    using var connection = new SqlConnection(_connectionString);
                    await connection.OpenAsync();
                    using var command = new SqlCommand(
                        "SELECT r.ExperienciaRecompensa FROM UsuarioReto ur INNER JOIN Reto r ON r.RetoId = ur.RetoId WHERE ur.UsuarioRetoId = @Id", connection);
                    command.Parameters.AddWithValue("@Id", usuarioRetoId);
                    var valor = await command.ExecuteScalarAsync();
                    if (valor is not null && valor != DBNull.Value) puntos = Convert.ToInt32(valor);
                }

                ok = await _usuarioRetoService.AprobarEvidenciaAsync(usuarioRetoId, puntos);
                if (ok)
                {
                    await CrearNotificacionAsync(usuarioReto.UsuarioId, "Reto aprobado",
                        $"Tu evidencia fue aprobada por {adminNombre}. Se acreditaron {puntos} puntos.",
                        "RETO_APROBADO", usuarioRetoId, "USUARIO_RETO");
                }
            }
            else
            {
                var motivo = (dto.MotivoRechazo ?? string.Empty).Trim();
                if (motivo.Length == 0) return false;
                if (motivo.Length > 300) motivo = motivo[..300];
                ok = await _usuarioRetoService.RechazarEvidenciaAsync(usuarioRetoId, motivo);
                if (ok)
                {
                    await CrearNotificacionAsync(usuarioReto.UsuarioId, "Reto rechazado",
                        $"Motivo: {motivo}", "RETO_RECHAZADO", usuarioRetoId, "USUARIO_RETO");
                }
            }

            if (ok)
            {
                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN",
                    estado == "COMPLETADO" ? "APROBAR_EVIDENCIA" : "RECHAZAR_EVIDENCIA",
                    "UsuarioReto", usuarioRetoId, null, estado, dto.MotivoRechazo,
                    JsonSerializer.Serialize(new { admin = adminNombre, estado, motivo = dto.MotivoRechazo }));
            }
            return ok;
        }


        public async Task<IEnumerable<AdminUsuarioResponseDto>> ObtenerAdminsAsync()
        {
            var lista = new List<AdminUsuarioResponseDto>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "SELECT u.UsuarioId, u.NombreUsuario, u.Correo, u.Activo, u.FechaRegistro, " +
                "(SELECT MAX(a.Fecha) FROM SupportAuditLog a WHERE a.ActorUsuarioId = u.UsuarioId) AS UltimaActividad " +
                "FROM Usuario u INNER JOIN UsuarioRol ur ON ur.UsuarioId = u.UsuarioId " +
                "INNER JOIN Rol r ON r.RolId = ur.RolId WHERE r.NombreRol = 'ADMIN' ORDER BY u.NombreUsuario", connection);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                lista.Add(new AdminUsuarioResponseDto
                {
                    Id = DatabaseHelper.ReadInt(reader, "UsuarioId"),
                    Nombre = DatabaseHelper.ReadString(reader, "NombreUsuario"),
                    Correo = DatabaseHelper.ReadString(reader, "Correo"),
                    Estado = DatabaseHelper.ReadBool(reader, "Activo") ? "ACTIVO" : "INACTIVO",
                    FechaCreacion = DatabaseHelper.ReadDateTime(reader, "FechaRegistro"),
                    UltimaActividad = DatabaseHelper.ReadNullableDateTime(reader, "UltimaActividad")
                });
            }
            return lista;
        }

        public async Task<CrearAdminResultDto> CrearAdminAsync(CrearAdminRequestDto dto, int adminUsuarioId, string adminNombre)
        {
            var correo = (dto.Correo ?? string.Empty).Trim().ToLowerInvariant();
            if (correo.Length == 0) throw new InvalidOperationException("El correo es obligatorio.");

            var rolAdmin = await _rolService.ObtenerPorNombreAsync("ADMIN")
                ?? throw new InvalidOperationException("El rol ADMIN no existe en la base de datos.");

            var usuario = await _usuarioService.ObtenerPorCorreoAsync(correo);
            var resultado = new CrearAdminResultDto();

            if (usuario is null)
            {
                var contrasena = string.IsNullOrWhiteSpace(dto.Contrasena)
                    ? GenerarContrasenaTemporal()
                    : dto.Contrasena!;
                var nombre = string.IsNullOrWhiteSpace(dto.Nombre) ? correo.Split('@')[0] : dto.Nombre!.Trim();

                usuario = await _usuarioService.CrearAsync(new Usuario
                {
                    NombreUsuario = nombre,
                    Correo = correo,
                    Contrasena = contrasena,
                    Activo = true,
                    FechaRegistro = DateTime.Now
                });

                await _perfilService.CrearAsync(new Perfil { UsuarioId = usuario.UsuarioId, Nombre = nombre, Apellido = string.Empty });
                await _progresoService.CrearProgresoAsync(new Progreso { UsuarioId = usuario.UsuarioId });
                await _jardinService.CrearJardinAsync(new Jardin { UsuarioId = usuario.UsuarioId });
                await _monederoService.CrearMonederoAsync(usuario.UsuarioId);
                resultado.ContrasenaTemporal = string.IsNullOrWhiteSpace(dto.Contrasena) ? contrasena : null;
            }
            else
            {
                resultado.UsuarioExistente = true;
                if (!usuario.Activo) await _usuarioService.ActivarAsync(usuario.UsuarioId);
            }

            var rolesActuales = await _usuarioRolService.ObtenerRolesPorUsuarioAsync(usuario.UsuarioId);
            if (!rolesActuales.Any(r => r.RolId == rolAdmin.RolId))
                await _usuarioRolService.AsignarRolAsync(new UsuarioRol { UsuarioId = usuario.UsuarioId, RolId = rolAdmin.RolId });

            await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "AGREGAR_ADMIN", "Usuario", usuario.UsuarioId,
                null, "ADMIN", $"Administrador agregado: {correo} (por {adminNombre})");

            resultado.Admin = new AdminUsuarioResponseDto
            {
                Id = usuario.UsuarioId,
                Nombre = usuario.NombreUsuario,
                Correo = usuario.Correo,
                Estado = usuario.Activo ? "ACTIVO" : "INACTIVO",
                FechaCreacion = usuario.FechaRegistro,
                UltimaActividad = null
            };
            return resultado;
        }

        private static string GenerarContrasenaTemporal()
        {
            const string mayus = "ABCDEFGHJKLMNPQRSTUVWXYZ";
            const string minus = "abcdefghijkmnpqrstuvwxyz";
            const string nums = "23456789";
            const string simbolos = "!@#$%";
            var random = new Random();
            var partes = new List<char>
            {
                mayus[random.Next(mayus.Length)],
                minus[random.Next(minus.Length)],
                nums[random.Next(nums.Length)],
                simbolos[random.Next(simbolos.Length)]
            };
            var todos = mayus + minus + nums;
            for (var i = 0; i < 8; i++) partes.Add(todos[random.Next(todos.Length)]);
            return new string(partes.OrderBy(_ => random.Next()).ToArray());
        }

        public async Task<bool> CambiarEstadoAdminAsync(int usuarioId, bool activo, int adminUsuarioId, string adminNombre)
        {
            if (usuarioId == adminUsuarioId && !activo)
                throw new InvalidOperationException("No puedes desactivar tu propia cuenta de administrador.");

            var rolAdmin = await _rolService.ObtenerPorNombreAsync("ADMIN");
            if (rolAdmin is not null && !await _usuarioRolService.UsuarioTieneRolAsync(usuarioId, rolAdmin.RolId))
                return false;

            var ok = activo
                ? await _usuarioService.ActivarAsync(usuarioId)
                : await _usuarioService.DesactivarAsync(usuarioId);

            if (ok)
            {
                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN",
                    activo ? "ACTIVAR_ADMIN" : "DESACTIVAR_ADMIN", "Usuario", usuarioId,
                    activo ? "INACTIVO" : "ACTIVO", activo ? "ACTIVO" : "INACTIVO", $"Por {adminNombre}");
            }
            return ok;
        }

        public async Task<bool> QuitarAdminAsync(int usuarioId, int adminUsuarioId, string adminNombre)
        {
            if (usuarioId == adminUsuarioId)
                throw new InvalidOperationException("No puedes quitarte a ti mismo el rol ADMIN.");

            var rolAdmin = await _rolService.ObtenerPorNombreAsync("ADMIN");
            if (rolAdmin is null) return false;

            var ok = await _usuarioRolService.QuitarRolAsync(usuarioId, rolAdmin.RolId);
            if (ok)
            {
                await _auditoria.RegistrarAsync(adminUsuarioId, "ADMIN", "QUITAR_ADMIN", "Usuario", usuarioId,
                    "ADMIN", null, $"Rol ADMIN retirado por {adminNombre}");
            }
            return ok;
        }


        public async Task NotificarAdminsAsync(int casoId, string titulo, string mensaje, string tipo)
        {
            var admins = new List<int>();
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand(
                    "SELECT DISTINCT u.UsuarioId FROM Usuario u " +
                    "INNER JOIN UsuarioRol ur ON ur.UsuarioId = u.UsuarioId " +
                    "INNER JOIN Rol r ON r.RolId = ur.RolId " +
                    "WHERE r.NombreRol = 'ADMIN' AND u.Activo = 1", connection);
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync()) admins.Add(DatabaseHelper.ReadInt(reader, "UsuarioId"));
            }

            foreach (var adminId in admins)
                await CrearNotificacionAsync(adminId, titulo, mensaje, tipo, casoId, "SUPPORTCASE");
        }

        public async Task NotificarAdminsReporteAsync(int denunciaId, string usuarioNombre, string motivo)
        {
            var titulo = "Nuevo reporte de contenido";
            var mensaje = $"El usuario {usuarioNombre} reportó contenido. Motivo: {motivo}.";
            await NotificarAdminsReferenciaAsync(titulo, mensaje, "NUEVO_REPORTE", denunciaId, "REPORTE");
        }

        private async Task NotificarAdminsReferenciaAsync(string titulo, string mensaje, string tipo, int referenciaId, string referenciaTipo)
        {
            var admins = new List<int>();
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand(
                    "SELECT DISTINCT u.UsuarioId FROM Usuario u " +
                    "INNER JOIN UsuarioRol ur ON ur.UsuarioId = u.UsuarioId " +
                    "INNER JOIN Rol r ON r.RolId = ur.RolId " +
                    "WHERE r.NombreRol = 'ADMIN' AND u.Activo = 1", connection);
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync()) admins.Add(DatabaseHelper.ReadInt(reader, "UsuarioId"));
            }

            foreach (var adminId in admins)
                await CrearNotificacionAsync(adminId, titulo, mensaje, tipo, referenciaId, referenciaTipo);
        }

        private async Task CrearNotificacionAsync(int usuarioId, string titulo, string mensaje, string tipo, int referenciaId, string referenciaTipo = "SUPPORTCASE")
        {
            await _notificaciones.CrearNotificacionAsync(new Notificacion
            {
                UsuarioId = usuarioId,
                Titulo = titulo,
                Mensaje = mensaje,
                Tipo = tipo,
                Leida = false,
                Fecha = DateTime.Now,
                ReferenciaTipo = referenciaTipo,
                ReferenciaId = referenciaId
            });
        }


        public async Task<ResumenAdminSoporteResponseDto> ObtenerResumenAdminAsync()
        {
            var r = new ResumenAdminSoporteResponseDto();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using (var command = new SqlCommand(
                "SELECT COUNT(*) AS Total, " +
                "SUM(CASE WHEN Estado IN ('NUEVO','IA_ATENDIENDO') THEN 1 ELSE 0 END) AS Nuevos, " +
                "SUM(CASE WHEN Estado = 'ESCALADO' THEN 1 ELSE 0 END) AS Escalados, " +
                "SUM(CASE WHEN Estado IN ('ASIGNADO','EN_REVISION') THEN 1 ELSE 0 END) AS EnAtencion, " +
                "SUM(CASE WHEN Prioridad = 'URGENTE' AND Estado <> 'CERRADO' THEN 1 ELSE 0 END) AS Urgencias " +
                "FROM SupportCase", connection))
            {
                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    r.CasosTotales = DatabaseHelper.ReadInt(reader, "Total");
                    r.CasosNuevos = DatabaseHelper.ReadInt(reader, "Nuevos");
                    r.Escalados = DatabaseHelper.ReadInt(reader, "Escalados");
                    r.EnAtencion = DatabaseHelper.ReadInt(reader, "EnAtencion");
                    r.Urgencias = DatabaseHelper.ReadInt(reader, "Urgencias");
                }
            }

            using (var command = new SqlCommand(
                "SELECT (SELECT COUNT(*) FROM Denuncia WHERE Estado IN ('PENDIENTE','EN_REVISION')) AS Reportes, " +
                "(SELECT COUNT(*) FROM UsuarioReto WHERE Estado NOT IN ('COMPLETADO','RECHAZADO') AND Evidencia IS NOT NULL AND Evidencia <> '') AS Evidencias, " +
                "(SELECT MAX(SupportCaseId) FROM SupportCase) AS UltimoCasoId, " +
                "(SELECT MAX(DenunciaId) FROM Denuncia) AS UltimoReporteId, " +
                "(SELECT MAX(UsuarioRetoId) FROM UsuarioReto WHERE Evidencia IS NOT NULL AND Evidencia <> '') AS UltimaEvidenciaId, " +
                "(SELECT MAX(FechaActualizacion) FROM SupportCase) AS UltimoCasoFecha, " +
                "(SELECT MAX(Fecha) FROM Denuncia) AS UltimoReporteFecha, " +
                "(SELECT MAX(FechaInicio) FROM UsuarioReto WHERE Evidencia IS NOT NULL AND Evidencia <> '') AS UltimaEvidenciaFecha", connection))
            {
                using var reader = await command.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    r.ReportesPendientes = DatabaseHelper.ReadInt(reader, "Reportes");
                    r.EvidenciasPendientes = DatabaseHelper.ReadInt(reader, "Evidencias");
                    r.UltimoCasoId = DatabaseHelper.ReadInt(reader, "UltimoCasoId");
                    r.UltimoReporteId = DatabaseHelper.ReadInt(reader, "UltimoReporteId");
                    r.UltimaEvidenciaId = DatabaseHelper.ReadInt(reader, "UltimaEvidenciaId");
                    r.UltimoCasoFecha = reader.IsDBNull(reader.GetOrdinal("UltimoCasoFecha")) ? null : DatabaseHelper.ReadDateTime(reader, "UltimoCasoFecha");
                    r.UltimoReporteFecha = reader.IsDBNull(reader.GetOrdinal("UltimoReporteFecha")) ? null : DatabaseHelper.ReadDateTime(reader, "UltimoReporteFecha");
                    r.UltimaEvidenciaFecha = reader.IsDBNull(reader.GetOrdinal("UltimaEvidenciaFecha")) ? null : DatabaseHelper.ReadDateTime(reader, "UltimaEvidenciaFecha");
                }
            }

            r.FechaConsulta = DateTime.Now;
            r.Firma = $"{r.CasosTotales}|{r.CasosNuevos}|{r.Escalados}|{r.EnAtencion}|{r.Urgencias}|" +
                      $"{r.ReportesPendientes}|{r.EvidenciasPendientes}|{r.UltimoCasoId}|{r.UltimoReporteId}|{r.UltimaEvidenciaId}";
            return r;
        }
    }
}
