using FuelMateBackend.Models;

namespace FuelMateBackend.Services;

public class LocationService
{
    private readonly Dictionary<string, UserLocation> _userLocations = new();

    public double CalculateDistance(decimal lat1, decimal lon1, decimal lat2, decimal lon2)
    {
        // Haversine formula
        const double R = 6371; // Earth's radius in kilometers
        var dLat = ToRadians((double)(lat2 - lat1));
        var dLon = ToRadians((double)(lon2 - lon1));

        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(ToRadians((double)lat1)) * Math.Cos(ToRadians((double)lat2)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return R * c; // Distance in kilometers
    }

    private static double ToRadians(double degrees)
    {
        return degrees * Math.PI / 180;
    }

    public List<UserLocation> FindNearestProviders(
        decimal needyLat, 
        decimal needyLon, 
        double maxDistanceKm = 10, 
        int limit = 5,
        string? excludeNeedyId = null)
    {
        var providers = _userLocations.Values
            .Where(l => l.Role == "provider" && 
                       l.IsAvailable && 
                       (excludeNeedyId == null || l.UserId != excludeNeedyId))
            .Select(location => {
                var distance = CalculateDistance(needyLat, needyLon, location.Latitude, location.Longitude);
                return new UserLocation
                {
                    UserId = location.UserId,
                    Name = location.Name,
                    Role = location.Role,
                    Latitude = location.Latitude,
                    Longitude = location.Longitude,
                    IsAvailable = location.IsAvailable,
                    Distance = distance
                };
            })
            .Where(p => p.Distance <= maxDistanceKm)
            .OrderBy(p => p.Distance)
            .Take(limit)
            .ToList();

        return providers;
    }

    public List<UserLocation> FindNearestNeedy(
        decimal providerLat, 
        decimal providerLon, 
        double maxDistanceKm = 10, 
        int limit = 5,
        string? excludeProviderId = null)
    {
        var needyUsers = _userLocations.Values
            .Where(l => l.Role == "needy" && 
                       l.IsAvailable && 
                       (excludeProviderId == null || l.UserId != excludeProviderId))
            .Select(location => {
                var distance = CalculateDistance(providerLat, providerLon, location.Latitude, location.Longitude);
                return new UserLocation
                {
                    UserId = location.UserId,
                    Name = location.Name,
                    Role = location.Role,
                    Latitude = location.Latitude,
                    Longitude = location.Longitude,
                    IsAvailable = location.IsAvailable,
                    Distance = distance
                };
            })
            .Where(n => n.Distance <= maxDistanceKm)
            .OrderBy(n => n.Distance)
            .Take(limit)
            .ToList();

        if (needyUsers.Count == 0)
        {
            Console.WriteLine("⚠️ No active needers found in system");
        }

        return needyUsers;
    }

    public void UpdateLocation(string userId, UserLocation location)
    {
        var existingLocation = GetLocation(userId);
        
        if (existingLocation == null)
        {
            Console.WriteLine($"📍 New user registered: {location.Role} {location.Name} ({userId})");
        }
        else if (existingLocation.Role != location.Role || existingLocation.IsAvailable != location.IsAvailable)
        {
            Console.WriteLine($"📍 User {location.Name} ({userId}) changed: role={existingLocation.Role}→{location.Role}, available={existingLocation.IsAvailable}→{location.IsAvailable}");
        }

        _userLocations[userId] = new UserLocation
        {
            UserId = userId,
            Name = location.Name,
            Role = location.Role,
            Latitude = location.Latitude,
            Longitude = location.Longitude,
            IsAvailable = location.IsAvailable
        };
    }

    public UserLocation? GetLocation(string userId)
    {
        return _userLocations.TryGetValue(userId, out var location) ? location : null;
    }
}

