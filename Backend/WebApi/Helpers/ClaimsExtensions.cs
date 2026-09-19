using System.Security.Claims;

namespace WebApi.Helpers
{




    public static class ClaimsExtensions
    {
        public static int? ObtenerUsuarioId(this ClaimsPrincipal? user)
        {
            if (user is null) return null;
            var valor = user.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? user.FindFirstValue(ClaimTypes.Name)
                ?? user.FindFirstValue("sub");
            return int.TryParse(valor, out var id) && id > 0 ? id : null;
        }
    }
}
