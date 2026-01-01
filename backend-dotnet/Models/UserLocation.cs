namespace FuelMateBackend.Models;

public class UserLocation
{
    public string UserId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty; // "needy" or "provider"
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public bool IsAvailable { get; set; }
    public double? Distance { get; set; } // Calculated distance in km
}

