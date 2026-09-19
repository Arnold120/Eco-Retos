using System.Globalization;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{










    public class ServicioIA : IServicioIA
    {
        private readonly IConfiguration _config;
        private readonly IHttpClientFactory _httpFactory;
        private readonly ILogger<ServicioIA> _logger;

        private readonly string _apiKey;
        private readonly string _modelo;
        private readonly string _baseUrl;
        private readonly int _timeoutSegundos;
        private readonly int _maxImagenes;
        private readonly int _maxHistorial;

        public ServicioIA(
            IConfiguration config,
            IHttpClientFactory httpFactory,
            ILogger<ServicioIA> logger)
        {
            _config = config;
            _httpFactory = httpFactory;
            _logger = logger;

            _apiKey = (config["Ia:ApiKey"] ?? string.Empty).Trim();
            _modelo = (config["Ia:Modelo"] ?? "gpt-4o-mini").Trim();
            _baseUrl = (config["Ia:BaseUrl"] ?? "https://api.openai.com/v1").Trim().TrimEnd('/');
            _timeoutSegundos = LeerEntero("Ia:TimeoutSegundos", 45, 5, 180);
            _maxImagenes = LeerEntero("Ia:MaxImagenes", 4, 0, 8);
            _maxHistorial = LeerEntero("Ia:MaxHistorial", 12, 2, 40);
        }

        private int LeerEntero(string clave, int porDefecto, int minimo, int maximo)
        {
            var valor = _config[clave];
            if (int.TryParse(valor, NumberStyles.Integer, CultureInfo.InvariantCulture, out var numero))
                return Math.Clamp(numero, minimo, maximo);
            return porDefecto;
        }

        public bool Configurada => _apiKey.Length > 0;


        public async Task<ReglasSoporteDecision> AnalizarSoporteAsync(ContextoSoporteIA contexto)
        {
            contexto ??= new ContextoSoporteIA();
            if (!Configurada) return RespaldoSoporte(contexto);

            try
            {
                var prompt = ConstruirPromptSoporte(contexto);
                var partes = new List<object> { new { type = "text", text = prompt } };


                var adjuntosRecientes = contexto.Historial
                    .Where(m => m.Remitente == "USUARIO")
                    .TakeLast(1)
                    .SelectMany(m => m.Adjuntos)
                    .Take(_maxImagenes)
                    .ToList();
                foreach (var adjunto in adjuntosRecientes)
                {
                    if (EsUrlVideo(adjunto)) continue;
                    var url = PrepararImagenParaModelo(adjunto);
                    if (url is not null)
                        partes.Add(new { type = "image_url", image_url = new { url } });
                }

                var json = await LlamarAsync(
                    "Eres el asistente de soporte de Eco-Retos. Respondes en espanol, con tono profesional, claro y breve. " +
                    "No usas emojis. Nunca afirmas haber eliminado contenido ni ejecutado acciones administrativas: " +
                    "solo analizas, orientas y escalas. Responde UNICAMENTE con un JSON valido.",
                    partes,
                    900);

                var decision = InterpretarDecisionSoporte(json);
                if (decision is null) return RespaldoSoporte(contexto);

                return AsegurarDecisionSegura(decision, contexto);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "IA de soporte no disponible; se usan reglas deterministas.");
                return RespaldoSoporte(contexto);
            }
        }

        private ReglasSoporteDecision RespaldoSoporte(ContextoSoporteIA contexto)
        {
            var decision = ReglasSoporte.Analizar(
                contexto.Descripcion.Length > 0 ? contexto.Descripcion : contexto.Titulo,
                contexto.CantidadMensajesUsuario,
                contexto.Categoria,
                contexto.TieneAdjuntos);

            return new ReglasSoporteDecision
            {
                MensajeIA = SinEmojis(decision.MensajeIA),
                Estado = decision.Estado,
                Categoria = decision.Categoria,
                Prioridad = decision.Prioridad,
                CrearReporte = decision.CrearReporte,
                Escalar = decision.Escalar,
                Resolver = decision.Resolver,
                MotivoEscalamiento = SinEmojis(decision.MotivoEscalamiento),
                Sugerencias = decision.Sugerencias.Select(SinEmojis).ToList(),
                Proveedor = "reglas"
            };
        }

        private string ConstruirPromptSoporte(ContextoSoporteIA contexto)
        {
            var sb = new StringBuilder();
            sb.AppendLine("Analiza la conversacion de soporte y decide la siguiente accion.");
            sb.AppendLine("Datos del caso:");
            sb.AppendLine($"- Titulo: {contexto.Titulo}");
            sb.AppendLine($"- Categoria declarada: {contexto.Categoria}");
            sb.AppendLine($"- Estado actual: {contexto.Estado}");
            sb.AppendLine($"- Mensajes del usuario: {contexto.CantidadMensajesUsuario}");
            sb.AppendLine($"- El ultimo mensaje trae adjuntos: {(contexto.TieneAdjuntos ? "si" : "no")}");
            sb.AppendLine();
            sb.AppendLine("Conversacion (mas reciente al final):");
            foreach (var m in contexto.Historial.TakeLast(_maxHistorial))
            {
                var adj = m.Adjuntos.Count > 0 ? $" [adjuntos: {string.Join(", ", m.Adjuntos)}]" : string.Empty;
                sb.AppendLine($"{m.Remitente}: {m.Contenido}{adj}");
            }
            sb.AppendLine();
            sb.AppendLine("Reglas obligatorias:");
            sb.AppendLine("1. Si hay indicios de contenido +18, acoso, amenazas, fraude o seguridad, NO resuelvas: escala y crea reporte.");
            sb.AppendLine("2. Solo puedes marcar resolver=true si el usuario confirmo explicitamente que el problema se soluciono.");
            sb.AppendLine("3. Si falta informacion, pide exactamente lo que falta (preguntas concretas).");
            sb.AppendLine("4. No inventes datos ni digas que ya realizaste acciones sobre cuentas o contenido.");
            sb.AppendLine("5. Responde en espanol y sin emojis.");
            sb.AppendLine();
            sb.AppendLine("Devuelve un JSON con este formato exacto:");
            sb.AppendLine("{\"mensajeIA\":\"texto para el usuario\",\"estado\":\"IA_ATENDIENDO|EN_REVISION|ESCALADO|RESUELTO_POR_IA\"," +
                          "\"categoria\":\"RETO|EVIDENCIA|CONTENIDO|CUENTA|MONEDERO|OTRO\",\"prioridad\":\"BAJA|NORMAL|ALTA|URGENTE\"," +
                          "\"crearReporte\":false,\"escalar\":false,\"resolver\":false,\"motivoEscalamiento\":null," +
                          "\"sugerencias\":[\"respuesta corta 1\",\"respuesta corta 2\"]}");
            return sb.ToString();
        }

        private ReglasSoporteDecision? InterpretarDecisionSoporte(string json)
        {
            using var doc = JsonDocument.Parse(json);
            var raiz = doc.RootElement;
            var mensaje = LeerTexto(raiz, "mensajeIA", "mensaje");
            if (string.IsNullOrWhiteSpace(mensaje)) return null;

            var estado = Normalizar(LeerTexto(raiz, "estado"), new[] { "NUEVO", "IA_ATENDIENDO", "EN_REVISION", "RESUELTO_POR_IA", "ESCALADO", "ASIGNADO", "RESUELTO", "CERRADO" }, "IA_ATENDIENDO");
            var categoria = Normalizar(LeerTexto(raiz, "categoria"), new[] { "RETO", "EVIDENCIA", "CONTENIDO", "CUENTA", "MONEDERO", "OTRO" }, "OTRO");
            var prioridad = Normalizar(LeerTexto(raiz, "prioridad"), new[] { "BAJA", "NORMAL", "ALTA", "URGENTE" }, "NORMAL");
            var escalar = LeerBool(raiz, "escalar");
            var resolver = LeerBool(raiz, "resolver");
            var crearReporte = LeerBool(raiz, "crearReporte");

            if (escalar) estado = "ESCALADO";
            if (resolver && !escalar) estado = "RESUELTO_POR_IA";

            return new ReglasSoporteDecision
            {
                MensajeIA = SinEmojis(mensaje).Trim(),
                Estado = estado,
                Categoria = categoria,
                Prioridad = escalar ? "URGENTE" : prioridad,
                CrearReporte = crearReporte,
                Escalar = escalar,
                Resolver = resolver && !escalar,
                MotivoEscalamiento = SinEmojis(LeerTexto(raiz, "motivoEscalamiento")),
                Sugerencias = LeerLista(raiz, "sugerencias"),
                Proveedor = "ia"
            };
        }





        private static ReglasSoporteDecision AsegurarDecisionSegura(ReglasSoporteDecision decision, ContextoSoporteIA contexto)
        {
            var textoUsuario = string.Join(" ", contexto.Historial
                .Where(m => m.Remitente == "USUARIO")
                .TakeLast(3)
                .Select(m => m.Contenido));

            if (EsContenidoSensible(textoUsuario))
            {
                decision.Escalar = true;
                decision.Resolver = false;
                decision.CrearReporte = true;
                decision.Estado = "ESCALADO";
                decision.Prioridad = "URGENTE";
                decision.MotivoEscalamiento ??= "Posible incumplimiento de las reglas de la comunidad; requiere moderacion humana.";
            }
            else if (decision.Categoria == "CONTENIDO" && decision.CrearReporte && decision.Prioridad == "NORMAL")
            {
                decision.Prioridad = "ALTA";
            }

            if (decision.Resolver && !EsConfirmacion(textoUsuario))
            {
                decision.Resolver = false;
                decision.Estado = decision.Escalar ? "ESCALADO" : "IA_ATENDIENDO";
                decision.MensajeIA += "\n\nPara poder cerrar el caso necesito que confirmes si el problema ya quedo resuelto.";
            }

            if (decision.Escalar)
            {
                decision.Resolver = false;
                decision.Estado = "ESCALADO";
                if (decision.Prioridad == "NORMAL" || decision.Prioridad == "BAJA") decision.Prioridad = "ALTA";
            }

            decision.MensajeIA = SinEmojis(decision.MensajeIA);
            decision.MotivoEscalamiento = SinEmojis(decision.MotivoEscalamiento);
            decision.Sugerencias = decision.Sugerencias
                .Select(SinEmojis)
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Distinct()
                .Take(4)
                .ToList();
            return decision;
        }

        private static readonly string[] ClavesSensibles =
        {
            "+18", "18+", "pornografia", "pornografico", "desnudo", "desnuda",
            "contenido para adultos", "acoso", "acoso sexual", "amenaza", "violencia",
            "gore", "discurso de odio", "suplantacion", "suplantar", "hack", "hackear",
            "estafa", "fraude", "extorsion", "phishing", "robo", "robar"
        };

        private static readonly string[] ClavesConfirmacion =
        {
            "ya funciona", "se resolvio", "se soluciono", "solucionado", "resuelto",
            "ya quedo", "ya pude", "funciono", "muchas gracias", "listo, gracias",
            "todo bien", "si, gracias", "sí, gracias", "perfecto"
        };

        private static bool EsContenidoSensible(string texto)
        {
            var t = (texto ?? string.Empty).ToLowerInvariant();
            return ClavesSensibles.Any(k => t.Contains(k));
        }

        private static bool EsConfirmacion(string texto)
        {
            var t = (texto ?? string.Empty).ToLowerInvariant();
            return ClavesConfirmacion.Any(k => t.Contains(k));
        }


        public async Task<EvaluacionIAEvidencia> EvaluarEvidenciaAsync(ContextoEvidenciaIA contexto)
        {
            contexto ??= new ContextoEvidenciaIA();
            if (!Configurada) return EvaluacionPorReglas(contexto);

            try
            {
                var partes = new List<object>
                {
                    new { type = "text", text = ConstruirPromptEvidencia(contexto) }
                };

                var imagenes = contexto.Imagenes.Take(_maxImagenes).ToList();
                foreach (var imagen in imagenes)
                {
                    var url = PrepararImagenParaModelo(imagen);
                    if (url is not null)
                        partes.Add(new { type = "image_url", image_url = new { url } });
                }

                var json = await LlamarAsync(
                    "Eres un evaluador de evidencias de retos de educacion ambiental. " +
                    "Trabajas SOLO con los datos entregados: nunca asumes que una evidencia existe si no llego. " +
                    "No usas emojis. Responde UNICAMENTE con un JSON valido.",
                    partes,
                    800);

                var evaluacion = InterpretarEvaluacion(json);
                if (evaluacion is null) return EvaluacionPorReglas(contexto);
                evaluacion.Proveedor = "ia";
                evaluacion.Fecha = DateTime.Now;
                return evaluacion;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "IA de evidencias no disponible; se usan reglas deterministas.");
                return EvaluacionPorReglas(contexto);
            }
        }

        private string ConstruirPromptEvidencia(ContextoEvidenciaIA contexto)
        {
            var sb = new StringBuilder();
            sb.AppendLine("Evalua si la evidencia presentada corresponde al reto.");
            sb.AppendLine();
            sb.AppendLine("DATOS DEL RETO (reales):");
            sb.AppendLine($"- Titulo: {contexto.RetoTitulo}");
            sb.AppendLine($"- Descripcion: {contexto.RetoDescripcion}");
            sb.AppendLine($"- Instrucciones: {contexto.RetoInstrucciones}");
            sb.AppendLine($"- Requisitos (JSON): {contexto.RetoRequisitos}");
            sb.AppendLine($"- Tipo de evidencia solicitada por el reto: {contexto.RetoTipoEvidencia}");
            sb.AppendLine($"- Objetivo de cantidad: {(contexto.RetoCantidadObjetivo?.ToString() ?? "no aplica")}");
            sb.AppendLine();
            sb.AppendLine("DATOS DEL USUARIO:");
            sb.AppendLine($"- Nombre: {contexto.UsuarioNombre}");
            sb.AppendLine($"- Correo: {contexto.UsuarioCorreo}");
            sb.AppendLine($"- Fecha de envio: {(contexto.FechaCompletado?.ToString("u") ?? "sin fecha")}");
            sb.AppendLine();
            sb.AppendLine("EVIDENCIA REAL RECIBIDA:");
            sb.AppendLine($"- Texto: {(string.IsNullOrWhiteSpace(contexto.EvidenciaTexto) ? "(vacio)" : contexto.EvidenciaTexto)}");
            sb.AppendLine($"- Imagenes adjuntas: {contexto.Imagenes.Count}");
            sb.AppendLine($"- Videos adjuntos: {contexto.Videos.Count}");
            if (contexto.Videos.Count > 0)
                sb.AppendLine($"- URLs de video: {string.Join(", ", contexto.Videos.Take(4))}");
            sb.AppendLine();
            sb.AppendLine("Reglas de evaluacion:");
            sb.AppendLine("1. Si el reto pide TEXTO y no pide imagen: valida solo el texto, no exijas fotografia.");
            sb.AppendLine("2. Si el reto pide FOTO/GALERIA/VIDEO: verifica que exista el archivo. Si falta, cumple=false.");
            sb.AppendLine("3. Si el reto pide texto + imagen: si falta uno, cumple=false e indica exactamente cual falta.");
            sb.AppendLine("4. Si hay imagenes pero no pueden analizarse con claridad, cumple=false o requiereRevisionHumana=true con confianza baja.");
            sb.AppendLine("5. Ante cualquier duda, contenido sospechoso o ambiguedad: requiereRevisionHumana=true.");
            sb.AppendLine("6. No inventes propiedades ni asumas datos que no aparecen arriba.");
            sb.AppendLine();
            sb.AppendLine("Devuelve un JSON con este formato exacto:");
            sb.AppendLine("{\"cumple\":false,\"confianza\":0,\"requiereRevisionHumana\":true,\"motivo\":\"explicacion breve\"," +
                          "\"elementosFaltantes\":[\"que falta\"],\"observaciones\":\"detalle adicional\"}");
            return sb.ToString();
        }

        private EvaluacionIAEvidencia? InterpretarEvaluacion(string json)
        {
            using var doc = JsonDocument.Parse(json);
            var raiz = doc.RootElement;
            var confianza = LeerInt(raiz, "confianza", 0);
            return new EvaluacionIAEvidencia
            {
                Cumple = LeerBool(raiz, "cumple"),
                Confianza = Math.Clamp(confianza, 0, 100),
                RequiereRevisionHumana = LeerBoolConDefecto(raiz, "requiereRevisionHumana", true),
                Motivo = SinEmojis(LeerTexto(raiz, "motivo")).Trim(),
                ElementosFaltantes = LeerLista(raiz, "elementosFaltantes").Select(SinEmojis).ToList(),
                Observaciones = SinEmojis(LeerTexto(raiz, "observaciones")).Trim()
            };
        }


        private static EvaluacionIAEvidencia EvaluacionPorReglas(ContextoEvidenciaIA contexto)
        {
            var tipo = (contexto.RetoTipoEvidencia ?? string.Empty).Trim().ToUpperInvariant();
            var requisitos = (contexto.RetoRequisitos ?? string.Empty).ToLowerInvariant();
            var texto = (contexto.EvidenciaTexto ?? string.Empty).Trim();
            var tieneImagenes = contexto.Imagenes.Count > 0;
            var tieneVideo = contexto.Videos.Count > 0;
            var faltantes = new List<string>();

            var pideFoto = tipo is "FOTO" or "GALERIA" or "VIDEO";
            var pideTexto = tipo is "TEXTO" or "RESPUESTA";
            var pideCantidad = tipo == "CANTIDAD";
            var requisitosPideImagen = requisitos.Contains("foto") || requisitos.Contains("fotograf") ||
                                       requisitos.Contains("imagen") || requisitos.Contains("video");
            var requisitosPideTexto = requisitos.Contains("texto") || requisitos.Contains("descrip") ||
                                      requisitos.Contains("comentario") || requisitos.Contains("explica");

            if (pideFoto && !tieneImagenes && !tieneVideo)
                faltantes.Add(tipo == "VIDEO" ? "Video de la evidencia" : "Fotografia de la evidencia");
            if (requisitosPideImagen && !tieneImagenes && !tieneVideo)
                faltantes.Add("Fotografia o video solicitado en los requisitos");
            if (pideTexto && texto.Length == 0)
                faltantes.Add("Texto de la evidencia");
            if (requisitosPideTexto && texto.Length == 0)
                faltantes.Add("Texto descriptivo solicitado en los requisitos");
            if (pideCantidad && !texto.ToLowerInvariant().Contains("cantidad"))
                faltantes.Add("Cantidad alcanzada");


            faltantes = faltantes.Distinct().ToList();

            var cumple = faltantes.Count == 0;
            var observaciones = new List<string>
            {
                "Evaluacion estructural automatica (proveedor de IA no configurado o no disponible)."
            };
            if (tieneImagenes || tieneVideo)
                observaciones.Add("No fue posible analizar el contenido visual; requiere revision humana obligatoria.");

            return new EvaluacionIAEvidencia
            {
                Cumple = cumple,
                Confianza = cumple ? (tieneImagenes || tieneVideo ? 40 : 60) : 85,
                RequiereRevisionHumana = true,
                Motivo = cumple
                    ? "La evidencia contiene los elementos solicitados por el reto. La decision final es del administrador."
                    : "Faltan elementos obligatorios para validar la evidencia.",
                ElementosFaltantes = faltantes,
                Observaciones = string.Join(" ", observaciones),
                Proveedor = "reglas"
            };
        }


        public async Task<AnalisisIAReporte> AnalizarReporteAsync(ContextoReporteIA contexto)
        {
            contexto ??= new ContextoReporteIA();
            if (!Configurada) return ReportePorReglas(contexto);

            try
            {
                var partes = new List<object>
                {
                    new { type = "text", text = ConstruirPromptReporte(contexto) }
                };
                foreach (var imagen in contexto.ContenidoImagenes.Take(_maxImagenes))
                {
                    var url = PrepararImagenParaModelo(imagen);
                    if (url is not null)
                        partes.Add(new { type = "image_url", image_url = new { url } });
                }

                var json = await LlamarAsync(
                    "Eres un moderador de contenido de una comunidad educativa. Analizas reportes y recomiendas acciones. " +
                    "La decision final siempre es del administrador humano. No usas emojis. Responde UNICAMENTE con un JSON valido.",
                    partes,
                    700);

                var analisis = InterpretarAnalisisReporte(json);
                if (analisis is null) return ReportePorReglas(contexto);
                analisis.Proveedor = "ia";
                return analisis;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "IA de reportes no disponible; se usan reglas deterministas.");
                return ReportePorReglas(contexto);
            }
        }

        private string ConstruirPromptReporte(ContextoReporteIA contexto)
        {
            var sb = new StringBuilder();
            sb.AppendLine($"Reporte #{contexto.ReporteId}");
            sb.AppendLine($"- Motivo indicado por el usuario: {contexto.Motivo}");
            sb.AppendLine($"- Descripcion: {contexto.Descripcion}");
            sb.AppendLine($"- Tipo de contenido: {contexto.TipoContenido} (#{contexto.ContenidoId})");
            sb.AppendLine($"- Texto del contenido: {contexto.ContenidoTexto}");
            sb.AppendLine($"- Enlace contenido: {contexto.Enlace}");
            sb.AppendLine($"- Imagenes del contenido: {contexto.ContenidoImagenes.Count}");
            sb.AppendLine();
            sb.AppendLine("Reglas:");
            sb.AppendLine("1. Determina si el reporte tiene fundamento segun la evidencia disponible.");
            sb.AppendLine("2. Si sugiere contenido +18, acoso, violencia o enlace sospechoso: recomendacion=OCULTAR_ADVERTIR.");
            sb.AppendLine("3. Si no hay fundamento: recomendacion=DESCARTAR.");
            sb.AppendLine("4. Ante duda o falta de evidencia: recomendacion=REVISAR, requiereRevisionHumana=true.");
            sb.AppendLine("5. Nunca ordenes eliminar informacion: la accion segura es ocultar y conservar el registro.");
            sb.AppendLine();
            sb.AppendLine("Devuelve un JSON con este formato exacto:");
            sb.AppendLine("{\"recomendacion\":\"DESCARTAR|REVISAR|ADVERTIR|OCULTAR_ADVERTIR\",\"posibleContenidoAdultos\":false," +
                          "\"confianza\":0,\"requiereRevisionHumana\":true,\"motivo\":\"explicacion\",\"observaciones\":\"detalle\"," +
                          "\"categoriaSugerida\":\"CONTENIDO\"}");
            return sb.ToString();
        }

        private AnalisisIAReporte? InterpretarAnalisisReporte(string json)
        {
            using var doc = JsonDocument.Parse(json);
            var raiz = doc.RootElement;
            var recomendacion = Normalizar(LeerTexto(raiz, "recomendacion"),
                new[] { "DESCARTAR", "REVISAR", "ADVERTIR", "OCULTAR_ADVERTIR" }, "REVISAR");
            return new AnalisisIAReporte
            {
                Recomendacion = recomendacion,
                PosibleContenidoAdultos = LeerBool(raiz, "posibleContenidoAdultos"),
                Confianza = Math.Clamp(LeerInt(raiz, "confianza", 0), 0, 100),
                RequiereRevisionHumana = LeerBoolConDefecto(raiz, "requiereRevisionHumana", true),
                Motivo = SinEmojis(LeerTexto(raiz, "motivo")).Trim(),
                Observaciones = SinEmojis(LeerTexto(raiz, "observaciones")).Trim(),
                CategoriaSugerida = Normalizar(LeerTexto(raiz, "categoriaSugerida"),
                    new[] { "RETO", "EVIDENCIA", "CONTENIDO", "CUENTA", "MONEDERO", "OTRO" }, "CONTENIDO")
            };
        }

        private static AnalisisIAReporte ReportePorReglas(ContextoReporteIA contexto)
        {
            var texto = $"{contexto.Motivo} {contexto.Descripcion} {contexto.ContenidoTexto}".ToLowerInvariant();
            var posibles = new[] { "+18", "18+", "adultos", "pornograf", "desnud", "acoso", "violencia", "amenaza", "gore", "odio" };
            var esAdultos = posibles.Any(k => texto.Contains(k));

            return new AnalisisIAReporte
            {
                Recomendacion = esAdultos ? "OCULTAR_ADVERTIR" : "REVISAR",
                PosibleContenidoAdultos = esAdultos,
                Confianza = esAdultos ? 65 : 35,
                RequiereRevisionHumana = true,
                Motivo = esAdultos
                    ? "El reporte y/o el contenido contienen indicios de material no permitido. Se recomienda ocultar y advertir, conservando el registro y la evidencia."
                    : "No hay elementos suficientes para confirmar una infraccion. Requiere revision humana del contenido completo.",
                Observaciones = "Analisis automatico conservador; la decision final corresponde al administrador.",
                Proveedor = "reglas"
            };
        }


        private async Task<string> LlamarAsync(string systemPrompt, List<object> partesUsuario, int maxTokens)
        {
            var cuerpo = new Dictionary<string, object>
            {
                ["model"] = _modelo,
                ["temperature"] = 0.2,
                ["max_tokens"] = maxTokens,
                ["messages"] = new object[]
                {
                    new { role = "system", content = systemPrompt },
                    new { role = "user", content = partesUsuario.ToArray() }
                },
                ["response_format"] = new { type = "json_object" }
            };

            var respuesta = await EnviarAsync(cuerpo, conFormatoJson: true);
            return respuesta;
        }

        private async Task<string> EnviarAsync(Dictionary<string, object> cuerpo, bool conFormatoJson)
        {
            using var cliente = _httpFactory.CreateClient();
            cliente.Timeout = TimeSpan.FromSeconds(_timeoutSegundos);
            cliente.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _apiKey);
            cliente.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(_timeoutSegundos));
            var contenido = new StringContent(JsonSerializer.Serialize(cuerpo), Encoding.UTF8, "application/json");
            using var respuesta = await cliente.PostAsync($"{_baseUrl}/chat/completions", contenido, cts.Token);

            if (!respuesta.IsSuccessStatusCode && conFormatoJson)
            {


                cuerpo.Remove("response_format");
                return await EnviarAsync(cuerpo, conFormatoJson: false);
            }

            var texto = await respuesta.Content.ReadAsStringAsync(cts.Token);
            if (!respuesta.IsSuccessStatusCode)
                throw new HttpRequestException($"Proveedor de IA respondio {(int)respuesta.StatusCode}: {Recortar(texto, 300)}");

            return ExtraerContenido(texto);
        }

        private static string ExtraerContenido(string cuerpoRespuesta)
        {
            using var doc = JsonDocument.Parse(cuerpoRespuesta);
            var raiz = doc.RootElement;
            if (!raiz.TryGetProperty("choices", out var choices) || choices.GetArrayLength() == 0)
                throw new InvalidOperationException("La respuesta del proveedor de IA no contiene choices.");

            var mensaje = choices[0].GetProperty("message");
            var contenido = mensaje.GetProperty("content").GetString() ?? string.Empty;


            var inicio = contenido.IndexOf('{');
            var fin = contenido.LastIndexOf('}');
            if (inicio >= 0 && fin > inicio) contenido = contenido[inicio..(fin + 1)];
            return contenido;
        }







        private string? PrepararImagenParaModelo(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return url;
            try
            {
                var marcador = "/api/Imagenes/archivo/";
                var indice = url.IndexOf(marcador, StringComparison.OrdinalIgnoreCase);
                if (indice < 0) return url;

                var relativa = url[(indice + marcador.Length)..];
                var partes = relativa.Split('/', StringSplitOptions.RemoveEmptyEntries);
                if (partes.Length < 2) return url;

                var subcarpeta = partes[0];
                var nombre = Path.GetFileName(partes[1]);
                var ruta = Path.Combine(RaizWeb(), "imagenes", subcarpeta, nombre);
                if (!File.Exists(ruta)) return url;

                var info = new FileInfo(ruta);
                if (info.Length > 8L * 1024 * 1024) return url;

                var bytes = File.ReadAllBytes(ruta);
                var mime = ExtensionAMime(Path.GetExtension(nombre));
                return $"data:{mime};base64,{Convert.ToBase64String(bytes)}";
            }
            catch
            {
                return url;
            }
        }

        private static bool EsUrlVideo(string? url)
        {
            var texto = (url ?? string.Empty).ToLowerInvariant();
            return texto.Contains(".mp4") || texto.Contains(".mov") || texto.Contains(".webm") || texto.Contains(".m4v");
        }


        private static string RaizWeb()
        {
            var candidatas = new[]
            {
                Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"),
                Path.Combine(AppContext.BaseDirectory, "wwwroot")
            };
            foreach (var candidata in candidatas)
            {
                if (Directory.Exists(candidata)) return candidata;
            }
            return candidatas[0];
        }

        private static string ExtensionAMime(string extension) => extension.ToLowerInvariant() switch
        {
            ".png" => "image/png",
            ".jpg" or ".jpeg" => "image/jpeg",
            ".webp" => "image/webp",
            ".gif" => "image/gif",
            _ => "application/octet-stream"
        };


        private static string LeerTexto(JsonElement raiz, params string[] claves)
        {
            foreach (var clave in claves)
            {
                if (raiz.TryGetProperty(clave, out var valor) && valor.ValueKind == JsonValueKind.String)
                    return valor.GetString() ?? string.Empty;
            }
            return string.Empty;
        }

        private static bool LeerBool(JsonElement raiz, string clave)
        {
            if (!raiz.TryGetProperty(clave, out var valor)) return false;
            return valor.ValueKind switch
            {
                JsonValueKind.True => true,
                JsonValueKind.False => false,
                JsonValueKind.String => bool.TryParse(valor.GetString(), out var b) && b,
                _ => false
            };
        }

        private static bool LeerBoolConDefecto(JsonElement raiz, string clave, bool porDefecto)
        {
            if (!raiz.TryGetProperty(clave, out var valor)) return porDefecto;
            return valor.ValueKind switch
            {
                JsonValueKind.True => true,
                JsonValueKind.False => false,
                JsonValueKind.String => bool.TryParse(valor.GetString(), out var b) ? b : porDefecto,
                _ => porDefecto
            };
        }

        private static int LeerInt(JsonElement raiz, string clave, int porDefecto)
        {
            if (!raiz.TryGetProperty(clave, out var valor)) return porDefecto;
            if (valor.ValueKind == JsonValueKind.Number && valor.TryGetInt32(out var numero)) return numero;
            if (valor.ValueKind == JsonValueKind.String &&
                int.TryParse(valor.GetString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out numero))
                return numero;
            return porDefecto;
        }

        private static List<string> LeerLista(JsonElement raiz, string clave)
        {
            var lista = new List<string>();
            if (!raiz.TryGetProperty(clave, out var valor) || valor.ValueKind != JsonValueKind.Array)
                return lista;
            foreach (var item in valor.EnumerateArray())
            {
                if (item.ValueKind == JsonValueKind.String)
                {
                    var texto = item.GetString();
                    if (!string.IsNullOrWhiteSpace(texto)) lista.Add(texto.Trim());
                }
            }
            return lista;
        }

        private static string Normalizar(string? valor, string[] validos, string porDefecto)
        {
            var v = (valor ?? string.Empty).Trim().ToUpperInvariant();
            return validos.Contains(v) ? v : porDefecto;
        }

        private static string Recortar(string texto, int maximo)
            => texto.Length <= maximo ? texto : texto[..maximo];


        public static string SinEmojis(string? texto)
        {
            if (string.IsNullOrEmpty(texto)) return string.Empty;
            var sb = new StringBuilder(texto.Length);
            foreach (var rune in texto.EnumerateRunes())
            {
                var valor = rune.Value;
                var esEmoji =
                    (valor >= 0x1F000 && valor <= 0x1FAFF) ||
                    (valor >= 0x2600 && valor <= 0x27BF) ||
                    (valor >= 0x2B00 && valor <= 0x2BFF) ||
                    (valor >= 0x1F1E6 && valor <= 0x1F1FF) ||
                    valor == 0xFE0F || valor == 0x200D || valor == 0x20E3;
                if (!esEmoji) sb.Append(rune);
            }
            return System.Text.RegularExpressions.Regex.Replace(sb.ToString(), @"[ \t]{2,}", " ").Trim();
        }
    }
}
