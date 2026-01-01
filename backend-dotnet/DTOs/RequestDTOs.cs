using System.ComponentModel.DataAnnotations;

namespace FuelMateBackend.DTOs;

public class CreateRequestDto
{
    [Required]
    public string UserId { get; set; } = string.Empty;
    
    [Required]
    public decimal Latitude { get; set; }
    
    [Required]
    public decimal Longitude { get; set; }
    
    [Required]
    public string Message { get; set; } = string.Empty;
    
    public decimal? QuantityLiters { get; set; }
    
    public string Urgency { get; set; } = "normal";
    
    public string? UserRole { get; set; }
}

public class CreateQuoteDto
{
    [Required]
    public string RequestId { get; set; } = string.Empty;
    
    [Required]
    public string ProviderId { get; set; } = string.Empty;
    
    [Required]
    public decimal Price { get; set; }
    
    public string Currency { get; set; } = "PKR";
    
    public int? EstimatedDeliveryTime { get; set; }
    
    public string? Message { get; set; }
}

public class AcceptQuoteDto
{
    [Required]
    public string NeedyId { get; set; } = string.Empty;
}

