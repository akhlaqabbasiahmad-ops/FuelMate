using System.ComponentModel.DataAnnotations;

namespace FuelMateBackend.DTOs;

public class CheckNameDto
{
    [Required]
    public string Name { get; set; } = string.Empty;
}

public class CheckNameResponse
{
    public string RequestedName { get; set; } = string.Empty;
    public bool IsAvailable { get; set; }
    public string SuggestedName { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}

