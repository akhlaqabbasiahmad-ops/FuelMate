using Dapper;
using FuelMateBackend.Data;
using FuelMateBackend.Models;

namespace FuelMateBackend.Services;

public class ChatService
{
    private readonly DapperContext _context;
    private readonly Dictionary<string, Dictionary<string, int>> _unreadCounts = new(); // requestId -> userId -> count

    public ChatService(DapperContext context)
    {
        _context = context;
    }

    public async Task<ChatMessage> SendMessage(
        string requestId,
        string senderId,
        string senderName,
        string senderRole,
        string message)
    {
        using var connection = _context.CreateConnection();
        
        var messageId = $"msg_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}_{Guid.NewGuid().ToString("N").Substring(0, 9)}";
        var now = DateTime.UtcNow;

        var chatMessage = new ChatMessage
        {
            Id = messageId,
            RequestId = requestId,
            SenderId = senderId,
            SenderName = senderName,
            SenderRole = senderRole,
            Message = message,
            CreatedAt = now
        };

        await connection.ExecuteAsync(
            @"INSERT INTO ChatMessages (Id, RequestId, SenderId, SenderName, SenderRole, Message, CreatedAt)
              VALUES (@Id, @RequestId, @SenderId, @SenderName, @SenderRole, @Message, @CreatedAt)",
            chatMessage);

        // Update unread counts
        UpdateUnreadCount(requestId, senderId);

        Console.WriteLine($"💬 Message sent: {senderName} ({senderRole}) in request {requestId}");
        return chatMessage;
    }

    public async Task<List<ChatMessage>> GetMessages(string requestId, string userId)
    {
        using var connection = _context.CreateConnection();
        
        var messages = await connection.QueryAsync<ChatMessage>(
            "SELECT * FROM ChatMessages WHERE RequestId = @RequestId ORDER BY CreatedAt ASC",
            new { RequestId = requestId });

        return messages.ToList();
    }

    public async Task<(string needyId, string? providerId)?> GetChatParticipants(string requestId)
    {
        using var connection = _context.CreateConnection();
        
        var request = await connection.QueryFirstOrDefaultAsync<PetrolRequest>(
            "SELECT * FROM PetrolRequests WHERE Id = @Id",
            new { Id = requestId });

        if (request == null) return null;

        return (request.NeedyId, request.AcceptedBy);
    }

    public Dictionary<string, int> GetUnreadCountsForUser(string userId)
    {
        var counts = new Dictionary<string, int>();
        
        foreach (var (requestId, userCounts) in _unreadCounts)
        {
            if (userCounts.TryGetValue(userId, out var count) && count > 0)
            {
                counts[requestId] = count;
            }
        }
        
        return counts;
    }

    public void MarkAsRead(string requestId, string userId)
    {
        if (_unreadCounts.TryGetValue(requestId, out var userCounts))
        {
            userCounts[userId] = 0;
        }
    }

    private void UpdateUnreadCount(string requestId, string senderId)
    {
        if (!_unreadCounts.ContainsKey(requestId))
        {
            _unreadCounts[requestId] = new Dictionary<string, int>();
        }

        // Increment unread count for all participants except sender
        // This is simplified - in production, get actual participants from request
        foreach (var userId in _unreadCounts[requestId].Keys.ToList())
        {
            if (userId != senderId)
            {
                _unreadCounts[requestId][userId]++;
            }
        }
    }
}

