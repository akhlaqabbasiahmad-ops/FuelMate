using FuelMateBackend.Data;
using FuelMateBackend.Services;
using Microsoft.OpenApi.Models;
using System.Net;
using System.Net.Sockets;
using System.Net.NetworkInformation;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configure Swagger/OpenAPI
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "FuelMate API",
        Version = "1.0",
        Description = "FuelMate Backend API - Location-based fuel request and delivery platform (.NET 8)"
    });
    
    // Add XML comments if available
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
});

// Register Database Context
builder.Services.AddSingleton<DapperContext>();

// Register Services
builder.Services.AddSingleton<LocationService>();
builder.Services.AddScoped<UsersService>();
builder.Services.AddScoped<RequestsService>();
builder.Services.AddScoped<ChatService>();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Initialize database tables
Console.WriteLine("\n📊 Database Configuration:");
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
var connStrStatus = string.IsNullOrEmpty(connectionString) ? "NOT SET ❌" : "SET ✅";
var appSettingsExists = File.Exists("appsettings.json") ? "YES ✅" : "NO ❌";
Console.WriteLine($"   Connection String: {connStrStatus}");
Console.WriteLine($"   appsettings.json exists: {appSettingsExists}");
Console.WriteLine("");

try
{
    var dapperContext = app.Services.GetRequiredService<DapperContext>();
    await DatabaseInitializer.InitializeDatabaseAsync(dapperContext);
}
catch (Exception ex)
{
    Console.WriteLine($"⚠️ Database initialization warning: {ex.Message}");
    Console.WriteLine("   Make sure SQL Server is running and connection string is configured");
    Console.WriteLine("");
}

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "FuelMate API v1");
        c.RoutePrefix = "api/docs";
        c.DocumentTitle = "FuelMate API Documentation";
    });
}

// Enable CORS
app.UseCors();

app.UseAuthorization();

app.MapControllers();

// Get network IPs for display
var networkIPs = GetNetworkIPs();

var port = builder.Configuration["Port"] ?? "5000";
var urls = $"http://0.0.0.0:{port}";

Console.WriteLine("");
Console.WriteLine("========================================");
Console.WriteLine("  FuelMate API is running! (.NET 8)");
Console.WriteLine("========================================");
Console.WriteLine("");
Console.WriteLine("Server accessible on:");
Console.WriteLine($"  - http://localhost:{port}");
Console.WriteLine($"  - http://127.0.0.1:{port}");
Console.WriteLine("");
Console.WriteLine("API Documentation (Swagger):");
Console.WriteLine($"  - http://localhost:{port}/api/docs");
Console.WriteLine("");

if (networkIPs.Any())
{
    Console.WriteLine("Network IP addresses (for mobile app):");
    foreach (var ip in networkIPs)
    {
        Console.WriteLine($"  - http://{ip}:{port}");
    }
    Console.WriteLine("");
    Console.WriteLine($"⚠️ IMPORTANT: Make sure Windows Firewall allows connections on port {port}");
    Console.WriteLine("⚠️ If connection fails, check firewall settings or run as administrator");
    Console.WriteLine("");
}
else
{
    Console.WriteLine("⚠️ No network IP addresses found. Check your network connection.");
    Console.WriteLine("");
}

Console.WriteLine("Mobile app configuration:");
Console.WriteLine($"  Update flutter_app/lib/config/api_config.dart with: API_HOST_IP = '{networkIPs.FirstOrDefault() ?? "YOUR_IP_HERE"}'");
Console.WriteLine("");
Console.WriteLine("========================================");
Console.WriteLine("");

app.Run(urls);

// Helper method to get network IP addresses
static List<string> GetNetworkIPs()
{
    var ips = new List<string>();
    
    try
    {
        var interfaces = NetworkInterface.GetAllNetworkInterfaces()
            .Where(ni => ni.OperationalStatus == OperationalStatus.Up && 
                        ni.NetworkInterfaceType != NetworkInterfaceType.Loopback);

        foreach (var ni in interfaces)
        {
            var properties = ni.GetIPProperties();
            foreach (var ip in properties.UnicastAddresses)
            {
                if (ip.Address.AddressFamily == AddressFamily.InterNetwork)
                {
                    var ipStr = ip.Address.ToString();
                    // Skip link-local addresses (169.254.x.x)
                    if (!ipStr.StartsWith("169.254."))
                    {
                        ips.Add(ipStr);
                    }
                }
            }
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"⚠️ Error getting network IPs: {ex.Message}");
    }
    
    return ips;
}
