namespace FuelMateBackend.Models;

public class PetrolRequest
{
    public string Id { get; set; } = string.Empty;
    public string NeedyId { get; set; } = string.Empty;
    public string? NeedyName { get; set; }
    public string Role { get; set; } = string.Empty; // "needy" or "provider"
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public string Message { get; set; } = string.Empty;
    public decimal? QuantityLiters { get; set; }
    public string Urgency { get; set; } = "normal"; // "normal" or "urgent"
    public string Status { get; set; } = "pending"; // "pending", "accepted", "in_progress", "completed", "cancelled"
    public string? AcceptedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

