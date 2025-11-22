/**
 * API Endpoints Configuration
 * 
 * This file centralizes all API endpoint paths used in the mobile app.
 * Keep this in sync with backend controller files.
 * 
 * Last synced: Auto-generated - keep backend controllers in sync
 */

const API_PREFIX = '/api';

// ============================================
// User Endpoints
// ============================================
export const USER_ENDPOINTS = {
  CHECK_NAME: `${API_PREFIX}/users/check-name`,
  REGISTER: `${API_PREFIX}/users/register`,
  GET_BY_ID: (userId: string) => `${API_PREFIX}/users/${userId}`,
} as const;

// ============================================
// Request Endpoints
// ============================================
export const REQUEST_ENDPOINTS = {
  CREATE: `${API_PREFIX}/requests/create`,
  NEAREST: `${API_PREFIX}/requests/nearest`,
  PROVIDERS_NEAREST: `${API_PREFIX}/requests/providers/nearest`,
  NEEDERS_NEAREST: `${API_PREFIX}/requests/needers/nearest`,
  ACCEPT: (requestId: string) => `${API_PREFIX}/requests/${requestId}/accept`,
  GET_BY_ID: (requestId: string) => `${API_PREFIX}/requests/${requestId}`,
  COMPLETE: (requestId: string) => `${API_PREFIX}/requests/${requestId}/complete`,
  HISTORY: `${API_PREFIX}/requests/history`,
  ACTIVE: `${API_PREFIX}/requests/active`,
} as const;

// ============================================
// Quote Endpoints
// ============================================
export const QUOTE_ENDPOINTS = {
  CREATE: `${API_PREFIX}/requests/quotes/create`,
  GET_FOR_REQUEST: (requestId: string) => `${API_PREFIX}/requests/quotes/request/${requestId}`,
  GET_FOR_NEEDY: (needyId: string) => `${API_PREFIX}/requests/quotes/needy/${needyId}`,
  ACCEPT: (quoteId: string) => `${API_PREFIX}/requests/quotes/${quoteId}/accept`,
  REJECT: (quoteId: string) => `${API_PREFIX}/requests/quotes/${quoteId}/reject`,
} as const;

// ============================================
// Location Endpoints
// ============================================
export const LOCATION_ENDPOINTS = {
  UPDATE: `${API_PREFIX}/location/update`,
} as const;

// ============================================
// Chat Endpoints
// ============================================
export const CHAT_ENDPOINTS = {
  SEND: `${API_PREFIX}/chat/send`,
  GET_MESSAGES: (requestId: string) => `${API_PREFIX}/chat/messages/${requestId}`,
  GET_PARTICIPANTS: (requestId: string) => `${API_PREFIX}/chat/participants/${requestId}`,
  GET_UNREAD_COUNTS: (userId: string) => `${API_PREFIX}/chat/unread-counts/${userId}`,
  MARK_AS_READ: (requestId: string) => `${API_PREFIX}/chat/mark-read/${requestId}`,
} as const;

// ============================================
// Health Endpoints
// ============================================
export const HEALTH_ENDPOINTS = {
  CHECK: '/health',
} as const;

// ============================================
// All Endpoints (for reference)
// ============================================
export const API_ENDPOINTS = {
  ...USER_ENDPOINTS,
  ...REQUEST_ENDPOINTS,
  ...QUOTE_ENDPOINTS,
  ...LOCATION_ENDPOINTS,
  ...CHAT_ENDPOINTS,
  ...HEALTH_ENDPOINTS,
} as const;

