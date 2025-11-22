import { Injectable } from '@nestjs/common';
import { getDistance } from 'geolib';

export interface UserLocation {
  userId: string;
  name: string; // User's name
  role: 'needy' | 'provider';
  latitude: number;
  longitude: number;
  isAvailable: boolean;
}

@Injectable()
export class LocationService {
  // In-memory storage (replace with database in production)
  private userLocations: Map<string, UserLocation> = new Map();

  calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
  ): number {
    return getDistance(
      { latitude: lat1, longitude: lon1 },
      { latitude: lat2, longitude: lon2 },
    ) / 1000; // Convert to kilometers
  }

  findNearestProviders(
    needyLat: number,
    needyLon: number,
    maxDistanceKm: number = 10,
    limit: number = 5,
    excludeNeedyId?: string, // Optional: exclude this needy user's own ID
  ): UserLocation[] {
    const allLocations = Array.from(this.userLocations.values());
    const activeProviders = allLocations.filter(l => 
      l.role === 'provider' && 
      l.isAvailable && 
      (!excludeNeedyId || l.userId !== excludeNeedyId) // Exclude needy's own ID
    );
    
    const providers: UserLocation[] = [];

    for (const location of allLocations) {
      // Only show active providers, and exclude the needy user's own ID
      if (location.role === 'provider' && location.isAvailable && (!excludeNeedyId || location.userId !== excludeNeedyId)) {
        const distance = this.calculateDistance(
          needyLat,
          needyLon,
          location.latitude,
          location.longitude,
        );

        // Don't log individual provider distances - too verbose

        if (distance <= maxDistanceKm) {
          providers.push({
            ...location,
            // Add distance for sorting
            ...({ distance } as any),
          });
        }
      }
    }

    // Only log summary, not individual providers

    // Sort by distance and return top results
    return providers
      .sort((a, b) => (a as any).distance - (b as any).distance)
      .slice(0, limit);
  }

  findNearestNeedy(
    providerLat: number,
    providerLon: number,
    maxDistanceKm: number = 10,
    limit: number = 5,
    excludeProviderId?: string, // Optional: exclude this provider's own ID
  ): UserLocation[] {
    const allLocations = Array.from(this.userLocations.values());
    
    const activeNeedy = allLocations.filter(l => 
      l.role === 'needy' && 
      l.isAvailable && 
      (!excludeProviderId || l.userId !== excludeProviderId) // Exclude provider's own ID
    );
    
    // Only log if no needers found (important for debugging)
    if (activeNeedy.length === 0) {
      console.log('⚠️ No active needers found in system');
    }
    
    const needyUsers: UserLocation[] = [];

    for (const location of allLocations) {
      // Only show active needers, and exclude the provider's own ID
      if (location.role === 'needy' && location.isAvailable && (!excludeProviderId || location.userId !== excludeProviderId)) {
        const distance = this.calculateDistance(
          providerLat,
          providerLon,
          location.latitude,
          location.longitude,
        );

        // Don't log individual needy distances - too verbose

        if (distance <= maxDistanceKm) {
          needyUsers.push({
            ...location,
            ...({ distance } as any),
          });
        }
        // Don't log individual distances or summaries - too verbose
      }
    }

    return needyUsers
      .sort((a, b) => (a as any).distance - (b as any).distance)
      .slice(0, limit);
  }

  updateLocation(userId: string, location: UserLocation): void {
    // IMPORTANT: userId parameter is the backend-assigned user ID from signup
    // This ID is never changed - it's the same ID assigned during registration
    // Only location coordinates, name, and availability are updated here
    
    const existingLocation = this.userLocations.get(userId);
    // Only log on first registration or significant changes (role change, availability change)
    if (!existingLocation) {
      console.log(`📍 New user registered: ${location.role} ${location.name} (${userId})`);
    } else if (existingLocation.role !== location.role || existingLocation.isAvailable !== location.isAvailable) {
      console.log(`📍 User ${location.name} (${userId}) changed: role=${existingLocation.role}→${location.role}, available=${existingLocation.isAvailable}→${location.isAvailable}`);
    }
    // Don't log routine location updates - too verbose
    
    // Update location data but preserve the userId (it's the key in the map)
    // The userId in the location object should match the key
    this.userLocations.set(userId, { ...location, userId });
  }

  getLocation(userId: string): UserLocation | undefined {
    return this.userLocations.get(userId);
  }
}

