using Microsoft.AspNetCore.Mvc;
using FuelMateBackend.Services;
using FuelMateBackend.DTOs;

namespace FuelMateBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Tags("chat")]
public class ChatController : ControllerBase
{
    private readonly ChatService _chatService;
    private readonly UsersService _usersService;

    public ChatController(ChatService chatService, UsersService usersService)
    {
        _chatService = chatService;
        _usersService = usersService;
    }

    /// <summary>
    /// Send a chat message
    /// </summary>
    [HttpPost("send")]
    public async Task<IActionResult> SendMessage([FromBody] SendMessageDto dto)
    {
        try
        {
            Console.WriteLine($"💬 Chat send request received: requestId={dto.RequestId}, senderId={dto.SenderId}, messageLength={dto.Message?.Length}");

            if (string.IsNullOrEmpty(dto.SenderId))
            {
                Console.WriteLine("❌ senderId is missing from request body");
                return BadRequest("senderId is required");
            }

            if (string.IsNullOrEmpty(dto.RequestId))
            {
                Console.WriteLine("❌ requestId is missing from request body");
                return BadRequest("requestId is required");
            }

            if (string.IsNullOrEmpty(dto.Message))
            {
                Console.WriteLine("❌ message is missing from request body");
                return BadRequest("message is required");
            }

            var sender = await _usersService.GetUserById(dto.SenderId);
            if (sender == null)
            {
                Console.WriteLine($"❌ User not found: {dto.SenderId}");
                return NotFound($"User not found: {dto.SenderId}");
            }

            Console.WriteLine($"✅ Sender found: id={sender.Id}, name={sender.Name}, role={sender.Role}");

            var message = await _chatService.SendMessage(
                dto.RequestId,
                dto.SenderId,
                sender.Name,
                sender.Role,
                dto.Message);

            return Ok(new
            {
                message.Id,
                message.RequestId,
                message.SenderId,
                message.SenderName,
                message.SenderRole,
                message.Message,
                message.CreatedAt,
                successMessage = "Message sent successfully"
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error in sendMessage: {ex.Message}");
            return StatusCode(500, ex.Message);
        }
    }

    /// <summary>
    /// Get all messages for a request
    /// </summary>
    [HttpGet("messages/{requestId}")]
    public async Task<IActionResult> GetMessages(string requestId, [FromQuery] string? userId)
    {
        try
        {
            if (string.IsNullOrEmpty(userId))
            {
                return BadRequest("userId query parameter is required");
            }

            var messages = await _chatService.GetMessages(requestId, userId);

            return Ok(new
            {
                messages,
                count = messages.Count
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error in getMessages: {ex.Message}");
            return StatusCode(500, ex.Message);
        }
    }

    /// <summary>
    /// Get chat participants
    /// </summary>
    [HttpGet("participants/{requestId}")]
    public async Task<IActionResult> GetParticipants(string requestId)
    {
        try
        {
            var participants = await _chatService.GetChatParticipants(requestId);
            if (participants == null)
            {
                return NotFound($"Request not found: {requestId}");
            }

            var needy = await _usersService.GetUserById(participants.Value.needyId);
            var provider = participants.Value.providerId != null
                ? await _usersService.GetUserById(participants.Value.providerId)
                : null;

            return Ok(new
            {
                needyId = participants.Value.needyId,
                needyName = needy?.Name ?? "Unknown",
                providerId = participants.Value.providerId,
                providerName = provider?.Name
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error in getParticipants: {ex.Message}");
            return StatusCode(500, ex.Message);
        }
    }

    /// <summary>
    /// Get unread message counts for a user
    /// </summary>
    [HttpGet("unread-counts/{userId}")]
    public IActionResult GetUnreadCounts(string userId)
    {
        try
        {
            var unreadCounts = _chatService.GetUnreadCountsForUser(userId);
            var totalUnread = unreadCounts.Values.Sum();

            return Ok(new
            {
                success = true,
                unreadCounts,
                totalUnread
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error in getUnreadCounts: {ex.Message}");
            return StatusCode(500, ex.Message);
        }
    }

    /// <summary>
    /// Mark messages as read
    /// </summary>
    [HttpPost("mark-read/{requestId}")]
    public IActionResult MarkAsRead(string requestId, [FromBody] MarkReadDto dto)
    {
        try
        {
            if (string.IsNullOrEmpty(dto.UserId))
            {
                return BadRequest("userId is required");
            }

            _chatService.MarkAsRead(requestId, dto.UserId);

            return Ok(new
            {
                success = true,
                message = "Messages marked as read"
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error in markAsRead: {ex.Message}");
            return StatusCode(500, ex.Message);
        }
    }
}

