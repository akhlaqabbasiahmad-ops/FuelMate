namespace FuelMateBackend.Models;

public class ChatMessage
{
    public string Id { get; set; } = string.Empty;
    public string RequestId { get; set; } = string.Empty;
    public string SenderId { get; set; } = string.Empty;
    public string SenderName { get; set; } = string.Empty;
    public string SenderRole { get; set; } = string.Empty; // "needy" or "provider"
    public string Message { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

