import { Platform } from 'react-native';

/**
 * API Configuration
 * 
 * This file centralizes the API endpoint configuration.
 * Update API_HOST_IP to match your computer's local IP address.
 * 
 * To find your IP:
 * - Windows: Run backend/FIND_IP.ps1 or use: ipconfig (look for IPv4 Address)
 * - Mac/Linux: Run: ifconfig or ip addr
 * 
 * The API server should be running on port 3000.
 */

// ============================================
// CONFIGURATION - Update this IP address
// ============================================
export const API_HOST_IP = '192.168.1.6'; // Your computer's local IP address
export const API_PORT = 3000;

// Set to true if testing on physical device, false for emulator/simulator
export const USE_PHYSICAL_DEVICE = true;

// Production API URL (for production builds)
export const PRODUCTION_API_URL = 'http://asentyx.com:4000';

// ============================================
// API URL Builder
// ============================================
/**
 * Get the API base URL based on the current environment and platform
 */
export const getApiBaseUrl = (): string => {
  // Always use production API URL for APK builds
  // Production mode - use production API URL
  if (!__DEV__) {
    return PRODUCTION_API_URL;
  }

  // Force production URL for APK builds (even in debug mode)
  // This ensures the APK uses the production server
  return PRODUCTION_API_URL;

  // Development mode (only used when running with Expo dev server)
  // Uncomment below if you need local development
  /*
  const baseUrl = `http://${API_HOST_IP}:${API_PORT}`;

  if (Platform.OS === 'android') {
    if (USE_PHYSICAL_DEVICE) {
      // Physical Android device - use your computer's IP
      return baseUrl;
    } else {
      // Android emulator - use special IP to access host machine
      return `http://10.0.2.2:${API_PORT}`;
    }
  } else if (Platform.OS === 'ios') {
    if (USE_PHYSICAL_DEVICE) {
      // Physical iOS device - use your computer's IP
      return baseUrl;
    } else {
      // iOS simulator - localhost works
      return `http://localhost:${API_PORT}`;
    }
  } else {
    // Web or other - use localhost
    return `http://localhost:${API_PORT}`;
  }
  */
};

// Export the API base URL as a constant
export const API_BASE_URL = getApiBaseUrl();

