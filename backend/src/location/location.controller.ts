import { Controller, Post, Get, Body, Query } from '@nestjs/common';
import { LocationService, UserLocation } from './location.service';

@Controller('api/location')
export class LocationController {
  constructor(private readonly locationService: LocationService) {}

  @Post('update')
  async updateLocation(@Body() location: UserLocation) {
    // IMPORTANT: location.userId is the backend-assigned user ID from signup
    // This ID is never changed - it's the same ID assigned during registration
    // Only location coordinates, name, and availability are updated here
    
    // IMPORTANT: Preserve existing role if user is already registered
    const existingLocation = this.locationService.getLocation(location.userId);
    
    if (existingLocation) {
      // User already exists - preserve their role, only update location and availability
      // The userId remains the same (backend-assigned ID)
      const updatedLocation: UserLocation = {
        ...location,
        userId: location.userId, // Ensure userId is preserved (backend-assigned ID)
        role: existingLocation.role, // Preserve existing role
        name: location.name || existingLocation.name, // Use new name if provided, otherwise keep existing
      };
      this.locationService.updateLocation(location.userId, updatedLocation);
      // Don't log routine location updates - too verbose
    } else {
      // New user - use the role from request
      // The userId comes from the request body (backend-assigned ID from signup)
      this.locationService.updateLocation(location.userId, location);
      // Logging handled in service
    }
    
    return {
      success: true,
      message: 'Location updated successfully',
      location: existingLocation ? { ...location, role: existingLocation.role } : location,
    };
  }

  @Get('user/:userId')
  async getUserLocation(@Body('userId') userId: string) {
    const location = this.locationService.getLocation(userId);
    return { location };
  }

  @Get('all')
  async getAllLocations() {
    // For debugging - get all registered locations
    const locations: UserLocation[] = [];
    // Note: This is a simplified version - in production, use proper storage
    return { 
      message: 'Use update endpoint to register locations',
      note: 'Locations are stored when requests are created or providers register',
    };
  }
}

