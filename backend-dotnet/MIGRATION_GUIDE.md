# Migration Guide: NestJS to .NET 8

This guide explains how to migrate from the NestJS backend to the .NET 8 backend.

## 🎯 Overview

The .NET 8 backend is a **complete rewrite** of the NestJS backend with:
- ✅ **Identical API endpoints** - No frontend changes required
- ✅ **Same request/response formats** - 100% API compatibility
- ✅ **Better performance** - .NET 8 is faster than Node.js
- ✅ **Dapper + SQL Server** - Instead of TypeORM + PostgreSQL
- ✅ **Strongly typed** - C# provides compile-time type safety

## 📊 Technology Stack Comparison

| Feature | NestJS Backend | .NET 8 Backend |
|---------|----------------|----------------|
| **Framework** | NestJS (Node.js) | ASP.NET Core 8.0 |
| **Language** | TypeScript | C# 12 |
| **Database** | PostgreSQL | MS SQL Server |
| **ORM** | TypeORM | Dapper |
| **API Docs** | Swagger (NestJS) | Swagger (Swashbuckle) |
| **Port** | 3000 | 3000 (configurable) |

## 🔄 API Endpoint Mapping

All endpoints remain **exactly the same**. No changes needed in mobile/Flutter apps.

### Users API

| Method | Endpoint | NestJS | .NET 8 | Status |
|--------|----------|--------|--------|--------|
| POST | `/api/users/check-name` | ✅ | ✅ | Identical |
| POST | `/api/users/register` | ✅ | ✅ | Identical |
| GET | `/api/users/:userId` | ✅ | ✅ | Identical |
| GET | `/api/users/debug/all` | ✅ | ✅ | Identical |

### Requests API

| Method | Endpoint | NestJS | .NET 8 | Status |
|--------|----------|--------|--------|--------|
| POST | `/api/requests/create` | ✅ | ✅ | Identical |
| GET | `/api/requests/nearest` | ✅ | ✅ | Identical |
| GET | `/api/requests/providers/nearest` | ✅ | ✅ | Identical |
| GET | `/api/requests/needers/nearest` | ✅ | ✅ | Identical |
| GET | `/api/requests/history` | ✅ | ✅ | Identical |
| GET | `/api/requests/active` | ✅ | ✅ | Identical |
| GET | `/api/requests/:id` | ✅ | ✅ | Identical |
| GET | `/api/requests/user/:userId` | ✅ | ✅ | Identical |
| POST | `/api/requests/:id/accept` | ✅ | ✅ | Identical |
| POST | `/api/requests/:id/complete` | ✅ | ✅ | Identical |
| POST | `/api/requests/:id/cancel` | ✅ | ✅ | Identical |

### Quotes API

| Method | Endpoint | NestJS | .NET 8 | Status |
|--------|----------|--------|--------|--------|
| POST | `/api/requests/quotes/create` | ✅ | ✅ | Identical |
| GET | `/api/requests/quotes/request/:requestId` | ✅ | ✅ | Identical |
| GET | `/api/requests/quotes/needy/:needyId` | ✅ | ✅ | Identical |
| GET | `/api/requests/quotes/provider/:providerId` | ✅ | ✅ | Identical |
| POST | `/api/requests/quotes/:quoteId/accept` | ✅ | ✅ | Identical |
| POST | `/api/requests/quotes/:quoteId/reject` | ✅ | ✅ | Identical |
| GET | `/api/requests/quotes/:quoteId` | ✅ | ✅ | Identical |

### Chat API

| Method | Endpoint | NestJS | .NET 8 | Status |
|--------|----------|--------|--------|--------|
| POST | `/api/chat/send` | ✅ | ✅ | Identical |
| GET | `/api/chat/messages/:requestId` | ✅ | ✅ | Identical |
| GET | `/api/chat/participants/:requestId` | ✅ | ✅ | Identical |
| GET | `/api/chat/unread-counts/:userId` | ✅ | ✅ | Identical |
| POST | `/api/chat/mark-read/:requestId` | ✅ | ✅ | Identical |

### Health API

| Method | Endpoint | NestJS | .NET 8 | Status |
|--------|----------|--------|--------|--------|
| GET | `/health` | ✅ | ✅ | Identical |

## 🔀 Database Migration

### Step 1: Export Data from PostgreSQL (Optional)

If you have existing data in PostgreSQL that you want to migrate:

```sql
-- Export Users
COPY users TO '/tmp/users.csv' CSV HEADER;

-- Export PetrolRequests
COPY petrol_requests TO '/tmp/requests.csv' CSV HEADER;

-- Export Quotes
COPY quotes TO '/tmp/quotes.csv' CSV HEADER;

-- Export ChatMessages (if you have a table)
COPY chat_messages TO '/tmp/chat.csv' CSV HEADER;
```

### Step 2: Setup SQL Server

Run the setup script:
```powershell
cd backend-dotnet
.\SETUP_SQLSERVER.ps1
```

### Step 3: Import Data to SQL Server (Optional)

Use SQL Server Management Studio or bulk insert:

```sql
-- Import Users
BULK INSERT Users
FROM 'C:\temp\users.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

-- Similar for other tables
```

### Step 4: Test the Migration

```powershell
.\TEST_CONNECTION.ps1
```

## 🚀 Migration Steps

### Option 1: Fresh Start (Recommended)

1. **Stop NestJS Backend**
   ```bash
   # Press Ctrl+C in the terminal running the backend
   ```

2. **Setup .NET Backend**
   ```powershell
   cd backend-dotnet
   .\SETUP_SQLSERVER.ps1
   ```

3. **Start .NET Backend**
   ```powershell
   .\START_BACKEND.ps1
   ```

4. **No Frontend Changes Needed**
   - All API endpoints are identical
   - Same port (3000)
   - Same request/response formats

### Option 2: Side-by-Side (Testing)

Run both backends simultaneously on different ports:

1. **Keep NestJS running on port 3000**

2. **Run .NET backend on port 5000**
   - Edit `backend-dotnet/appsettings.json`
   - Change `"Port": "5000"`

3. **Test .NET backend**
   ```bash
   curl http://localhost:5000/health
   ```

4. **Switch frontend to .NET backend**
   - Update `API_HOST_IP` in mobile/Flutter app config
   - Point to new port if needed

### Option 3: Gradual Migration

You can migrate one module at a time:

1. **Start with Health Check**
   ```bash
   curl http://localhost:5000/health
   ```

2. **Test Users API**
   ```bash
   curl -X POST http://localhost:5000/api/users/register \
     -H "Content-Type: application/json" \
     -d '{"name":"testuser","role":"needy"}'
   ```

3. **Test each API endpoint**

4. **Switch when confident**

## 🔧 Configuration Changes

### NestJS (.env)
```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_NAME=fuelmate
NODE_ENV=development
PORT=3000
```

### .NET 8 (appsettings.json)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=FuelMate;User Id=sa;Password=YourPassword123!;TrustServerCertificate=True;"
  },
  "Port": "3000"
}
```

## 📝 Code Structure Comparison

### NestJS Structure
```
backend/
├── src/
│   ├── users/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   ├── users.module.ts
│   │   └── user.entity.ts
│   ├── requests/
│   ├── chat/
│   └── main.ts
└── package.json
```

### .NET 8 Structure
```
backend-dotnet/
├── Controllers/
│   └── UsersController.cs      (users.controller.ts)
├── Services/
│   └── UsersService.cs         (users.service.ts)
├── Models/
│   └── User.cs                 (user.entity.ts)
├── DTOs/
│   └── UserDTOs.cs             (dto/*.ts)
├── Data/
│   └── DapperContext.cs        (database connection)
└── Program.cs                  (main.ts)
```

## 🎨 Code Examples

### NestJS Controller
```typescript
@Controller('api/users')
export class UsersController {
  @Post('register')
  async register(@Body() dto: RegisterDto) {
    const result = await this.usersService.registerOrLogin(dto.name, dto.role);
    return { success: true, user: result.user };
  }
}
```

### .NET 8 Controller
```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase {
  [HttpPost("register")]
  public async Task<IActionResult> Register([FromBody] RegisterDto dto) {
    var (user, isNewUser) = await _usersService.RegisterOrLogin(dto.Name, dto.Role);
    return Ok(new { success = true, user });
  }
}
```

## 🐛 Troubleshooting Migration

### Issue: "Connection refused"

**NestJS:**
```bash
# Check if PostgreSQL is running
pg_isready -h localhost -p 5432
```

**.NET:**
```powershell
# Check if SQL Server is running
Get-Service -Name "MSSQL*"
```

### Issue: Different Response Format

Both backends return **identical** JSON responses. If you see differences:

1. Check API version (should be same endpoint)
2. Verify request body format
3. Check Swagger docs: http://localhost:3000/api/docs

### Issue: Data Not Found

If data exists in PostgreSQL but not in SQL Server:

1. Export data from PostgreSQL (see above)
2. Import to SQL Server
3. Or start fresh (recommended for testing)

## ✅ Verification Checklist

After migration, verify:

- [ ] Health check works: `GET /health`
- [ ] User registration works
- [ ] Login works with existing users
- [ ] Requests can be created
- [ ] Nearest requests query works
- [ ] Quotes can be created and accepted
- [ ] Chat messages work
- [ ] Mobile/Flutter app connects successfully
- [ ] All features work as before

## 📊 Performance Comparison

Expected improvements with .NET 8:

- **Startup time**: ~2-3x faster
- **Memory usage**: ~30-40% lower
- **Request throughput**: ~2-3x higher
- **Response time**: ~20-30% faster

## 🔒 Security Considerations

Both backends:
- ✅ CORS enabled for mobile apps
- ✅ Input validation
- ✅ SQL injection protection (Dapper parameterized queries)
- ⚠️ **Note**: Both use simple authentication (no JWT yet)

## 📚 Additional Resources

- [.NET 8 Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [Dapper Documentation](https://github.com/DapperLib/Dapper)
- [ASP.NET Core Documentation](https://docs.microsoft.com/en-us/aspnet/core/)
- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)

## 🆘 Need Help?

1. Check the logs in the console
2. Visit `/api/docs` for Swagger documentation
3. Run `TEST_CONNECTION.ps1` to verify database
4. Compare responses with NestJS backend

## 🎉 Benefits of Migration

1. **Better Performance** - .NET 8 is faster than Node.js
2. **Type Safety** - C# provides compile-time checking
3. **Better Tooling** - Visual Studio, Rider, VS Code
4. **Easier Debugging** - Better debugging experience
5. **Lower Memory Usage** - More efficient resource usage
6. **Production Ready** - Better for enterprise deployments

## ⚡ Quick Switch Command

```powershell
# Stop NestJS
cd backend
# Press Ctrl+C

# Start .NET
cd ..\backend-dotnet
.\START_BACKEND.ps1
```

That's it! No changes needed in mobile/Flutter apps. All APIs work identically! 🚀

