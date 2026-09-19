using System.Net;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace WebApi.Controllers
{
    /// <summary>
    /// Obtiene metadatos (Open Graph) de un enlace externo para construir la
    /// vista previa en el compositor de publicaciones.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class EnlacesController : ControllerBase
    {
        private static readonly Regex MetaRegex = new(
            "<meta[^>]+(?:property|name)=[\"'](?<clave>[^\"']+)[\"'][^>]+content=[\"'](?<valor>[^\"']*)[\"'][^>]*>",
            RegexOptions.IgnoreCase | RegexOptions.Compiled);

        private static readonly Regex MetaRegexInvertida = new(
            "<meta[^>]+content=[\"'](?<valor>[^\"']*)[\"'][^>]+(?:property|name)=[\"'](?<clave>[^\"']+)[\"'][^>]*>",
            RegexOptions.IgnoreCase | RegexOptions.Compiled);

        private static readonly Regex TitleRegex = new(
            "<title[^>]*>(?<titulo>.*?)</title>",
            RegexOptions.IgnoreCase | RegexOptions.Singleline | RegexOptions.Compiled);

        private static readonly Regex ImageLinkRegex = new(
            "<link[^>]+rel=[\"']image_src[\"'][^>]+href=[\"'](?<url>[^\"']+)[\"']",
            RegexOptions.IgnoreCase | RegexOptions.Compiled);

        private readonly IHttpClientFactory _httpClientFactory;
        private readonly ILogger<EnlacesController> _logger;

        public EnlacesController(
            IHttpClientFactory httpClientFactory,
            ILogger<EnlacesController> logger)
        {
            _httpClientFactory = httpClientFactory;
            _logger = logger;
        }

        [HttpGet("preview")]
        [ProducesResponseType(typeof(EnlacePreviewResponse), StatusCodes.Status200OK)]
        public async Task<IActionResult> Preview([FromQuery] string url)
        {
            var resultado = new EnlacePreviewResponse { Url = url ?? string.Empty };
            if (string.IsNullOrWhiteSpace(url) ||
                !Uri.TryCreate(url.Trim(), UriKind.Absolute, out var uri) ||
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
            {
                resultado.Disponible = false;
                return Ok(resultado);
            }

            resultado.Dominio = uri.Host;
            if (EsHostPrivado(uri.Host))
            {
                resultado.Disponible = false;
                return Ok(resultado);
            }

            try
            {
                var cliente = _httpClientFactory.CreateClient();
                cliente.Timeout = TimeSpan.FromSeconds(8);
                // Varios sitios (YouTube, Teams, medios) bloquean agentes
                // desconocidos; se usa un agente de navegador realista.
                cliente.DefaultRequestHeaders.UserAgent.ParseAdd(
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
                    "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36");
                cliente.DefaultRequestHeaders.Accept.ParseAdd(
                    "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
                cliente.DefaultRequestHeaders.AcceptLanguage.ParseAdd(
                    "es-ES,es;q=0.9,en;q=0.8");

                using var respuesta = await cliente.GetAsync(
                    uri, HttpCompletionOption.ResponseHeadersRead);
                if (!respuesta.IsSuccessStatusCode)
                {
                    return Ok(resultado);
                }

                var tipo = respuesta.Content.Headers.ContentType?.MediaType ?? string.Empty;
                if (!tipo.Contains("html", StringComparison.OrdinalIgnoreCase))
                {
                    resultado.Disponible = tipo.StartsWith("image/", StringComparison.OrdinalIgnoreCase);
                    resultado.Imagen = resultado.Disponible ? uri.ToString() : null;
                    return Ok(resultado);
                }

                var html = await LeerConLimiteAsync(respuesta, 600_000);
                var metas = ExtraerMetas(html);

                resultado.Titulo = Primero(metas, "og:title")
                    ?? Primero(metas, "twitter:title")
                    ?? ExtraerTitulo(html);
                resultado.Descripcion = Primero(metas, "og:description")
                    ?? Primero(metas, "twitter:description")
                    ?? Primero(metas, "description");
                var imagen = Primero(metas, "og:image")
                    ?? Primero(metas, "og:image:secure_url")
                    ?? Primero(metas, "twitter:image")
                    ?? Primero(metas, "twitter:image:src")
                    ?? ExtraerImagenLink(html);
                if (!string.IsNullOrWhiteSpace(imagen) &&
                    Uri.TryCreate(uri, imagen, out var absoluta))
                {
                    resultado.Imagen = absoluta.ToString();
                }

                resultado.Dominio = Primero(metas, "og:site_name") ?? uri.Host;
                resultado.Disponible = !string.IsNullOrWhiteSpace(resultado.Titulo)
                    || !string.IsNullOrWhiteSpace(resultado.Descripcion)
                    || resultado.Imagen is not null;
            }
            catch (Exception ex)
            {
                _logger.LogInformation(ex, "No se pudo obtener la vista previa de {Url}", url);
                resultado.Disponible = false;
            }

            return Ok(resultado);
        }

        private static async Task<string> LeerConLimiteAsync(HttpResponseMessage respuesta, int limite)
        {
            await using var stream = await respuesta.Content.ReadAsStreamAsync();
            using var reader = new StreamReader(stream);
            var buffer = new char[8192];
            var total = 0;
            var builder = new System.Text.StringBuilder();
            int leidos;
            while ((leidos = await reader.ReadAsync(buffer, 0, buffer.Length)) > 0)
            {
                builder.Append(buffer, 0, leidos);
                total += leidos;
                if (total >= limite) break;
            }
            return builder.ToString();
        }

        private static Dictionary<string, string> ExtraerMetas(string html)
        {
            var metas = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            foreach (Match match in MetaRegex.Matches(html))
            {
                metas.TryAdd(match.Groups["clave"].Value.Trim(), match.Groups["valor"].Value.Trim());
            }
            foreach (Match match in MetaRegexInvertida.Matches(html))
            {
                metas.TryAdd(match.Groups["clave"].Value.Trim(), match.Groups["valor"].Value.Trim());
            }
            return metas;
        }

        private static string? Primero(Dictionary<string, string> metas, string clave)
        {
            return metas.TryGetValue(clave, out var valor) && !string.IsNullOrWhiteSpace(valor)
                ? WebUtility.HtmlDecode(valor)
                : null;
        }

        private static string? ExtraerTitulo(string html)
        {
            var match = TitleRegex.Match(html);
            return match.Success
                ? WebUtility.HtmlDecode(match.Groups["titulo"].Value.Trim())
                : null;
        }

        private static string? ExtraerImagenLink(string html)
        {
            var match = ImageLinkRegex.Match(html);
            return match.Success ? match.Groups["url"].Value.Trim() : null;
        }

        private static bool EsHostPrivado(string host)
        {
            if (host.Equals("localhost", StringComparison.OrdinalIgnoreCase) ||
                host.EndsWith(".local", StringComparison.OrdinalIgnoreCase) ||
                host.EndsWith(".internal", StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            if (!IPAddress.TryParse(host, out var ip)) return false;
            if (IPAddress.IsLoopback(ip)) return true;

            var bytes = ip.GetAddressBytes();
            if (bytes.Length == 4)
            {
                return bytes[0] == 10
                    || (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31)
                    || (bytes[0] == 192 && bytes[1] == 168)
                    || (bytes[0] == 169 && bytes[1] == 254)
                    || bytes[0] == 127;
            }

            return ip.IsIPv6LinkLocal || ip.IsIPv6SiteLocal;
        }
    }

    public class EnlacePreviewResponse
    {
        public string Url { get; set; } = string.Empty;
        public string? Titulo { get; set; }
        public string? Descripcion { get; set; }
        public string? Imagen { get; set; }
        public string? Dominio { get; set; }
        public bool Disponible { get; set; }
    }
}
