/**
 * API Endpoints Reference
 * 
 * This file documents all API endpoints defined in the backend controllers.
 * Keep this in sync with actual controller routes.
 * 
 * This is a reference file for documentation and testing purposes.
 * The actual routes are defined in the controller decorators.
 */

/**
 * User Endpoints (users.controller.ts)
 */
export const USER_ENDPOINTS = {
  CHECK_NAME: '/api/users/check-name', // POST
  REGISTER: '/api/users/register', // POST
  GET_BY_ID: (userId: string) => `/api/users/${userId}`, // GET
  DEBUG_ALL: '/api/users/debug/all', // GET (debug only)
} as const;

/**
 * Request Endpoints (requests.controller.ts)
 */
export const REQUEST_ENDPOINTS = {
  CREATE: '/api/requests/create', // POST
  NEAREST: '/api/requests/nearest', // GET
  PROVIDERS_NEAREST: '/api/requests/providers/nearest', // GET
  NEEDERS_NEAREST: '/api/requests/needers/nearest', // GET
  ACCEPT: (requestId: string) => `/api/requests/${requestId}/accept`, // POST
  GET_BY_ID: (requestId: string) => `/api/requests/${requestId}`, // GET
  GET_USER_REQUESTS: (userId: string) => `/api/requests/user/${userId}`, // GET
  CANCEL: (requestId: string) => `/api/requests/${requestId}/cancel`, // POST
  COMPLETE: (requestId: string) => `/api/requests/${requestId}/complete`, // POST
  HISTORY: '/api/requests/history', // GET
  ACTIVE: '/api/requests/active', // GET
} as const;

/**
 * Quote Endpoints (requests.controller.ts)
 */
export const QUOTE_ENDPOINTS = {
  CREATE: '/api/requests/quotes/create', // POST
  GET_FOR_REQUEST: (requestId: string) => `/api/requests/quotes/request/${requestId}`, // GET
  GET_FOR_NEEDY: (needyId: string) => `/api/requests/quotes/needy/${needyId}`, // GET
  GET_FOR_PROVIDER: (providerId: string) => `/api/requests/quotes/provider/${providerId}`, // GET
  ACCEPT: (quoteId: string) => `/api/requests/quotes/${quoteId}/accept`, // POST
  REJECT: (quoteId: string) => `/api/requests/quotes/${quoteId}/reject`, // POST
  GET_BY_ID: (quoteId: string) => `/api/requests/quotes/${quoteId}`, // GET
} as const;

/**
 * Location Endpoints (location.controller.ts)
 */
export const LOCATION_ENDPOINTS = {
  UPDATE: '/api/location/update', // POST
  GET_USER: (userId: string) => `/api/location/user/${userId}`, // GET
  GET_ALL: '/api/location/all', // GET (debug only)
} as const;

/**
 * Chat Endpoints (chat.controller.ts)
 */
export const CHAT_ENDPOINTS = {
  SEND: '/api/chat/send', // POST
  GET_MESSAGES: (requestId: string) => `/api/chat/messages/${requestId}`, // GET
  GET_PARTICIPANTS: (requestId: string) => `/api/chat/participants/${requestId}`, // GET
} as const;

/**
 * Health Endpoints (health.controller.ts)
 */
export const HEALTH_ENDPOINTS = {
  CHECK: '/health', // GET
} as const;

/**
 * All Endpoints Summary
 */
export const API_ENDPOINTS = {
  ...USER_ENDPOINTS,
  ...REQUEST_ENDPOINTS,
  ...QUOTE_ENDPOINTS,
  ...LOCATION_ENDPOINTS,
  ...CHAT_ENDPOINTS,
  ...HEALTH_ENDPOINTS,
} as const;

