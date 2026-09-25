using System.Net.Http.Headers;
using System.Net.Http.Json;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class FirebaseNotificationService : IFirebaseNotificationService
    {
        private const string FirebaseMessagingScope =
            "https://www.googleapis.com/auth/firebase.messaging";
        private readonly IDispositivoService _dispositivoService;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly ILogger<FirebaseNotificationService> _logger;

        public FirebaseNotificationService(
            IDispositivoService dispositivoService,
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration,
            ILogger<FirebaseNotificationService> logger)
        {
            _dispositivoService = dispositivoService;
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task EnviarAsync(Notificacion notificacion)
        {
            var projectId = _configuration["Firebase:ProjectId"];
            var serviceAccountJson = _configuration["Firebase:ServiceAccountJson"];
            var serviceAccountPath = _configuration["Firebase:ServiceAccountPath"];
            if (string.IsNullOrWhiteSpace(serviceAccountJson) &&
                !string.IsNullOrWhiteSpace(serviceAccountPath) &&
                File.Exists(serviceAccountPath))
            {
                serviceAccountJson = await File.ReadAllTextAsync(serviceAccountPath);
            }
            if (string.IsNullOrWhiteSpace(projectId) ||
                string.IsNullOrWhiteSpace(serviceAccountJson))
            {
                _logger.LogWarning(
                    "FCM no configurado. Configure Firebase:ProjectId y " +
                    "Firebase:ServiceAccountPath o Firebase:ServiceAccountJson.");
                return;
            }

            var dispositivos = await _dispositivoService.ObtenerActivosAsync(notificacion.UsuarioId);
            if (!dispositivos.Any()) return;

            var credential = GoogleCredential
                .FromJson(serviceAccountJson)
                .CreateScoped(FirebaseMessagingScope);
            var accessToken = await credential.UnderlyingCredential.GetAccessTokenForRequestAsync();
            var client = _httpClientFactory.CreateClient();
            client.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", accessToken);

            foreach (var dispositivo in dispositivos)
            {
                var response = await client.PostAsJsonAsync(
                    $"https://fcm.googleapis.com/v1/projects/{projectId}/messages:send",
                    CrearSolicitud(dispositivo.Token, notificacion));
                if (!response.IsSuccessStatusCode)
                {
                    var detalle = await response.Content.ReadAsStringAsync();
                    _logger.LogWarning(
                        "FCM rechazo el token {Token}: {Status} {Detalle}",
                        dispositivo.Token,
                        response.StatusCode,
                        detalle);
                }
            }
        }

        private static object CrearSolicitud(string token, Notificacion notificacion)
        {
            var data = new Dictionary<string, string>
            {
                ["screen"] = ObtenerSeccion(notificacion),
                ["referenceType"] = notificacion.ReferenciaTipo ?? string.Empty,
                ["referenceId"] = notificacion.ReferenciaId?.ToString() ?? string.Empty,
                ["notificationId"] = notificacion.NotificacionId.ToString()
            };

            return new
            {
                message = new
                {
                    token,
                    notification = new
                    {
                        title = notificacion.Titulo,
                        body = notificacion.Mensaje
                    },
                    data,
                    android = new
                    {
                        priority = "high",
                        notification = new
                        {
                            channel_id = "eco_reto_notificaciones_v1",
                            sound = "notificacion"
                        }
                    },
                    apns = new
                    {
                        payload = new
                        {
                            aps = new
                            {
                                sound = "default"
                            }
                        }
                    }
                }
            };
        }

        private static string ObtenerSeccion(Notificacion notificacion)
        {
            var referencia = notificacion.ReferenciaTipo?.ToUpperInvariant();
            return referencia switch
            {
                "RETO" or "USUARIORETO" => "challenges",
                "TRIVIA" or "PREGUNTA" => "trivia",
                "PUBLICACION" or "COMENTARIO" or "REACCION" or "SEGUIMIENTO" => "community",
                "PERFIL" or "INSIGNIA" => "profile",
                _ => "notifications"
            };
        }
    }
}
