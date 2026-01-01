/// API Endpoints Configuration
/// 
/// This file centralizes all API endpoint paths used in the mobile app.
/// Keep this in sync with backend controller files.

class ApiEndpoints {
  static const String apiPrefix = '/api';
  
  // ============================================
  // User Endpoints
  // ============================================
  static const String checkName = '$apiPrefix/users/check-name';
  static const String register = '$apiPrefix/users/register';
  static String getUserById(String userId) => '$apiPrefix/users/$userId';
  
  // ============================================
  // Request Endpoints
  // ============================================
  static const String createRequest = '$apiPrefix/requests/create';
  static const String nearestRequests = '$apiPrefix/requests/nearest';
  static const String providersNearest = '$apiPrefix/requests/providers/nearest';
  static const String needersNearest = '$apiPrefix/requests/needers/nearest';
  static String acceptRequest(String requestId) => '$apiPrefix/requests/$requestId/accept';
  static String getRequestById(String requestId) => '$apiPrefix/requests/$requestId';
  static String completeRequest(String requestId) => '$apiPrefix/requests/$requestId/complete';
  static const String requestHistory = '$apiPrefix/requests/history';
  static const String activeRequests = '$apiPrefix/requests/active';
  
  // ============================================
  // Quote Endpoints
  // ============================================
  static const String createQuote = '$apiPrefix/requests/quotes/create';
  static String getQuotesForRequest(String requestId) => '$apiPrefix/requests/quotes/request/$requestId';
  static String getQuotesForNeedy(String needyId) => '$apiPrefix/requests/quotes/needy/$needyId';
  static String acceptQuote(String quoteId) => '$apiPrefix/requests/quotes/$quoteId/accept';
  static String rejectQuote(String quoteId) => '$apiPrefix/requests/quotes/$quoteId/reject';
  
  // ============================================
  // Location Endpoints
  // ============================================
  static const String updateLocation = '$apiPrefix/location/update';
  
  // ============================================
  // Chat Endpoints
  // ============================================
  static const String sendMessage = '$apiPrefix/chat/send';
  static String getChatMessages(String requestId) => '$apiPrefix/chat/messages/$requestId';
  static String getChatParticipants(String requestId) => '$apiPrefix/chat/participants/$requestId';
  static String getUnreadCounts(String userId) => '$apiPrefix/chat/unread-counts/$userId';
  static String markAsRead(String requestId) => '$apiPrefix/chat/mark-read/$requestId';
  
  // ============================================
  // Health Endpoints
  // ============================================
  static const String healthCheck = '/health';
}

