using System.ComponentModel.DataAnnotations;

namespace FuelMateBackend.DTOs;

public class SendMessageDto
{
    [Required]
    public string RequestId { get; set; } = string.Empty;
    
    [Required]
    public string SenderId { get; set; } = string.Empty;
    
    [Required]
    public string Message { get; set; } = string.Empty;
}

public class MarkReadDto
{
    [Required]
    public string UserId { get; set; } = string.Empty;
}

