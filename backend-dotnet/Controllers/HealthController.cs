using Microsoft.AspNetCore.Mvc;

namespace FuelMateBackend.Controllers;

[ApiController]
[Route("[controller]")]
[Tags("health")]
public class HealthController : ControllerBase
{
    /// <summary>
    /// Health check endpoint
    /// </summary>
    [HttpGet]
    public IActionResult Check()
    {
        return Ok(new
        {
            status = "ok",
            message = "FuelMate API is running",
            timestamp = DateTime.UtcNow.ToString("O")
        });
    }
}

