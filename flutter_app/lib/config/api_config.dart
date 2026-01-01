/// API Configuration
/// 
/// This file centralizes the API endpoint configuration.
/// Update apiHostIp to match your computer's local IP address.
/// 
/// To find your IP:
/// - Windows: Run ipconfig (look for IPv4 Address)
/// - Mac/Linux: Run ifconfig or ip addr
/// 
/// The API server should be running on port 3000.

class ApiConfig {
  // ============================================
  // CONFIGURATION - Update this IP address
  // ============================================
  static const String apiHostIp = '192.168.1.8'; // Your computer's local IP address (auto-detected)
  static const int apiPort = 3000; // .NET backend port
  
  // Set to true if testing on physical device, false for emulator/simulator
  static const bool usePhysicalDevice = true;
  
  // Production API URL (for production builds)
  static const String productionApiUrl = 'http://asentyx.com:4000';
  
  // ============================================
  // API URL Builder
  // ============================================
  
  /// Get the API base URL based on the current environment
  static String getApiBaseUrl() {
    // Always use production API URL for release builds
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    
    if (isProduction) {
      return productionApiUrl;
    }
    
    // Development mode - use local .NET backend
    // Physical device: use computer's network IP
    if (usePhysicalDevice) {
      return 'http://$apiHostIp:$apiPort';
    }
    
    // Android emulator: use 10.0.2.2
    // Web/Desktop: use localhost
    return 'http://10.0.2.2:$apiPort'; // For Android emulator
    
    // Alternative configurations:
    // return 'http://localhost:$apiPort'; // For web/desktop
    // return 'http://127.0.0.1:$apiPort'; // For iOS simulator
  }
  
  // Export the API base URL as a constant
  static final String apiBaseUrl = getApiBaseUrl();
}

