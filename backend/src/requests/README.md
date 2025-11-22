# Requests Module

This module handles petrol requests and matching them with nearest providers/needers.

## Features

- Create petrol requests
- Find nearest requests for providers
- Find nearest providers for needers
- Accept requests
- Complete/cancel requests
- Real-time distance calculation
- Urgency-based sorting

## API Endpoints

### Create Request
```
POST /api/requests/create
Body: {
  userId: string,
  latitude: number,
  longitude: number,
  message: string,
  quantityLiters?: number,
  urgency?: 'normal' | 'urgent'
}
```

### Find Nearest Requests (for Providers)
```
GET /api/requests/nearest?latitude=24.8607&longitude=67.0011&maxDistance=10&limit=10
```

### Find Nearest Providers (for Needers)
```
GET /api/requests/providers/nearest?latitude=24.8607&longitude=67.0011&maxDistance=10&limit=10
```

### Accept Request
```
POST /api/requests/:id/accept
Body: {
  providerId: string
}
```

### Get Request
```
GET /api/requests/:id
```

### Cancel Request
```
POST /api/requests/:id/cancel
Body: {
  userId: string
}
```

### Complete Request
```
POST /api/requests/:id/complete
Body: {
  providerId: string
}
```

## Request Status Flow

1. **pending** - Request created, waiting for provider
2. **accepted** - Provider accepted the request
3. **in_progress** - Delivery in progress
4. **completed** - Delivery completed
5. **cancelled** - Request cancelled by needy

## Distance Calculation

Requests are sorted by:
1. Urgency (urgent first)
2. Distance (nearest first)

Max distance default: 10km

