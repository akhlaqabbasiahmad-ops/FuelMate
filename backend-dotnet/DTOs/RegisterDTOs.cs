using System.ComponentModel.DataAnnotations;

namespace FuelMateBackend.DTOs;

public class RegisterDto
{
    [Required]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    public string Role { get; set; } = string.Empty; // "needy" or "provider"
    
    [Required]
    [MinLength(6)]
    public string Password { get; set; } = string.Empty;
}

public class LoginDto
{
    [Required]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    public string Role { get; set; } = string.Empty; // "needy" or "provider"
    
    [Required]
    public string Password { get; set; } = string.Empty;
}

public class RegisterResponse
{
    public bool Success { get; set; }
    public UserDto? User { get; set; }
    public bool IsNewUser { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class LoginResponse
{
    public bool Success { get; set; }
    public UserDto? User { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class UserDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public DateTime? CreatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }
}

