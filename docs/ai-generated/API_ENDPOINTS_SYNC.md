# API Endpoints Synchronization

This document tracks the synchronization between frontend and backend API endpoints.

## Centralized Configuration

All API endpoints are now centralized in:
- **Frontend**: `mobile/src/config/api-endpoints.ts`
- **Backend**: `backend/src/config/api-endpoints.ts` (reference/documentation)

## Endpoint Categories

### User Endpoints
- `POST /api/users/check-name` - Check if username is available
- `POST /api/users/register` - Register or login user
- `GET /api/users/:userId` - Get user by ID

### Request Endpoints
- `POST /api/requests/create` - Create a new request
- `GET /api/requests/nearest` - Find nearest requests (for providers/needers)
- `GET /api/requests/providers/nearest` - Find nearest providers (for needers)
- `GET /api/requests/needers/nearest` - Find nearest needers (for providers)
- `POST /api/requests/:id/accept` - Accept a request
- `POST /api/requests/:id/complete` - Complete a request
- `GET /api/requests/history` - Get request history
- `GET /api/requests/active` - Get active requests

### Quote Endpoints
- `POST /api/requests/quotes/create` - Create a quote
- `GET /api/requests/quotes/request/:requestId` - Get quotes for a request
- `GET /api/requests/quotes/needy/:needyId` - Get quotes for a needy user
- `POST /api/requests/quotes/:quoteId/accept` - Accept a quote
- `POST /api/requests/quotes/:quoteId/reject` - Reject a quote

### Location Endpoints
- `POST /api/location/update` - Update user location

### Agent Endpoints
- `POST /api/agent/process` - Process AI agent request

### Health Endpoints
- `GET /health` - Health check

## Usage in Frontend

All frontend service files now import endpoints from `api-endpoints.ts`:

```typescript
import { REQUEST_ENDPOINTS, QUOTE_ENDPOINTS } from '../config/api-endpoints';

// Usage
const url = `${API_BASE_URL}${REQUEST_ENDPOINTS.CREATE}`;
const url = `${API_BASE_URL}${QUOTE_ENDPOINTS.ACCEPT(quoteId)}`;
```

## Benefits

1. **Single Source of Truth**: All endpoints defined in one place
2. **Type Safety**: TypeScript ensures correct usage
3. **Easy Updates**: Change endpoint once, updates everywhere
4. **Documentation**: Clear reference for all available endpoints
5. **Consistency**: Frontend and backend stay in sync

## Maintenance

When adding new endpoints:
1. Add to `mobile/src/config/api-endpoints.ts`
2. Add to `backend/src/config/api-endpoints.ts` (reference)
3. Update backend controller with `@Controller` and route decorators
4. Update frontend service to use the new endpoint constant

## Last Synced

All endpoints are synchronized as of the latest update.

