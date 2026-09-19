using System.Text.RegularExpressions;

namespace WebApi.Implementacion.Helpers
{










    public static class EvidenciaParser
    {
        private static readonly Regex UrlRegex = new(@"https?://[^\s,;]+", RegexOptions.IgnoreCase | RegexOptions.Compiled);
        private static readonly string[] ExtensionesVideo = { ".mp4", ".mov", ".webm", ".m4v" };
        private static readonly string[] ExtensionesImagen = { ".png", ".jpg", ".jpeg", ".webp", ".gif" };

        public class EvidenciaParseada
        {
            public string Texto { get; set; } = string.Empty;
            public List<string> Imagenes { get; set; } = new();
            public List<string> Videos { get; set; } = new();
            public List<string> Enlaces { get; set; } = new();
        }

        public static EvidenciaParseada Parse(string? evidencia)
        {
            var resultado = new EvidenciaParseada();
            if (string.IsNullOrWhiteSpace(evidencia)) return resultado;

            var lineas = evidencia.Replace("\r\n", "\n").Split('\n');
            var partesTexto = new List<string>();

            foreach (var lineaOriginal in lineas)
            {
                var linea = lineaOriginal.Trim();
                if (linea.Length == 0) continue;

                var esLineaFotos = linea.StartsWith("Fotos:", StringComparison.OrdinalIgnoreCase);
                var sinEtiqueta = esLineaFotos ? linea["Fotos:".Length..].Trim() : linea;

                foreach (Match match in UrlRegex.Matches(sinEtiqueta))
                    ClasificarUrl(match.Value, resultado);

                var sinUrls = UrlRegex.Replace(sinEtiqueta, string.Empty).Trim(' ', ',', ';', '-');
                if (sinUrls.Length == 0) continue;

                if (esLineaFotos)
                {

                    continue;
                }

                partesTexto.Add(sinUrls);
            }

            resultado.Texto = string.Join("\n", partesTexto).Trim();
            return resultado;
        }

        private static void ClasificarUrl(string url, EvidenciaParseada resultado)
        {
            var limpia = url.Trim().TrimEnd('.', ',', ';');
            var sinQuery = limpia.Split('?')[0].ToLowerInvariant();

            if (ExtensionesVideo.Any(e => sinQuery.EndsWith(e)))
            {
                if (!resultado.Videos.Contains(limpia)) resultado.Videos.Add(limpia);
                return;
            }

            if (ExtensionesImagen.Any(e => sinQuery.EndsWith(e)))
            {
                if (!resultado.Imagenes.Contains(limpia)) resultado.Imagenes.Add(limpia);
                return;
            }

            if (!resultado.Enlaces.Contains(limpia)) resultado.Enlaces.Add(limpia);
        }
    }
}
