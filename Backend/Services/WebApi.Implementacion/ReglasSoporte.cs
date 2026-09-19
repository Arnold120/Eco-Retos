namespace WebApi.Implementacion
{
    /// <summary>
    /// Motor de reglas del soporte (sustituye temporalmente al LLM).
    /// Mantiene EXACTAMENTE el contrato que consumirá la web y que un futuro
    /// proveedor de IA deberá devolver: mensaje, estado, categoría, prioridad,
    /// escalar, crearReporte, motivoEscalamiento y sugerencias.
    /// </summary>
    public static class ReglasSoporte
    {
        public class DecisionIA
        {
            public string MensajeIA { get; set; } = string.Empty;
            public string Estado { get; set; } = "IA_ATENDIENDO";
            public string Categoria { get; set; } = "OTRO";
            public string Prioridad { get; set; } = "NORMAL";
            public bool CrearReporte { get; set; }
            public bool Escalar { get; set; }
            public bool Resolver { get; set; }
            public string? MotivoEscalamiento { get; set; }
            public List<string> Sugerencias { get; set; } = new();
        }

        private static readonly string[] ClavesEscalar =
        {
            "hablar con un humano", "hablar con alguien", "persona real", "administrador",
            "urgente", "grave", "seguridad", "amenaza", "suplantacion", "suplantar",
            "hack", "hackear", "robar", "robo", "estafa", "fraude", "extorsion",
            "phishing", "enlace sospechoso", "doble cobro", "cobro indebido", "reclamo",
            "banearon", "me banearon", "bloquearon mi cuenta", "no puedo entrar a mi cuenta"
        };

        private static readonly string[] ClavesGraves =
        {
            "+18", "18+", "contenido para adultos", "pornografico", "pornografia",
            "inapropiado", "acoso", "acoso sexual", "bullying", "ofensivo", "violencia",
            "desnudo", "desnuda", "fotografia inapropiada", "video inapropiado",
            "enlace inapropiado", "discurso de odio", "gore"
        };

        private static readonly string[] ClavesConfirmacion =
        {
            "ya funciona", "se resolvio", "se soluciono", "solucionado", "resuelto",
            "ya quedo", "ya pude", "funciono", "perfecto, gracias", "muchas gracias",
            "listo, gracias", "todo bien"
        };

        private static readonly string[] ClavesPersiste =
        {
            "sigue", "sigue fallando", "no funciona", "no me funciona", "persiste",
            "otra vez", "de nuevo", "no se arreglo", "sigue igual", "no sirvio",
            "sin solucion", "mismo error", "mismo problema"
        };

        private static readonly string[] ClavesEvidencia =
        {
            "adjunto", "adjunte", "esta es la captura", "captura", "foto", "imagen",
            "archivo", "evidencia", "mira", "te envio"
        };

        private static readonly string[] ClavesDinero =
            { "moneda", "monedas", "monedero", "saldo", "puntos", "recompensa", "compra", "pago" };

        private static readonly string[] ClavesCuenta =
            { "correo", "contrasena", "login", "cuenta", "sesion", "password", "email", "registrar" };

        private static readonly string[] ClavesContenido =
            { "reportar", "reporte", "publicacion", "muro", "comunidad", "denuncia", "comentario" };

        private static readonly string[] ClavesError =
            { "error", "falla", "bug", "cierra", "crash", "no abre", "no carga", "pantalla", "se queda", "actualizacion", "version" };

        private static bool Contiene(string texto, string[] claves)
        {
            var t = texto.ToLowerInvariant();
            return claves.Any(k => t.Contains(k));
        }

        private static string Clasificar(string texto)
        {
            var t = texto.ToLowerInvariant();
            if (System.Text.RegularExpressions.Regex.IsMatch(t, "(reto|retos|evidencia|evidencias|insignia|racha|trivia|quiz|complete|complet)"))
                return "RETO";
            if (System.Text.RegularExpressions.Regex.IsMatch(t, "(reportar|reporte|publicacion|muro|comunidad|denuncia|comentario)"))
                return "CONTENIDO";
            if (Contiene(t, ClavesDinero)) return "MONEDERO";
            if (Contiene(t, ClavesCuenta)) return "CUENTA";
            if (Contiene(t, ClavesError)) return "OTRO";
            return "OTRO";
        }

        private static string PrioridadDe(string categoria, bool escalar)
        {
            if (escalar) return "URGENTE";
            if (categoria == "CONTENIDO") return "ALTA";
            return "NORMAL";
        }

        private static string PreguntaPrimera(string categoria) => categoria switch
        {
            "RETO" => "¡Gracias por escribirnos! Voy a ayudarte con tu reto. ¿Qué reto estabas realizando y qué ocurre exactamente al completarlo o enviar la evidencia?",
            "CONTENIDO" => "Gracias por cuidar la comunidad. ¿Qué tipo de contenido deseas reportar? (contenido +18, acoso, violencia, enlace sospechoso, otro)",
            "MONEDERO" => "Voy a revisarlo contigo. ¿El reto figura como \"Completado\" en tu lista o sigue \"En revisión\" cuando no te llegan las monedas?",
            "CUENTA" => "Claro, te ayudo con tu cuenta. ¿Qué necesitas exactamente? (cambiar correo, recuperar contraseña, desbloquear cuenta, otro)",
            _ => "Entiendo. Para ubicar el problema: ¿en qué momento ocurre y en qué dispositivo lo usas? (Android, iPhone o web)"
        };

        private static string PreguntaSegunda(string categoria) => categoria switch
        {
            "RETO" => "Entiendo. ¿Puedes adjuntar una captura donde se vea el error o la evidencia que enviaste? Con eso reviso con precisión qué pasó.",
            "CONTENIDO" => "¿Puedes adjuntar una captura del contenido? No es obligatorio, pero ayuda a que el equipo de moderación lo revise más rápido.",
            "MONEDERO" => "¿Hace cuánto completaste la actividad? Las monedas se acreditan automáticamente hasta 24 horas después de la aprobación.",
            "CUENTA" => "¿Ya intentaste hacerlo desde Configuración en la app? Cuéntame qué mensaje o error aparece exactamente.",
            _ => "¿La app está actualizada a la última versión? ¿Te aparece algún mensaje de error? Si puedes, adjunta una captura."
        };

        private static string? RespuestaResuelta(string categoria) => categoria switch
        {
            "MONEDERO" => "Con lo que me cuentas puedo resolverlo: las monedas se acreditan automáticamente dentro de las 24 horas posteriores a la aprobación del reto. Si después de ese tiempo no aparecen, escribe de nuevo aquí y lo escalamos a un administrador.",
            "CUENTA" => "Puedo guiarte: cambia tu correo o contraseña desde Configuración → \"Nombre de usuario y correo\" o \"Cambiar contraseña\". Si no recuerdas tu contraseña, usa \"Olvidé mi contraseña\" en la pantalla de inicio de sesión.",
            _ => null
        };

        private static List<string> Sugerencias(string categoria) => categoria switch
        {
            "RETO" => new List<string> { "Adjuntar captura", "No me deja enviar la evidencia", "El reto no me aparece" },
            "CONTENIDO" => new List<string> { "Adjuntar captura", "Es contenido +18", "Es acoso o violencia" },
            "MONEDERO" => new List<string> { "Completé el reto", "Sigue en revisión", "No me llegaron las monedas" },
            "CUENTA" => new List<string> { "Quiero cambiar mi correo", "Olvidé mi contraseña", "No puedo iniciar sesión" },
            _ => new List<string> { "Adjuntar captura", "La app se cierra", "Es un error de la app" }
        };

        /// <summary>
        /// Analiza el mensaje del usuario y decide la siguiente acción.
        /// </summary>
        /// <param name="texto">Mensaje del usuario.</param>
        /// <param name="cantidadMensajesUsuario">Mensajes ya enviados por el usuario (incluye este).</param>
        /// <param name="categoriaCaso">Categoría elegida al crear el caso (manda sobre la detección).</param>
        /// <param name="tieneAdjuntos">Si el mensaje trae archivos.</param>
        public static DecisionIA Analizar(string texto, int cantidadMensajesUsuario, string? categoriaCaso, bool tieneAdjuntos)
        {
            texto ??= string.Empty;
            var n = cantidadMensajesUsuario < 1 ? 1 : cantidadMensajesUsuario;
            var grave = Contiene(texto, ClavesGraves) || Contiene(texto, ClavesEscalar);
            var confirmacion = Contiene(texto, ClavesConfirmacion);
            var persiste = Contiene(texto, ClavesPersiste);
            var mencionaEvidencia = tieneAdjuntos || Contiene(texto, ClavesEvidencia);
            var detectada = Clasificar(texto);
            var categoria = !string.IsNullOrWhiteSpace(categoriaCaso) && !grave ? categoriaCaso! : detectada;

            /* 1. El usuario confirma que se solucionó. */
            if (confirmacion && !grave)
            {
                return new DecisionIA
                {
                    MensajeIA = "Qué bueno saberlo. Marco el caso como resuelto. Si el problema vuelve a aparecer, puedes abrir una nueva conversación y te ayudamos de inmediato.",
                    Estado = "RESUELTO_POR_IA",
                    Categoria = categoria,
                    Prioridad = PrioridadDe(categoria, false),
                    Resolver = true,
                    Sugerencias = new List<string> { "¡Gracias!", "Tengo otro problema" }
                };
            }

            /* 2. Caso grave o petición explícita de humano → escalar. */
            if (grave)
            {
                var esContenidoGrave = Contiene(texto, ClavesGraves);
                return new DecisionIA
                {
                    MensajeIA = esContenidoGrave
                        ? "Esto es importante y requiere revisión humana. He creado un reporte estructurado y escalado tu caso a un administrador, que lo revisará lo antes posible. Te notificaremos el resultado."
                        : "Entiendo, voy a escalar tu caso a un administrador humano para que te atienda personalmente. He dejado todo el contexto del problema en el reporte. Te responderán por aquí.",
                    Estado = "ESCALADO",
                    Categoria = categoria,
                    Prioridad = "URGENTE",
                    CrearReporte = true,
                    Escalar = true,
                    MotivoEscalamiento = esContenidoGrave
                        ? "Reporte grave detectado por la IA (posible contenido inapropiado). Requiere moderación humana."
                        : "El usuario solicitó intervención humana tras el diagnóstico de la IA.",
                    Sugerencias = new List<string> { "Gracias, espero respuesta" }
                };
            }

            /* 3. El problema sigue tras intentar resolverlo → escalar. */
            if (persiste && n >= 3)
            {
                return new DecisionIA
                {
                    MensajeIA = "Comprendo que el problema continúa. Como ya intentamos la solución y sigue ocurriendo, lo escalo a un administrador para que lo revise a fondo. Te avisaremos por aquí.",
                    Estado = "ESCALADO",
                    Categoria = categoria,
                    Prioridad = PrioridadDe(categoria, false),
                    CrearReporte = true,
                    Escalar = true,
                    MotivoEscalamiento = "La solución propuesta por la IA no funcionó; requiere revisión humana.",
                    Sugerencias = new List<string> { "Gracias" }
                };
            }

            /* 4. Primer mensaje → pregunta de diagnóstico. */
            if (n == 1)
            {
                return new DecisionIA
                {
                    MensajeIA = PreguntaPrimera(categoria),
                    Estado = "IA_ATENDIENDO",
                    Categoria = categoria,
                    Prioridad = PrioridadDe(categoria, false),
                    Sugerencias = Sugerencias(categoria)
                };
            }

            /* 5. Segundo mensaje. */
            if (n == 2)
            {
                if (tieneAdjuntos || mencionaEvidencia)
                {
                    return new DecisionIA
                    {
                        MensajeIA = "Recibí tu información. Voy a revisarla. Si el problema no puede resolverse automáticamente, lo escalaré a un administrador con toda la evidencia adjunta.",
                        Estado = "EN_REVISION",
                        Categoria = categoria,
                        Prioridad = PrioridadDe(categoria, false),
                        Sugerencias = new List<string> { "Gracias", "Sigue sin funcionar" }
                    };
                }

                var resuelta = RespuestaResuelta(categoria);
                if (resuelta is not null)
                {
                    return new DecisionIA
                    {
                        MensajeIA = resuelta + " ¿Te sirvió esta información?",
                        Estado = "RESUELTO_POR_IA",
                        Categoria = categoria,
                        Prioridad = PrioridadDe(categoria, false),
                        Resolver = true,
                        Sugerencias = new List<string> { "Sí, gracias", "No, sigue igual" }
                    };
                }

                return new DecisionIA
                {
                    MensajeIA = PreguntaSegunda(categoria),
                    Estado = "IA_ATENDIENDO",
                    Categoria = categoria,
                    Prioridad = PrioridadDe(categoria, false),
                    Sugerencias = Sugerencias(categoria)
                };
            }

            /* 6. Mensajes siguientes → escalar con contexto. */
            return new DecisionIA
            {
                MensajeIA = "He agotado las alternativas que puedo resolver por aquí. Voy a escalar tu caso a un administrador humano con todo el historial para darte una solución definitiva. Gracias por tu paciencia.",
                Estado = "ESCALADO",
                Categoria = categoria,
                Prioridad = PrioridadDe(categoria, false),
                CrearReporte = true,
                Escalar = true,
                MotivoEscalamiento = categoria == "RETO"
                    ? "El usuario necesita validación de la evidencia o del reto, algo que solo puede hacer un humano."
                    : "La IA no pudo resolver el problema con la información disponible; requiere intervención humana.",
                Sugerencias = new List<string> { "Gracias" }
            };
        }
    }
}
