# .NET 8 Backend - File Overview

## 📁 Project Structure

```
backend-dotnet/
│
├── 📄 Program.cs                    # Application entry point & configuration
│   • Configures services (DI, CORS, Swagger)
│   • Database initialization
│   • Middleware pipeline
│   • Server startup & network IP display
│
├── 📄 appsettings.json              # Configuration (Production)
│   • Connection strings
│   • Port configuration
│   • Logging settings
│
├── 📄 appsettings.Development.json  # Configuration (Development)
│   • Development-specific settings
│
├── 📄 FuelMateBackend.csproj        # Project file
│   • .NET 8 target framework
│   • NuGet package references
│   • Build configuration
│
├── 📂 Controllers/                  # API Endpoints (REST Controllers)
│   ├── UsersController.cs           # User registration, login, check-name
│   ├── RequestsController.cs        # Fuel requests, quotes, location
│   ├── ChatController.cs            # Chat messages, unread counts
│   └── HealthController.cs          # Health check endpoint
│
├── 📂 Services/                     # Business Logic Layer
│   ├── UsersService.cs              # User management, name suggestions
│   ├── RequestsService.cs           # Request/quote CRUD, location queries
│   ├── ChatService.cs               # Message handling, unread tracking
│   └── LocationService.cs           # Distance calculation, nearest search
│
├── 📂 Models/                       # Data Models (Entities)
│   ├── User.cs                      # User entity
│   ├── PetrolRequest.cs             # Fuel request entity
│   ├── Quote.cs                     # Quote entity
│   ├── ChatMessage.cs               # Chat message entity
│   └── UserLocation.cs              # In-memory location data
│
├── 📂 DTOs/                         # Data Transfer Objects
│   ├── UserDTOs.cs                  # CheckNameDto, CheckNameResponse
│   ├── RegisterDTOs.cs              # RegisterDto, RegisterResponse, UserDto
│   ├── RequestDTOs.cs               # CreateRequestDto, CreateQuoteDto
│   └── ChatDTOs.cs                  # SendMessageDto, MarkReadDto
│
├── 📂 Data/                         # Database Access Layer
│   ├── DapperContext.cs             # Database connection factory
│   └── DatabaseInitializer.cs      # Create tables on startup
│
├── 📂 bin/                          # Build output (auto-generated)
├── 📂 obj/                          # Build intermediates (auto-generated)
│
├── 📜 README.md                     # Complete documentation
├── 📜 MIGRATION_GUIDE.md            # NestJS → .NET migration guide
├── 📜 CONVERSION_SUMMARY.md         # What was converted
├── 📜 QUICKSTART.md                 # Quick start guide
├── 📜 FILE_OVERVIEW.md              # This file
│
├── 🔧 START_BACKEND.ps1             # Start the server
├── 🔧 SETUP_SQLSERVER.ps1           # Setup SQL Server database
└── 🔧 TEST_CONNECTION.ps1           # Test database connection
```

---

## 📝 File Descriptions

### Core Application Files

#### `Program.cs`
- Application entry point
- Configures dependency injection
- Sets up Swagger/OpenAPI
- Configures CORS for mobile apps
- Initializes database tables
- Displays network IPs on startup

#### `appsettings.json`
- Database connection string
- Server port (default: 3000)
- Logging configuration
- Environment-specific settings

### Controllers (API Layer)

#### `UsersController.cs`
**Endpoints:**
- `POST /api/users/check-name` - Check username availability
- `POST /api/users/register` - Register/login user
- `GET /api/users/{userId}` - Get user by ID
- `GET /api/users/debug/all` - Get all users

#### `RequestsController.cs`
**Endpoints:**
- `POST /api/requests/create` - Create fuel request
- `GET /api/requests/nearest` - Find nearest requests
- `GET /api/requests/providers/nearest` - Find nearest providers
- `GET /api/requests/needers/nearest` - Find nearest needers
- `GET /api/requests/history` - Get request history
- `GET /api/requests/active` - Get active requests
- `POST /api/requests/{id}/accept` - Accept request
- `POST /api/requests/{id}/complete` - Complete request
- `POST /api/requests/{id}/cancel` - Cancel request
- `POST /api/requests/quotes/create` - Create quote
- `POST /api/requests/quotes/{quoteId}/accept` - Accept quote
- `POST /api/requests/quotes/{quoteId}/reject` - Reject quote
- `GET /api/requests/quotes/*` - Various quote queries

#### `ChatController.cs`
**Endpoints:**
- `POST /api/chat/send` - Send message
- `GET /api/chat/messages/{requestId}` - Get messages
- `GET /api/chat/participants/{requestId}` - Get participants
- `GET /api/chat/unread-counts/{userId}` - Get unread counts
- `POST /api/chat/mark-read/{requestId}` - Mark as read

#### `HealthController.cs`
**Endpoints:**
- `GET /health` - Health check

### Services (Business Logic)

#### `UsersService.cs`
- User registration and login
- Name availability checking
- Name suggestion algorithm
- User retrieval by ID/name

#### `RequestsService.cs`
- Create, update, delete requests
- Find nearest requests/providers/needers
- Request history and active requests
- Quote management (create, accept, reject)
- Distance-based filtering

#### `ChatService.cs`
- Send and retrieve messages
- Chat participant management
- Unread message tracking
- Mark messages as read

#### `LocationService.cs`
- In-memory location storage
- Distance calculation (Haversine formula)
- Find nearest providers/needers
- Location updates

### Models (Entities)

#### `User.cs`
```csharp
- Id: string
- Name: string (unique)
- Role: string ("needy" or "provider")
- CreatedAt: DateTime
- LastLoginAt: DateTime
```

#### `PetrolRequest.cs`
```csharp
- Id: string
- NeedyId: string
- Role: string
- Latitude: decimal
- Longitude: decimal
- Message: string
- QuantityLiters: decimal?
- Urgency: string
- Status: string
- AcceptedBy: string?
- CreatedAt: DateTime
- UpdatedAt: DateTime
```

#### `Quote.cs`
```csharp
- Id: string
- RequestId: string
- ProviderId: string
- Price: decimal
- Currency: string
- EstimatedDeliveryTime: int?
- Message: string?
- Status: string
- CreatedAt: DateTime
- UpdatedAt: DateTime
```

#### `ChatMessage.cs`
```csharp
- Id: string
- RequestId: string
- SenderId: string
- SenderName: string
- SenderRole: string
- Message: string
- CreatedAt: DateTime
```

### Data Access

#### `DapperContext.cs`
- Creates SQL Server connections
- Manages connection lifecycle
- Connection string configuration

#### `DatabaseInitializer.cs`
- Creates tables on startup
- Executes SQL scripts
- Checks for existing tables

---

## 🗄️ Database Tables

### Users Table
```sql
CREATE TABLE Users (
    Id NVARCHAR(255) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL UNIQUE,
    Role NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL,
    LastLoginAt DATETIME2 NOT NULL
)
```

### PetrolRequests Table
```sql
CREATE TABLE PetrolRequests (
    Id NVARCHAR(255) PRIMARY KEY,
    NeedyId NVARCHAR(255) NOT NULL,
    NeedyName NVARCHAR(255),
    Role NVARCHAR(50) NOT NULL,
    Latitude DECIMAL(10, 7) NOT NULL,
    Longitude DECIMAL(10, 7) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    QuantityLiters DECIMAL(10, 2),
    Urgency NVARCHAR(50) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    AcceptedBy NVARCHAR(255),
    CreatedAt DATETIME2 NOT NULL,
    UpdatedAt DATETIME2 NOT NULL
)
```

### Quotes Table
```sql
CREATE TABLE Quotes (
    Id NVARCHAR(255) PRIMARY KEY,
    RequestId NVARCHAR(255) NOT NULL,
    ProviderId NVARCHAR(255) NOT NULL,
    ProviderName NVARCHAR(255),
    Price DECIMAL(10, 2) NOT NULL,
    Currency NVARCHAR(10) NOT NULL,
    EstimatedDeliveryTime INT,
    Message NVARCHAR(MAX),
    Status NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL,
    UpdatedAt DATETIME2 NOT NULL
)
```

### ChatMessages Table
```sql
CREATE TABLE ChatMessages (
    Id NVARCHAR(255) PRIMARY KEY,
    RequestId NVARCHAR(255) NOT NULL,
    SenderId NVARCHAR(255) NOT NULL,
    SenderName NVARCHAR(255) NOT NULL,
    SenderRole NVARCHAR(50) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME2 NOT NULL
)
```

---

## 📦 NuGet Packages

- **Dapper** (2.1.66) - Lightweight ORM for database access
- **Microsoft.Data.SqlClient** (5.2.0) - SQL Server data provider
- **Swashbuckle.AspNetCore** (6.5.0) - Swagger/OpenAPI documentation

---

## 🎯 Request Flow

```
1. HTTP Request → Controller
2. Controller → Service (Business Logic)
3. Service → Dapper → SQL Server
4. SQL Server → Dapper → Service
5. Service → Controller
6. Controller → HTTP Response
```

Example:
```
POST /api/users/register
  ↓
UsersController.Register()
  ↓
UsersService.RegisterOrLogin()
  ↓
Dapper Query → SQL Server
  ↓
Return User object
  ↓
Return JSON Response
```

---

## 🔐 Authentication

Currently uses **simple authentication** (user ID in request body).

For production, consider:
- JWT tokens
- OAuth 2.0
- API keys

---

## 📊 Technology Stack

- **Framework:** ASP.NET Core 8.0
- **Language:** C# 12
- **Database:** MS SQL Server
- **ORM:** Dapper (micro-ORM)
- **API Documentation:** Swagger (Swashbuckle)
- **Dependency Injection:** Built-in .NET DI
- **Configuration:** appsettings.json
- **Logging:** Built-in .NET logging

---

## 🚀 Quick Commands

```powershell
# Build
dotnet build

# Run
dotnet run

# Watch mode (auto-reload)
dotnet watch run

# Publish
dotnet publish -c Release
```

---

**Need more details?** Check out `README.md` or `MIGRATION_GUIDE.md`

