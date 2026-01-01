namespace FuelMateBackend.Models;

public class Quote
{
    public string Id { get; set; } = string.Empty;
    public string RequestId { get; set; } = string.Empty;
    public string ProviderId { get; set; } = string.Empty;
    public string? ProviderName { get; set; }
    public decimal Price { get; set; }
    public string Currency { get; set; } = "PKR";
    public int? EstimatedDeliveryTime { get; set; } // minutes
    public string? Message { get; set; }
    public string Status { get; set; } = "pending"; // "pending", "accepted", "rejected"
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

