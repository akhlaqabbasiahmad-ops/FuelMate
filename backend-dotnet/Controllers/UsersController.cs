using Microsoft.AspNetCore.Mvc;
using FuelMateBackend.Services;
using FuelMateBackend.DTOs;

namespace FuelMateBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
[Tags("users")]
public class UsersController : ControllerBase
{
    private readonly UsersService _usersService;

    public UsersController(UsersService usersService)
    {
        _usersService = usersService;
    }

    /// <summary>
    /// Check if a username is available
    /// </summary>
    [HttpPost("check-name")]
    public async Task<ActionResult<CheckNameResponse>> CheckName([FromBody] CheckNameDto dto)
    {
        var name = dto.Name.Trim();
        var isAvailable = await _usersService.IsNameAvailable(name);
        var suggestedName = await _usersService.SuggestName(name);

        return Ok(new CheckNameResponse
        {
            RequestedName = name,
            IsAvailable = isAvailable,
            SuggestedName = suggestedName,
            Message = isAvailable
                ? $"Name \"{name}\" is available!"
                : $"Name \"{name}\" is taken. Suggested: \"{suggestedName}\""
        });
    }

    /// <summary>
    /// Register a new user or login existing user (OLD METHOD - kept for backward compatibility)
    /// </summary>
    [HttpPost("register")]
    public async Task<ActionResult<RegisterResponse>> Register([FromBody] RegisterDto dto)
    {
        // If password is provided, use new registration method
        if (!string.IsNullOrEmpty(dto.Password))
        {
            try
            {
                var user = await _usersService.RegisterWithPassword(dto.Name, dto.Password, dto.Role);
                
                return Ok(new RegisterResponse
                {
                    Success = true,
                    User = new UserDto
                    {
                        Id = user.Id,
                        Name = user.Name,
                        Role = user.Role,
                        CreatedAt = user.CreatedAt,
                        LastLoginAt = user.LastLoginAt
                    },
                    IsNewUser = true,
                    Message = $"Welcome! Your account has been created."
                });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new RegisterResponse
                {
                    Success = false,
                    Message = ex.Message
                });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new RegisterResponse
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }

        // Old method without password (for backward compatibility)
        var (existingUser, isNewUser) = await _usersService.RegisterOrLogin(dto.Name, dto.Role);

        return Ok(new RegisterResponse
        {
            Success = true,
            User = new UserDto
            {
                Id = existingUser.Id,
                Name = existingUser.Name,
                Role = existingUser.Role
            },
            IsNewUser = isNewUser,
            Message = isNewUser
                ? $"Welcome! Your name is \"{existingUser.Name}\""
                : $"Welcome back, {existingUser.Name}!"
        });
    }

    /// <summary>
    /// Login with username and password
    /// </summary>
    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginDto dto)
    {
        try
        {
            var user = await _usersService.LoginWithPassword(dto.Name, dto.Password, dto.Role);

            if (user == null)
            {
                return Unauthorized(new LoginResponse
                {
                    Success = false,
                    Message = "Invalid username or password"
                });
            }

            return Ok(new LoginResponse
            {
                Success = true,
                User = new UserDto
                {
                    Id = user.Id,
                    Name = user.Name,
                    Role = user.Role,
                    CreatedAt = user.CreatedAt,
                    LastLoginAt = user.LastLoginAt
                },
                Message = $"Welcome back, {user.Name}!"
            });
        }
        catch (InvalidOperationException ex) when (ex.Message == "PASSWORD_NOT_SET")
        {
            return BadRequest(new LoginResponse
            {
                Success = false,
                Message = "PASSWORD_NOT_SET"
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Login error: {ex.Message}");
            return StatusCode(500, new LoginResponse
            {
                Success = false,
                Message = "An error occurred during login"
            });
        }
    }

    /// <summary>
    /// Check if user exists (for showing login vs register screen)
    /// </summary>
    [HttpPost("check-exists")]
    public async Task<IActionResult> CheckUserExists([FromBody] Dictionary<string, string> body)
    {
        if (!body.TryGetValue("name", out var name) || !body.TryGetValue("role", out var role))
        {
            return BadRequest(new { error = "Name and role are required" });
        }

        var user = await _usersService.GetUserByName(name, role);
        var exists = user != null;
        var hasPassword = exists && !string.IsNullOrEmpty(user!.PasswordHash);

        return Ok(new
        {
            exists,
            hasPassword,
            needsPasswordSet = exists && !hasPassword,
            message = exists
                ? (hasPassword ? "User exists with password" : "User exists but needs to set password")
                : "User does not exist"
        });
    }

    /// <summary>
    /// Get user by ID
    /// </summary>
    [HttpGet("{userId}")]
    public async Task<IActionResult> GetUser(string userId)
    {
        var user = await _usersService.GetUserById(userId);

        if (user == null)
        {
            return NotFound(new
            {
                error = "User not found",
                message = $"No user found with ID: {userId}"
            });
        }

        return Ok(new
        {
            success = true,
            user = new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                Role = user.Role,
                CreatedAt = user.CreatedAt,
                LastLoginAt = user.LastLoginAt
            }
        });
    }

    /// <summary>
    /// Get all users (debug endpoint)
    /// </summary>
    [HttpGet("debug/all")]
    public async Task<IActionResult> GetAllUsers()
    {
        var users = await _usersService.GetAllUsers();
        
        return Ok(new
        {
            success = true,
            count = users.Count,
            users = users.Select(u => new UserDto
            {
                Id = u.Id,
                Name = u.Name,
                Role = u.Role,
                CreatedAt = u.CreatedAt,
                LastLoginAt = u.LastLoginAt
            })
        });
    }
}

