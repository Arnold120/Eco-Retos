using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace WebApi.Controllers
{




    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ImagenesController : ControllerBase
    {
        private static readonly string[] FormatosImagen =
            { ".png", ".jpg", ".jpeg", ".webp", ".gif" };

        private static readonly string[] FormatosVideo =
            { ".mp4", ".mov", ".webm", ".m4v" };

        private const long TamanoMaximoImagen = 8L * 1024 * 1024;
        private const long TamanoMaximoVideo = 100L * 1024 * 1024;

        private readonly IWebHostEnvironment _env;
        private readonly ILogger<ImagenesController> _logger;

        public ImagenesController(
            IWebHostEnvironment env,
            ILogger<ImagenesController> logger)
        {
            _env = env;
            _logger = logger;
        }


        [HttpPost]
        [Consumes("multipart/form-data")]
        [RequestSizeLimit(101L * 1024 * 1024)]
        [ProducesResponseType(typeof(SubirImagenResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Subir([FromForm] SubirImagenRequest request)
        {




            var archivo = request.Archivo;
            if (archivo is null || archivo.Length == 0)
                return BadRequest(new { mensaje = "No se recibio ningun archivo." });

            var extension = Path.GetExtension(archivo.FileName).ToLowerInvariant();
            var esVideo = FormatosVideo.Contains(extension);
            var esImagen = FormatosImagen.Contains(extension);

            if (!esVideo && !esImagen)
                return BadRequest(new
                {
                    mensaje = "Formato no permitido. Imagenes: png, jpg, jpeg, webp, gif. " +
                              "Videos: mp4, mov, webm, m4v."
                });

            var tamanoMaximo = esVideo ? TamanoMaximoVideo : TamanoMaximoImagen;
            if (archivo.Length > tamanoMaximo)
                return BadRequest(new
                {
                    mensaje = esVideo
                        ? "El video supera el tamano maximo de 100 MB."
                        : "La imagen supera el tamano maximo de 8 MB."
                });

            var subcarpeta = DateTime.Now.ToString("yyyyMM");
            var raizWeb = _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot");
            var carpeta = Path.Combine(raizWeb, "imagenes", subcarpeta);
            Directory.CreateDirectory(carpeta);

            var nombre = $"{Guid.NewGuid():N}{extension}";
            var rutaFisica = Path.Combine(carpeta, nombre);

            await using (var stream = System.IO.File.Create(rutaFisica))
                await archivo.CopyToAsync(stream);

            var rutaRelativa = $"/api/Imagenes/archivo/{subcarpeta}/{nombre}";
            var urlAbsoluta = $"{Request.Scheme}://{Request.Host}{rutaRelativa}";

            _logger.LogInformation("Archivo subido: {Url} ({Tamano} bytes)", urlAbsoluta, archivo.Length);

            return Ok(new SubirImagenResponse
            {
                Url = urlAbsoluta,
                Ruta = rutaRelativa,
                Tipo = esVideo ? "video" : "imagen"
            });
        }






        [HttpGet("archivo/{subcarpeta}/{nombre}")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(FileResult), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public IActionResult Obtener(string subcarpeta, string nombre)
        {
            if (subcarpeta.Length != 6 || !subcarpeta.All(char.IsDigit))
                return NotFound();

            var extension = Path.GetExtension(nombre).ToLowerInvariant();
            if (!FormatosImagen.Contains(extension) && !FormatosVideo.Contains(extension))
                return NotFound();

            var raizWeb = _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot");
            var ruta = Path.Combine(raizWeb, "imagenes", subcarpeta, Path.GetFileName(nombre));
            if (!System.IO.File.Exists(ruta))
                return NotFound();

            return PhysicalFile(ruta, ObtenerContentType(extension));
        }

        private static string ObtenerContentType(string extension)
        {
            return extension switch
            {
                ".png" => "image/png",
                ".jpg" or ".jpeg" => "image/jpeg",
                ".webp" => "image/webp",
                ".gif" => "image/gif",
                ".mp4" or ".m4v" => "video/mp4",
                ".mov" => "video/quicktime",
                ".webm" => "video/webm",
                _ => "application/octet-stream",
            };
        }
    }

    public class SubirImagenResponse
    {
        public string Url { get; set; } = "";
        public string Ruta { get; set; } = "";

        public string Tipo { get; set; } = "imagen";
    }


    public class SubirImagenRequest
    {
        public IFormFile? Archivo { get; set; }
    }
}