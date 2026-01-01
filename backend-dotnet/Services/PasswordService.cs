using System.Security.Cryptography;
using System.Text;

namespace FuelMateBackend.Services;

/// <summary>
/// Service for password hashing and verification
/// </summary>
public class PasswordService
{
    /// <summary>
    /// Hash a password using SHA256
    /// </summary>
    /// <param name="password">Plain text password</param>
    /// <returns>Base64 encoded hash</returns>
    public string HashPassword(string password)
    {
        if (string.IsNullOrEmpty(password))
        {
            throw new ArgumentException("Password cannot be empty", nameof(password));
        }

        using var sha256 = SHA256.Create();
        var bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
        return Convert.ToBase64String(bytes);
    }

    /// <summary>
    /// Verify a password against a hash
    /// </summary>
    /// <param name="password">Plain text password</param>
    /// <param name="hash">Stored hash</param>
    /// <returns>True if password matches</returns>
    public bool VerifyPassword(string password, string hash)
    {
        if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(hash))
        {
            return false;
        }

        var passwordHash = HashPassword(password);
        return passwordHash == hash;
    }

    /// <summary>
    /// Validate password strength
    /// </summary>
    /// <param name="password">Password to validate</param>
    /// <returns>True if password meets requirements</returns>
    public bool IsPasswordValid(string password, out string? errorMessage)
    {
        errorMessage = null;

        if (string.IsNullOrEmpty(password))
        {
            errorMessage = "Password is required";
            return false;
        }

        if (password.Length < 6)
        {
            errorMessage = "Password must be at least 6 characters";
            return false;
        }

        if (!password.Any(char.IsLetter))
        {
            errorMessage = "Password must contain at least one letter";
            return false;
        }

        if (!password.Any(char.IsDigit))
        {
            errorMessage = "Password must contain at least one number";
            return false;
        }

        return true;
    }
}

