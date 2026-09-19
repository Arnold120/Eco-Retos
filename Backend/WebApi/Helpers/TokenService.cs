using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace WebApi.Helpers
{
    public interface ITokenService
    {
        (string Token, DateTime ExpiraEn) GenerarToken(int usuarioId, string nombreUsuario, string correo, IEnumerable<string> roles);
    }

    public class TokenService : ITokenService
    {
        private readonly IConfiguration _configuration;

        public TokenService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public (string Token, DateTime ExpiraEn) GenerarToken(int usuarioId, string nombreUsuario, string correo, IEnumerable<string> roles)
        {
            var key = _configuration["Jwt:Key"]
                ?? throw new InvalidOperationException("Jwt:Key no configurado.");
            var issuer = _configuration["Jwt:Issuer"] ?? "EcoRetos";
            var audience = _configuration["Jwt:Audience"] ?? "EcoRetosApp";
            var minutos = Convert.ToInt32(_configuration["Jwt:ExpirationInMinutes"] ?? "1440");

            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, usuarioId.ToString()),
                new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new(ClaimTypes.NameIdentifier, usuarioId.ToString()),
                new(ClaimTypes.Name, nombreUsuario),
                new(ClaimTypes.Email, correo)
            };

            foreach (var rol in roles)
                claims.Add(new Claim(ClaimTypes.Role, rol));

            var signingCredentials = new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
                SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(minutos),
                signingCredentials: signingCredentials);

            var expiracion = DateTime.UtcNow.AddMinutes(minutos);
            return (new JwtSecurityTokenHandler().WriteToken(token), expiracion);
        }
    }
}