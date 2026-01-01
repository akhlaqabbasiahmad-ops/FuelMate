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
    /// Register a new user or login existing user
    /// </summary>
    [HttpPost("register")]
    public async Task<ActionResult<RegisterResponse>> Register([FromBody] RegisterDto dto)
    {
        var (user, isNewUser) = await _usersService.RegisterOrLogin(dto.Name, dto.Role);

        return Ok(new RegisterResponse
        {
            Success = true,
            User = new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                Role = user.Role
            },
            IsNewUser = isNewUser,
            Message = isNewUser
                ? $"Welcome! Your name is \"{user.Name}\""
                : $"Welcome back, {user.Name}!"
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

