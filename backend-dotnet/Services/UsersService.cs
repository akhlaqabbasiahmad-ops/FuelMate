using Dapper;
using FuelMateBackend.Data;
using FuelMateBackend.Models;

namespace FuelMateBackend.Services;

public class UsersService
{
    private readonly DapperContext _context;
    private readonly PasswordService _passwordService;

    public UsersService(DapperContext context, PasswordService passwordService)
    {
        _context = context;
        _passwordService = passwordService;
    }

    public async Task<bool> IsNameAvailable(string name)
    {
        var normalizedName = NormalizeName(name);
        using var connection = _context.CreateConnection();
        
        var existing = await connection.QueryFirstOrDefaultAsync<User>(
            "SELECT * FROM Users WHERE Name = @Name",
            new { Name = normalizedName });
        
        return existing == null;
    }

    public async Task<string> SuggestName(string baseName)
    {
        var normalizedBase = NormalizeName(baseName);
        
        if (await IsNameAvailable(normalizedBase))
        {
            return normalizedBase;
        }

        using var connection = _context.CreateConnection();
        var counter = 2;
        
        while (true)
        {
            var suggestedName = $"{normalizedBase} {counter}";
            var exists = await connection.QueryFirstOrDefaultAsync<User>(
                "SELECT * FROM Users WHERE Name = @Name",
                new { Name = suggestedName });
            
            if (exists == null)
            {
                return suggestedName;
            }
            
            counter++;
        }
    }

    public async Task<(User user, bool isNewUser)> RegisterOrLogin(string name, string role)
    {
        var normalizedName = NormalizeName(name);
        using var connection = _context.CreateConnection();
        
        var existingUser = await connection.QueryFirstOrDefaultAsync<User>(
            "SELECT * FROM Users WHERE Name = @Name",
            new { Name = normalizedName });
        
        if (existingUser != null)
        {
            // Update last login
            await connection.ExecuteAsync(
                "UPDATE Users SET LastLoginAt = @LastLoginAt WHERE Id = @Id",
                new { Id = existingUser.Id, LastLoginAt = DateTime.UtcNow });
            
            existingUser.LastLoginAt = DateTime.UtcNow;
            Console.WriteLine($"✅ User logged in: {existingUser.Name} ({existingUser.Id})");
            return (existingUser, false);
        }

        // Create new user
        var suggestedName = await SuggestName(normalizedName);
        var userId = GenerateUserId(role);
        var now = DateTime.UtcNow;
        
        var newUser = new User
        {
            Id = userId,
            Name = suggestedName,
            Role = role,
            CreatedAt = now,
            LastLoginAt = now
        };

        await connection.ExecuteAsync(
            @"INSERT INTO Users (Id, Name, Role, CreatedAt, LastLoginAt) 
              VALUES (@Id, @Name, @Role, @CreatedAt, @LastLoginAt)",
            newUser);

        Console.WriteLine($"✅ New user registered: {newUser.Name} ({newUser.Id})");
        return (newUser, true);
    }

    public async Task<User?> GetUserById(string userId)
    {
        using var connection = _context.CreateConnection();
        return await connection.QueryFirstOrDefaultAsync<User>(
            "SELECT * FROM Users WHERE Id = @Id",
            new { Id = userId });
    }

    public async Task<User?> GetUserByName(string name)
    {
        var normalizedName = NormalizeName(name);
        using var connection = _context.CreateConnection();
        return await connection.QueryFirstOrDefaultAsync<User>(
            "SELECT * FROM Users WHERE Name = @Name",
            new { Name = normalizedName });
    }

    public async Task<List<User>> GetAllUsers()
    {
        using var connection = _context.CreateConnection();
        var users = await connection.QueryAsync<User>(
            "SELECT * FROM Users ORDER BY CreatedAt DESC");
        return users.ToList();
    }

    private static string NormalizeName(string name)
    {
        return name.Trim().ToLowerInvariant();
    }

    /// <summary>
    /// Register a new user with password
    /// </summary>
    public async Task<User> RegisterWithPassword(string name, string password, string role)
    {
        var normalizedName = NormalizeName(name);
        
        // Validate password
        if (!_passwordService.IsPasswordValid(password, out var errorMessage))
        {
            throw new ArgumentException(errorMessage);
        }

        using var connection = _context.CreateConnection();
        
        // Check if user already exists
        var existingUser = await connection.QueryFirstOrDefaultAsync<User>(
            "SELECT * FROM Users WHERE Name = @Name",
            new { Name = normalizedName });
        
        if (existingUser != null)
        {
            throw new InvalidOperationException($"User with name '{normalizedName}' already exists");
        }

        // Hash password
        var passwordHash = _passwordService.HashPassword(password);

        // Create new user
        var userId = GenerateUserId(role);
        var now = DateTime.UtcNow;
        
        var newUser = new User
        {
            Id = userId,
            Name = normalizedName,
            Role = role,
            PasswordHash = passwordHash,
            CreatedAt = now,
            LastLoginAt = now
        };

        await connection.ExecuteAsync(
            @"INSERT INTO Users (Id, Name, Role, PasswordHash, CreatedAt, LastLoginAt)
              VALUES (@Id, @Name, @Role, @PasswordHash, @CreatedAt, @LastLoginAt)",
            newUser);

        Console.WriteLine($"✅ New user registered: {newUser.Name} ({newUser.Id})");
        return newUser;
    }

    /// <summary>
    /// Login user with password
    /// </summary>
    public async Task<User?> LoginWithPassword(string name, string password, string role)
    {
        var normalizedName = NormalizeName(name);
        using var connection = _context.CreateConnection();
        
        var user = await connection.QueryFirstOrDefaultAsync<User>(
            "SELECT * FROM Users WHERE Name = @Name AND Role = @Role",
            new { Name = normalizedName, Role = role });
        
        if (user == null)
        {
            Console.WriteLine($"❌ User not found: {normalizedName} ({role})");
            return null;
        }

        // Check if user has empty password (old user)
        if (string.IsNullOrEmpty(user.PasswordHash))
        {
            Console.WriteLine($"⚠️ User {user.Name} has no password set - needs to set password");
            throw new InvalidOperationException("PASSWORD_NOT_SET");
        }

        // Verify password
        if (!_passwordService.VerifyPassword(password, user.PasswordHash))
        {
            Console.WriteLine($"❌ Invalid password for user: {normalizedName}");
            return null;
        }

        // Update last login
        await connection.ExecuteAsync(
            "UPDATE Users SET LastLoginAt = @LastLoginAt WHERE Id = @Id",
            new { Id = user.Id, LastLoginAt = DateTime.UtcNow });
        
        user.LastLoginAt = DateTime.UtcNow;
        Console.WriteLine($"✅ User logged in: {user.Name} ({user.Id})");
        return user;
    }

    /// <summary>
    /// Check if user exists (for checking before login/register)
    /// </summary>
    public async Task<User?> GetUserByName(string name, string role)
    {
        var normalizedName = NormalizeName(name);
        using var connection = _context.CreateConnection();
        
        return await connection.QueryFirstOrDefaultAsync<User>(
            "SELECT * FROM Users WHERE Name = @Name AND Role = @Role",
            new { Name = normalizedName, Role = role });
    }

    private static string GenerateUserId(string role)
    {
        var timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var random = Guid.NewGuid().ToString("N").Substring(0, 9);
        return $"{role}_{timestamp}_{random}";
    }
}

