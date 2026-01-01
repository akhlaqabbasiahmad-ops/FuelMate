using Microsoft.AspNetCore.Mvc;
using FuelMateBackend.Services;
using FuelMateBackend.DTOs;
using FuelMateBackend.Models;

namespace FuelMateBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Tags("requests")]
public class RequestsController : ControllerBase
{
    private readonly RequestsService _requestsService;
    private readonly LocationService _locationService;

    public RequestsController(RequestsService requestsService, LocationService locationService)
    {
        _requestsService = requestsService;
        _locationService = locationService;
    }

    /// <summary>
    /// Create a new fuel request
    /// </summary>
    [HttpPost("create")]
    public async Task<IActionResult> CreateRequest([FromBody] CreateRequestDto dto)
    {
        if (string.IsNullOrEmpty(dto.UserId))
        {
            return BadRequest(new
            {
                error = "User ID is required",
                message = "Please provide a valid user ID"
            });
        }

        var existingLocation = _locationService.GetLocation(dto.UserId);
        var actualUserRole = existingLocation?.Role ?? dto.UserRole ?? "needy";
        var requestRole = dto.UserRole ?? actualUserRole;

        Console.WriteLine($"📝 Creating request: userId={dto.UserId}, actualUserRole={actualUserRole}, requestRole={requestRole}, location=({dto.Latitude},{dto.Longitude})");

        var request = await _requestsService.CreateRequest(
            dto.UserId,
            dto.Latitude,
            dto.Longitude,
            dto.Message,
            dto.QuantityLiters,
            dto.Urgency,
            requestRole);

        Console.WriteLine($"✅ Request created: {request.Id} by {requestRole} {dto.UserId} (user's role: {actualUserRole})");

        return Ok(new
        {
            request.Id,
            request.NeedyId,
            request.Role,
            request.Latitude,
            request.Longitude,
            request.Message,
            request.QuantityLiters,
            request.Urgency,
            request.Status,
            request.CreatedAt,
            successMessage = $"Request created successfully. It will be visible to nearby {(requestRole == "needy" ? "providers" : "needers")}."
        });
    }

    /// <summary>
    /// Find nearest fuel requests
    /// </summary>
    [HttpGet("nearest")]
    public async Task<IActionResult> FindNearestRequests(
        [FromQuery] decimal latitude,
        [FromQuery] decimal longitude,
        [FromQuery] double maxDistance = 10,
        [FromQuery] int limit = 10,
        [FromQuery] string? providerId = null,
        [FromQuery] string? needyId = null,
        [FromQuery] string? userRole = null)
    {
        var userId = needyId ?? providerId;
        if (string.IsNullOrEmpty(userId))
        {
            return BadRequest(new
            {
                error = "User ID is required (providerId or needyId)",
                requests = new List<object>(),
                count = 0
            });
        }

        Console.WriteLine($"🔍 Searching for requests: userId={userId}, userRole={userRole}, location=({latitude},{longitude}), maxDistance={maxDistance}");

        // Register/update user location
        var existingLocation = _locationService.GetLocation(userId);
        var actualRole = existingLocation?.Role ?? userRole ?? (needyId != null ? "needy" : "provider");

        _locationService.UpdateLocation(userId, new UserLocation
        {
            UserId = userId,
            Name = existingLocation?.Name ?? (needyId != null ? "Needy User" : "Provider"),
            Role = actualRole,
            Latitude = latitude,
            Longitude = longitude,
            IsAvailable = true
        });

        var requests = await _requestsService.FindNearestRequests(
            latitude,
            longitude,
            maxDistance,
            limit,
            userId,
            actualRole);

        Console.WriteLine($"✅ Found {requests.Count} requests nearby");

        return Ok(new
        {
            requests,
            count = requests.Count,
            searchLocation = new { latitude, longitude }
        });
    }

    /// <summary>
    /// Find nearest providers
    /// </summary>
    [HttpGet("providers/nearest")]
    public IActionResult FindNearestProviders(
        [FromQuery] decimal latitude,
        [FromQuery] decimal longitude,
        [FromQuery] double maxDistance = 10,
        [FromQuery] int limit = 10,
        [FromQuery] string? needyId = null)
    {
        if (string.IsNullOrEmpty(needyId))
        {
            return BadRequest(new
            {
                error = "Needy ID is required",
                providers = new List<object>(),
                count = 0
            });
        }

        Console.WriteLine($"🔍 Real needy searching for providers: needyId={needyId}, location=({latitude},{longitude})");

        // Register/update needy location
        var existingLocation = _locationService.GetLocation(needyId);
        _locationService.UpdateLocation(needyId, new UserLocation
        {
            UserId = needyId,
            Name = existingLocation?.Name ?? "Needy User",
            Role = existingLocation?.Role ?? "needy",
            Latitude = latitude,
            Longitude = longitude,
            IsAvailable = true
        });

        var providers = _requestsService.FindNearestProviders(latitude, longitude, maxDistance, limit, needyId);

        Console.WriteLine($"✅ Found {providers.Count} providers nearby");

        return Ok(new
        {
            providers,
            count = providers.Count,
            searchLocation = new { latitude, longitude }
        });
    }

    /// <summary>
    /// Find nearest needers
    /// </summary>
    [HttpGet("needers/nearest")]
    public IActionResult FindNearestNeeders(
        [FromQuery] decimal latitude,
        [FromQuery] decimal longitude,
        [FromQuery] double maxDistance = 10,
        [FromQuery] int limit = 10,
        [FromQuery] string? providerId = null)
    {
        if (string.IsNullOrEmpty(providerId))
        {
            return BadRequest(new
            {
                error = "Provider ID is required",
                needers = new List<object>(),
                count = 0
            });
        }

        Console.WriteLine($"🔍 Real provider searching for needers: providerId={providerId}, location=({latitude},{longitude})");

        // Register/update provider location
        var existingLocation = _locationService.GetLocation(providerId);
        _locationService.UpdateLocation(providerId, new UserLocation
        {
            UserId = providerId,
            Name = existingLocation?.Name ?? "Provider",
            Role = existingLocation?.Role ?? "provider",
            Latitude = latitude,
            Longitude = longitude,
            IsAvailable = true
        });

        var needers = _requestsService.FindNearestNeeders(latitude, longitude, maxDistance, limit, providerId);

        Console.WriteLine($"✅ Found {needers.Count} needers nearby");

        return Ok(new
        {
            needers,
            count = needers.Count,
            searchLocation = new { latitude, longitude }
        });
    }

    /// <summary>
    /// Accept a fuel request
    /// </summary>
    [HttpPost("{id}/accept")]
    public async Task<IActionResult> AcceptRequest(string id, [FromBody] Dictionary<string, string> body)
    {
        if (!body.TryGetValue("providerId", out var providerId))
        {
            return BadRequest("Provider ID is required");
        }

        var request = await _requestsService.AcceptRequest(id, providerId);
        if (request == null)
        {
            return NotFound(new { error = "Request not found" });
        }

        return Ok(request);
    }

    /// <summary>
    /// Get request history (completed requests)
    /// </summary>
    [HttpGet("history")]
    public async Task<IActionResult> GetRequestHistory(
        [FromQuery] string? userId,
        [FromQuery] string? userRole)
    {
        Console.WriteLine($"\n\n📜 ========== HISTORY ENDPOINT CALLED ==========");
        Console.WriteLine($"📜 History endpoint called: userId={userId}, userRole={userRole}");

        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(userRole))
        {
            Console.WriteLine("❌ Missing userId or userRole");
            return BadRequest(new
            {
                error = "User ID and role are required",
                message = "Please provide userId and userRole",
                history = new List<object>(),
                count = 0
            });
        }

        try
        {
            Console.WriteLine("📜 Calling getRequestHistory service method...");
            var history = await _requestsService.GetRequestHistory(userId, userRole);
            Console.WriteLine($"📜 Service returned {history.Count} history items");

            return Ok(new
            {
                success = true,
                history,
                count = history.Count
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error getting history: {ex.Message}");
            return StatusCode(500, new
            {
                success = false,
                error = ex.Message,
                history = new List<object>(),
                count = 0
            });
        }
    }

    /// <summary>
    /// Get active requests (pending, accepted, in_progress)
    /// </summary>
    [HttpGet("active")]
    public async Task<IActionResult> GetActiveRequests(
        [FromQuery] string? userId,
        [FromQuery] string? userRole)
    {
        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(userRole))
        {
            return BadRequest(new
            {
                error = "User ID and role are required",
                message = "Please provide userId and userRole"
            });
        }

        var activeRequests = await _requestsService.GetActiveRequests(userId, userRole);

        return Ok(new
        {
            success = true,
            requests = activeRequests,
            count = activeRequests.Count
        });
    }

    /// <summary>
    /// Get a specific request by ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetRequest(string id)
    {
        var request = await _requestsService.GetRequest(id);
        if (request == null)
        {
            return NotFound(new { error = "Request not found" });
        }

        return Ok(request);
    }

    /// <summary>
    /// Get all requests for a user
    /// </summary>
    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetUserRequests(string userId)
    {
        var requests = await _requestsService.GetUserRequests(userId);
        return Ok(new { requests });
    }

    /// <summary>
    /// Cancel a request
    /// </summary>
    [HttpPost("{id}/cancel")]
    public async Task<IActionResult> CancelRequest(string id, [FromBody] Dictionary<string, string> body)
    {
        if (!body.TryGetValue("userId", out var userId))
        {
            return BadRequest("User ID is required");
        }

        var request = await _requestsService.CancelRequest(id, userId);
        if (request == null)
        {
            return NotFound(new { error = "Request not found" });
        }

        return Ok(request);
    }

    /// <summary>
    /// Complete a request
    /// </summary>
    [HttpPost("{id}/complete")]
    public async Task<IActionResult> CompleteRequest(string id, [FromBody] Dictionary<string, string> body)
    {
        body.TryGetValue("userId", out var userId);
        body.TryGetValue("providerId", out var providerId);
        body.TryGetValue("userRole", out var userRole);

        var finalUserId = userId ?? providerId;
        var finalUserRole = userRole ?? (providerId != null ? "provider" : "needy");

        if (string.IsNullOrEmpty(finalUserId))
        {
            return BadRequest(new
            {
                error = "User ID is required",
                message = "Please provide userId (or providerId for backward compatibility)"
            });
        }

        try
        {
            var request = await _requestsService.CompleteRequest(id, finalUserId, finalUserRole);
            
            if (request == null)
            {
                return NotFound(new { error = "Request not found" });
            }

            return Ok(new
            {
                success = true,
                request = new
                {
                    request.Id,
                    request.Status,
                    completedAt = request.UpdatedAt
                },
                message = "Request completed successfully. Moved to history."
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                error = ex.Message,
                message = ex.Message
            });
        }
    }

    // Quote endpoints

    /// <summary>
    /// Create a quote for a fuel request
    /// </summary>
    [HttpPost("quotes/create")]
    public async Task<IActionResult> CreateQuote([FromBody] CreateQuoteDto dto)
    {
        if (string.IsNullOrEmpty(dto.ProviderId))
        {
            return BadRequest(new
            {
                error = "Provider ID is required",
                message = "Please provide a valid provider ID"
            });
        }

        if (string.IsNullOrEmpty(dto.RequestId))
        {
            return BadRequest(new
            {
                error = "Request ID is required",
                message = "Please provide a valid request ID"
            });
        }

        Console.WriteLine($"💰 Creating quote: requestId={dto.RequestId}, providerId={dto.ProviderId}, price={dto.Price}");

        try
        {
            var quote = await _requestsService.CreateQuote(
                dto.RequestId,
                dto.ProviderId,
                dto.Price,
                dto.Currency,
                dto.EstimatedDeliveryTime,
                dto.Message);

            Console.WriteLine($"✅ Quote created successfully: {quote.Id}");

            return Ok(new
            {
                quote.Id,
                quote.RequestId,
                quote.ProviderId,
                quote.Price,
                quote.Currency,
                quote.EstimatedDeliveryTime,
                quote.Message,
                quote.Status,
                quote.CreatedAt,
                quote.UpdatedAt,
                successMessage = "Quote sent successfully to needy user"
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error creating quote: {ex.Message}");
            return BadRequest(new
            {
                error = ex.Message,
                message = ex.Message
            });
        }
    }

    /// <summary>
    /// Get quotes for a request
    /// </summary>
    [HttpGet("quotes/request/{requestId}")]
    public async Task<IActionResult> GetQuotesForRequest(string requestId)
    {
        var quotes = await _requestsService.GetQuotesForRequest(requestId);
        return Ok(new
        {
            quotes,
            count = quotes.Count
        });
    }

    /// <summary>
    /// Get quotes for a needy user
    /// </summary>
    [HttpGet("quotes/needy/{needyId}")]
    public async Task<IActionResult> GetQuotesForNeedy(string needyId)
    {
        var quotes = await _requestsService.GetQuotesForNeedy(needyId);
        return Ok(new
        {
            quotes,
            count = quotes.Count
        });
    }

    /// <summary>
    /// Get quotes for a provider
    /// </summary>
    [HttpGet("quotes/provider/{providerId}")]
    public async Task<IActionResult> GetQuotesForProvider(string providerId)
    {
        var quotes = await _requestsService.GetQuotesForProvider(providerId);
        return Ok(new
        {
            quotes,
            count = quotes.Count
        });
    }

    /// <summary>
    /// Accept a quote
    /// </summary>
    [HttpPost("quotes/{quoteId}/accept")]
    public async Task<IActionResult> AcceptQuote(string quoteId, [FromBody] AcceptQuoteDto dto)
    {
        try
        {
            Console.WriteLine($"✅ Accepting quote: quoteId={quoteId}, needyId={dto.NeedyId}");

            if (string.IsNullOrWhiteSpace(dto.NeedyId))
            {
                Console.WriteLine("❌ Needy ID is missing or empty");
                return BadRequest("Needy ID is required");
            }

            var quote = await _requestsService.AcceptQuote(quoteId, dto.NeedyId);
            
            if (quote == null)
            {
                return NotFound(new { error = "Quote not found" });
            }
            
            Console.WriteLine($"✅ Quote accepted successfully: {quote.Id}");

            var request = await _requestsService.GetRequest(quote.RequestId);
            if (request == null)
            {
                Console.WriteLine($"❌ Request {quote.RequestId} not found after accepting quote");
                return Ok(new
                {
                    quote.Id,
                    quote.Status,
                    request = (object?)null,
                    warning = "Request not found",
                    message = "Quote accepted successfully, but request details could not be retrieved."
                });
            }

            Console.WriteLine($"✅ Request retrieved: id={request.Id}, status={request.Status}");

            return Ok(new
            {
                quote.Id,
                quote.Status,
                quote.RequestId,
                request = new
                {
                    request.Id,
                    request.Status,
                    request.NeedyId,
                    request.AcceptedBy
                },
                message = "Quote accepted successfully. Request is now hidden from other providers."
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error accepting quote: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }

    /// <summary>
    /// Reject a quote
    /// </summary>
    [HttpPost("quotes/{quoteId}/reject")]
    public async Task<IActionResult> RejectQuote(string quoteId, [FromBody] Dictionary<string, string> body)
    {
        if (!body.TryGetValue("needyId", out var needyId))
        {
            return BadRequest("Needy ID is required");
        }

        var quote = await _requestsService.RejectQuote(quoteId, needyId);
        if (quote == null)
        {
            return NotFound(new { error = "Quote not found" });
        }

        return Ok(new
        {
            quote.Id,
            quote.Status,
            message = "Quote rejected"
        });
    }

    /// <summary>
    /// Get a specific quote
    /// </summary>
    [HttpGet("quotes/{quoteId}")]
    public async Task<IActionResult> GetQuote(string quoteId)
    {
        var quote = await _requestsService.GetQuote(quoteId);
        if (quote == null)
        {
            return NotFound(new { error = "Quote not found" });
        }

        return Ok(quote);
    }
}

