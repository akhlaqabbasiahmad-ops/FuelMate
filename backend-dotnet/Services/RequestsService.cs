using Dapper;
using FuelMateBackend.Data;
using FuelMateBackend.Models;

namespace FuelMateBackend.Services;

public class RequestsService
{
    private readonly DapperContext _context;
    private readonly LocationService _locationService;

    public RequestsService(DapperContext context, LocationService locationService)
    {
        _context = context;
        _locationService = locationService;
    }

    public async Task<PetrolRequest> CreateRequest(
        string userId,
        decimal latitude,
        decimal longitude,
        string message,
        decimal? quantityLiters,
        string urgency,
        string role)
    {
        using var connection = _context.CreateConnection();
        
        var requestId = $"req_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}_{Guid.NewGuid().ToString("N").Substring(0, 9)}";
        var now = DateTime.UtcNow;

        var request = new PetrolRequest
        {
            Id = requestId,
            NeedyId = userId,
            Role = role,
            Latitude = latitude,
            Longitude = longitude,
            Message = message,
            QuantityLiters = quantityLiters,
            Urgency = urgency,
            Status = "pending",
            CreatedAt = now,
            UpdatedAt = now
        };

        await connection.ExecuteAsync(
            @"INSERT INTO PetrolRequests (Id, NeedyId, NeedyName, Role, Latitude, Longitude, Message, QuantityLiters, Urgency, Status, CreatedAt, UpdatedAt)
              VALUES (@Id, @NeedyId, @NeedyName, @Role, @Latitude, @Longitude, @Message, @QuantityLiters, @Urgency, @Status, @CreatedAt, @UpdatedAt)",
            request);

        Console.WriteLine($"✅ Request created: {request.Id} by {role} {userId}");
        return request;
    }

    public async Task<List<PetrolRequest>> FindNearestRequests(
        decimal latitude,
        decimal longitude,
        double maxDistance,
        int limit,
        string userId,
        string? userRole)
    {
        using var connection = _context.CreateConnection();
        
        // Get all pending and accepted requests
        var allRequests = (await connection.QueryAsync<PetrolRequest>(
            "SELECT * FROM PetrolRequests WHERE Status IN ('pending', 'accepted', 'in_progress')"))
            .ToList();

        var nearbyRequests = new List<PetrolRequest>();

        foreach (var request in allRequests)
        {
            var distance = _locationService.CalculateDistance(
                latitude, longitude, 
                request.Latitude, request.Longitude);

            if (distance <= maxDistance)
            {
                // Filter based on user role
                if (userRole == "provider")
                {
                    // Providers see needy requests OR their own accepted requests
                    if (request.Role == "needy" && request.Status == "pending")
                    {
                        nearbyRequests.Add(request);
                    }
                    else if (request.AcceptedBy == userId)
                    {
                        nearbyRequests.Add(request);
                    }
                }
                else if (userRole == "needy")
                {
                    // Needers see provider requests OR their own requests
                    if (request.Role == "provider" && request.Status == "pending")
                    {
                        nearbyRequests.Add(request);
                    }
                    else if (request.NeedyId == userId)
                    {
                        nearbyRequests.Add(request);
                    }
                }
            }
        }

        return nearbyRequests
            .OrderBy(r => _locationService.CalculateDistance(latitude, longitude, r.Latitude, r.Longitude))
            .Take(limit)
            .ToList();
    }

    public async Task<PetrolRequest?> GetRequest(string requestId)
    {
        using var connection = _context.CreateConnection();
        return await connection.QueryFirstOrDefaultAsync<PetrolRequest>(
            "SELECT * FROM PetrolRequests WHERE Id = @Id",
            new { Id = requestId });
    }

    public async Task<List<PetrolRequest>> GetUserRequests(string userId)
    {
        using var connection = _context.CreateConnection();
        var requests = await connection.QueryAsync<PetrolRequest>(
            "SELECT * FROM PetrolRequests WHERE NeedyId = @UserId ORDER BY CreatedAt DESC",
            new { UserId = userId });
        return requests.ToList();
    }

    public async Task<PetrolRequest?> AcceptRequest(string requestId, string providerId)
    {
        using var connection = _context.CreateConnection();
        
        var request = await GetRequest(requestId);
        if (request == null) return null;

        await connection.ExecuteAsync(
            @"UPDATE PetrolRequests 
              SET Status = 'accepted', AcceptedBy = @ProviderId, UpdatedAt = @UpdatedAt 
              WHERE Id = @Id",
            new { Id = requestId, ProviderId = providerId, UpdatedAt = DateTime.UtcNow });

        request.Status = "accepted";
        request.AcceptedBy = providerId;
        request.UpdatedAt = DateTime.UtcNow;
        
        return request;
    }

    public async Task<PetrolRequest?> CancelRequest(string requestId, string userId)
    {
        using var connection = _context.CreateConnection();
        
        var request = await GetRequest(requestId);
        if (request == null) return null;

        await connection.ExecuteAsync(
            @"UPDATE PetrolRequests 
              SET Status = 'cancelled', UpdatedAt = @UpdatedAt 
              WHERE Id = @Id",
            new { Id = requestId, UpdatedAt = DateTime.UtcNow });

        request.Status = "cancelled";
        request.UpdatedAt = DateTime.UtcNow;
        
        return request;
    }

    public async Task<PetrolRequest?> CompleteRequest(string requestId, string userId, string userRole)
    {
        using var connection = _context.CreateConnection();
        
        var request = await GetRequest(requestId);
        if (request == null) 
            throw new Exception($"Request {requestId} not found");

        await connection.ExecuteAsync(
            @"UPDATE PetrolRequests 
              SET Status = 'completed', UpdatedAt = @UpdatedAt 
              WHERE Id = @Id",
            new { Id = requestId, UpdatedAt = DateTime.UtcNow });

        request.Status = "completed";
        request.UpdatedAt = DateTime.UtcNow;
        
        return request;
    }

    public async Task<List<PetrolRequest>> GetRequestHistory(string userId, string userRole)
    {
        using var connection = _context.CreateConnection();
        
        IEnumerable<PetrolRequest> history;
        
        if (userRole == "needy")
        {
            history = await connection.QueryAsync<PetrolRequest>(
                @"SELECT * FROM PetrolRequests 
                  WHERE NeedyId = @UserId AND Status IN ('completed', 'cancelled') 
                  ORDER BY UpdatedAt DESC",
                new { UserId = userId });
        }
        else // provider
        {
            history = await connection.QueryAsync<PetrolRequest>(
                @"SELECT * FROM PetrolRequests 
                  WHERE AcceptedBy = @UserId AND Status IN ('completed', 'cancelled') 
                  ORDER BY UpdatedAt DESC",
                new { UserId = userId });
        }
        
        return history.ToList();
    }

    public async Task<List<PetrolRequest>> GetActiveRequests(string userId, string userRole)
    {
        using var connection = _context.CreateConnection();
        
        IEnumerable<PetrolRequest> active;
        
        if (userRole == "needy")
        {
            active = await connection.QueryAsync<PetrolRequest>(
                @"SELECT * FROM PetrolRequests 
                  WHERE NeedyId = @UserId AND Status IN ('pending', 'accepted', 'in_progress') 
                  ORDER BY CreatedAt DESC",
                new { UserId = userId });
        }
        else // provider
        {
            active = await connection.QueryAsync<PetrolRequest>(
                @"SELECT * FROM PetrolRequests 
                  WHERE AcceptedBy = @UserId AND Status IN ('pending', 'accepted', 'in_progress') 
                  ORDER BY CreatedAt DESC",
                new { UserId = userId });
        }
        
        return active.ToList();
    }

    public List<UserLocation> FindNearestProviders(
        decimal latitude,
        decimal longitude,
        double maxDistance,
        int limit,
        string needyId)
    {
        return _locationService.FindNearestProviders(latitude, longitude, maxDistance, limit, needyId);
    }

    public List<UserLocation> FindNearestNeeders(
        decimal latitude,
        decimal longitude,
        double maxDistance,
        int limit,
        string providerId)
    {
        return _locationService.FindNearestNeedy(latitude, longitude, maxDistance, limit, providerId);
    }

    // Quote methods
    public async Task<Quote> CreateQuote(
        string requestId,
        string providerId,
        decimal price,
        string currency,
        int? estimatedDeliveryTime,
        string? message)
    {
        using var connection = _context.CreateConnection();
        
        var quoteId = $"quote_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}_{Guid.NewGuid().ToString("N").Substring(0, 9)}";
        var now = DateTime.UtcNow;

        var quote = new Quote
        {
            Id = quoteId,
            RequestId = requestId,
            ProviderId = providerId,
            Price = price,
            Currency = currency,
            EstimatedDeliveryTime = estimatedDeliveryTime,
            Message = message,
            Status = "pending",
            CreatedAt = now,
            UpdatedAt = now
        };

        await connection.ExecuteAsync(
            @"INSERT INTO Quotes (Id, RequestId, ProviderId, ProviderName, Price, Currency, EstimatedDeliveryTime, Message, Status, CreatedAt, UpdatedAt)
              VALUES (@Id, @RequestId, @ProviderId, @ProviderName, @Price, @Currency, @EstimatedDeliveryTime, @Message, @Status, @CreatedAt, @UpdatedAt)",
            quote);

        return quote;
    }

    public async Task<List<Quote>> GetQuotesForRequest(string requestId)
    {
        using var connection = _context.CreateConnection();
        var quotes = await connection.QueryAsync<Quote>(
            "SELECT * FROM Quotes WHERE RequestId = @RequestId ORDER BY CreatedAt DESC",
            new { RequestId = requestId });
        return quotes.ToList();
    }

    public async Task<List<Quote>> GetQuotesForNeedy(string needyId)
    {
        using var connection = _context.CreateConnection();
        var quotes = await connection.QueryAsync<Quote>(
            @"SELECT q.* FROM Quotes q
              INNER JOIN PetrolRequests r ON q.RequestId = r.Id
              WHERE r.NeedyId = @NeedyId
              ORDER BY q.CreatedAt DESC",
            new { NeedyId = needyId });
        return quotes.ToList();
    }

    public async Task<List<Quote>> GetQuotesForProvider(string providerId)
    {
        using var connection = _context.CreateConnection();
        var quotes = await connection.QueryAsync<Quote>(
            "SELECT * FROM Quotes WHERE ProviderId = @ProviderId ORDER BY CreatedAt DESC",
            new { ProviderId = providerId });
        return quotes.ToList();
    }

    public async Task<Quote?> GetQuote(string quoteId)
    {
        using var connection = _context.CreateConnection();
        return await connection.QueryFirstOrDefaultAsync<Quote>(
            "SELECT * FROM Quotes WHERE Id = @Id",
            new { Id = quoteId });
    }

    public async Task<Quote?> AcceptQuote(string quoteId, string needyId)
    {
        using var connection = _context.CreateConnection();
        
        var quote = await GetQuote(quoteId);
        if (quote == null)
            throw new Exception($"Quote {quoteId} not found");

        // Update quote status
        await connection.ExecuteAsync(
            @"UPDATE Quotes 
              SET Status = 'accepted', UpdatedAt = @UpdatedAt 
              WHERE Id = @Id",
            new { Id = quoteId, UpdatedAt = DateTime.UtcNow });

        // Update request status
        await connection.ExecuteAsync(
            @"UPDATE PetrolRequests 
              SET Status = 'accepted', AcceptedBy = @ProviderId, UpdatedAt = @UpdatedAt 
              WHERE Id = @RequestId",
            new { RequestId = quote.RequestId, ProviderId = quote.ProviderId, UpdatedAt = DateTime.UtcNow });

        quote.Status = "accepted";
        quote.UpdatedAt = DateTime.UtcNow;
        
        return quote;
    }

    public async Task<Quote?> RejectQuote(string quoteId, string needyId)
    {
        using var connection = _context.CreateConnection();
        
        var quote = await GetQuote(quoteId);
        if (quote == null) return null;

        await connection.ExecuteAsync(
            @"UPDATE Quotes 
              SET Status = 'rejected', UpdatedAt = @UpdatedAt 
              WHERE Id = @Id",
            new { Id = quoteId, UpdatedAt = DateTime.UtcNow });

        quote.Status = "rejected";
        quote.UpdatedAt = DateTime.UtcNow;
        
        return quote;
    }
}

