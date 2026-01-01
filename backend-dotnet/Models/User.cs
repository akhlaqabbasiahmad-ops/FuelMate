namespace FuelMateBackend.Models;

public class User
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty; // "needy" or "provider"
    public DateTime CreatedAt { get; set; }
    public DateTime LastLoginAt { get; set; }
}

