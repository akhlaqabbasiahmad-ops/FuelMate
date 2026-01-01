# FuelMate Backend API (.NET 8)

**ASP.NET Core Web API** backend for FuelMate AI Agent system, using **Dapper** and **MS SQL Server**.

This is a complete rewrite of the original NestJS backend in .NET 8 with identical API endpoints.

## 🚀 Quick Start

### Prerequisites

- **.NET 8 SDK** - [Download here](https://dotnet.microsoft.com/download/dotnet/8.0)
- **SQL Server** (Express or Developer Edition) - [Download here](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- **SQL Server Management Studio** (optional but recommended) - [Download here](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)

### Installation

1. **Install .NET 8 SDK**
   ```bash
   # Verify installation
   dotnet --version
   # Should show 8.x.x
   ```

2. **Install SQL Server**
   - Download and install SQL Server Express (FREE)
   - During installation:
     - Choose **Mixed Mode Authentication**
     - Set a strong password for `sa` user
     - Enable **TCP/IP protocol**

3. **Setup Database**
   ```powershell
   cd backend-dotnet
   .\SETUP_SQLSERVER.ps1
   ```
   
   This script will:
   - Check SQL Server installation
   - Test connection
   - Create the `FuelMate` database
   - Update `appsettings.json` with your connection string

4. **Test Connection**
   ```powershell
   .\TEST_CONNECTION.ps1
   ```

5. **Run the Backend**
   ```powershell
   .\START_BACKEND.ps1
   ```
   
   Or manually:
   ```bash
   dotnet restore
   dotnet build
   dotnet run
   ```

The server will start on **http://localhost:3000**

API Documentation (Swagger) will be available at: **http://localhost:3000/api/docs**

## 📁 Project Structure

```
backend-dotnet/
├── Controllers/          # API Controllers
│   ├── UsersController.cs
│   ├── RequestsController.cs
│   ├── ChatController.cs
│   └── HealthController.cs
├── Services/            # Business Logic
│   ├── UsersService.cs
│   ├── RequestsService.cs
│   ├── ChatService.cs
│   └── LocationService.cs
├── Models/              # Data Models
│   ├── User.cs
│   ├── PetrolRequest.cs
│   ├── Quote.cs
│   ├── ChatMessage.cs
│   └── UserLocation.cs
├── DTOs/                # Data Transfer Objects
│   ├── UserDTOs.cs
│   ├── RegisterDTOs.cs
│   ├── RequestDTOs.cs
│   └── ChatDTOs.cs
├── Data/                # Database Access
│   ├── DapperContext.cs
│   └── DatabaseInitializer.cs
├── Program.cs           # Application Entry Point
├── appsettings.json     # Configuration
└── FuelMateBackend.csproj
```

## 🗄️ Database Configuration

The application uses **MS SQL Server** with **Dapper** for data access.

### Default Connection String

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=FuelMate;User Id=sa;Password=YourPassword123!;TrustServerCertificate=True;"
  }
}
```

Update `appsettings.json` with your SQL Server credentials.

### Database Tables

The database tables are automatically created on first run:

- **Users** - User accounts (needy and providers)
- **PetrolRequests** - Fuel delivery requests
- **Quotes** - Price quotes from providers
- **ChatMessages** - Chat messages between users

## 📚 API Documentation

### Base URL
```
http://localhost:3000
```

### Swagger/OpenAPI
Interactive API documentation is available at:
```
http://localhost:3000/api/docs
```

### Main Endpoints

#### Users
- `POST /api/users/check-name` - Check username availability
- `POST /api/users/register` - Register or login user
- `GET /api/users/{userId}` - Get user by ID
- `GET /api/users/debug/all` - Get all users (debug)

#### Requests
- `POST /api/requests/create` - Create fuel request
- `GET /api/requests/nearest` - Find nearest requests
- `GET /api/requests/providers/nearest` - Find nearest providers
- `GET /api/requests/needers/nearest` - Find nearest needers
- `GET /api/requests/history` - Get request history
- `GET /api/requests/active` - Get active requests
- `POST /api/requests/{id}/accept` - Accept request
- `POST /api/requests/{id}/complete` - Complete request
- `POST /api/requests/{id}/cancel` - Cancel request

#### Quotes
- `POST /api/requests/quotes/create` - Create quote
- `GET /api/requests/quotes/request/{requestId}` - Get quotes for request
- `GET /api/requests/quotes/needy/{needyId}` - Get quotes for needy
- `GET /api/requests/quotes/provider/{providerId}` - Get quotes for provider
- `POST /api/requests/quotes/{quoteId}/accept` - Accept quote
- `POST /api/requests/quotes/{quoteId}/reject` - Reject quote

#### Chat
- `POST /api/chat/send` - Send message
- `GET /api/chat/messages/{requestId}` - Get messages for request
- `GET /api/chat/participants/{requestId}` - Get chat participants
- `GET /api/chat/unread-counts/{userId}` - Get unread message counts
- `POST /api/chat/mark-read/{requestId}` - Mark messages as read

#### Health
- `GET /health` - Health check endpoint

## 🔧 Configuration

### appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=FuelMate;User Id=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
  },
  "Port": "3000",
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

### Environment Variables

You can also configure via environment variables:
- `ConnectionStrings__DefaultConnection` - Database connection string
- `Port` - Server port (default: 3000)

## 🌐 CORS Configuration

CORS is enabled for all origins to allow mobile app connections:

```csharp
app.UseCors(policy => 
    policy.AllowAnyOrigin()
          .AllowAnyMethod()
          .AllowAnyHeader());
```

## 🚦 Running in Production

1. **Update appsettings.json** for production:
   - Use a secure connection string
   - Disable detailed error messages
   - Configure proper logging

2. **Publish the application**:
   ```bash
   dotnet publish -c Release -o ./publish
   ```

3. **Run the published app**:
   ```bash
   cd publish
   dotnet FuelMateBackend.dll
   ```

4. **Or host in IIS**:
   - Install ASP.NET Core Hosting Bundle
   - Create IIS website pointing to publish folder
   - Configure application pool

## 🔥 Firewall Configuration

To allow mobile app connections, open port 3000 in Windows Firewall:

**Option 1: Use PowerShell**
```powershell
New-NetFirewallRule -DisplayName "FuelMate API" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

**Option 2: Use GUI**
1. Open Windows Defender Firewall
2. Advanced Settings
3. Inbound Rules → New Rule
4. Port → TCP → 3000
5. Allow the connection

## 🐛 Troubleshooting

### SQL Server Connection Issues

1. **Check SQL Server is running**:
   ```powershell
   Get-Service -Name "MSSQL*"
   ```

2. **Enable TCP/IP protocol**:
   - Open SQL Server Configuration Manager
   - SQL Server Network Configuration → Protocols for [Instance]
   - Enable TCP/IP
   - Restart SQL Server service

3. **Check firewall**:
   - SQL Server default port: 1433
   - Ensure firewall allows connections

4. **Test connection**:
   ```powershell
   .\TEST_CONNECTION.ps1
   ```

### Common Errors

**"Cannot connect to SQL Server"**
- Verify SQL Server is running
- Check connection string in appsettings.json
- Ensure TCP/IP is enabled
- Check SQL Server authentication mode (Mixed Mode required for sa login)

**"Login failed for user 'sa'"**
- Verify password is correct
- Ensure Mixed Mode authentication is enabled
- Check if sa account is enabled

**"Database 'FuelMate' does not exist"**
- Run `SETUP_SQLSERVER.ps1` to create the database
- Or manually create it in SQL Server Management Studio

**"Port 3000 is already in use"**
- Change port in appsettings.json
- Or stop other applications using port 3000

## 📝 Migration from NestJS Backend

See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for detailed migration instructions from the NestJS backend.

## 🛠️ Development

### Building
```bash
dotnet build
```

### Running in Development Mode
```bash
dotnet run
```

### Running with Hot Reload
```bash
dotnet watch run
```

### Running Tests (if added)
```bash
dotnet test
```

## 📦 NuGet Packages Used

- **Dapper** (2.1.66) - Lightweight ORM
- **Microsoft.Data.SqlClient** (5.2.0) - SQL Server data provider
- **Swashbuckle.AspNetCore** (6.5.0) - Swagger/OpenAPI

## 🤝 Contributing

When contributing:
1. Follow C# coding conventions
2. Add XML documentation comments to public APIs
3. Update Swagger documentation
4. Test all endpoints

## 📄 License

MIT License

