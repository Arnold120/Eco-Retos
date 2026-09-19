using System.Security.Cryptography;

namespace WebApi.Implementacion.Helpers
{
    public static class PasswordHasher
    {
        private const int SaltSize = 16;
        private const int HashSize = 32;
        private const int Iterations = 10000;

        public static byte[] GenerateSalt()
        {
            return RandomNumberGenerator.GetBytes(SaltSize);
        }

        public static string HashPassword(string password, byte[] salt)
        {
            using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations, HashAlgorithmName.SHA256);
            var hashBytes = pbkdf2.GetBytes(HashSize);
            return Convert.ToBase64String(hashBytes);
        }

        public static bool VerifyPassword(string password, byte[] salt, string storedHash)
        {
            if (salt is null || salt.Length == 0 || string.IsNullOrEmpty(storedHash))
                return false;

            string computedHash;
            try
            {
                computedHash = HashPassword(password, salt);
            }
            catch
            {
                return false;
            }

            try
            {
                var a = Convert.FromBase64String(computedHash);
                var b = Convert.FromBase64String(storedHash);
                return a.Length == b.Length && CryptographicOperations.FixedTimeEquals(a, b);
            }
            catch
            {
                return false;
            }
        }
    }
}
