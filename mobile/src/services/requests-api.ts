import axios from 'axios';
import { API_BASE_URL } from '../config/api.config';
import { REQUEST_ENDPOINTS, QUOTE_ENDPOINTS, LOCATION_ENDPOINTS } from '../config/api-endpoints';

export interface CreateRequestData {
  latitude: number;
  longitude: number;
  message: string;
  quantityLiters?: number;
  urgency?: 'normal' | 'urgent';
  userId?: string;
  userRole?: 'needy' | 'provider'; // Role of user creating request
}

export interface Quote {
  id: string;
  requestId: string;
  providerId: string;
  needyId: string;
  price: number;
  currency: string;
  estimatedDeliveryTime: number;
  message?: string;
  status: 'pending' | 'accepted' | 'rejected' | 'expired';
  createdAt: string;
  expiresAt: string;
}

export interface CreateQuoteData {
  requestId: string;
  providerId: string;
  price: number;
  currency: string;
  estimatedDeliveryTime: number;
  message?: string;
}

export interface PetrolRequest {
  id: string;
  needyId: string;
  needyName?: string;
  name?: string;
  role?: 'needy' | 'provider';
  latitude: number;
  longitude: number;
  message: string;
  quantityLiters?: number;
  urgency: 'normal' | 'urgent';
  status: 'pending' | 'accepted' | 'in_progress' | 'completed' | 'cancelled';
  acceptedBy?: string;
  createdAt?: string | Date;
  updatedAt?: string | Date;
  distance?: number;
  type?: 'request' | 'needy' | 'provider';
}

export const createRequest = async (data: CreateRequestData) => {
  if (!data.userId) {
    throw new Error('User ID is required to create request');
  }
  
  const url = `${API_BASE_URL}${REQUEST_ENDPOINTS.CREATE}`;
  console.log('📝 Creating request with real user data:', {
    userId: data.userId,
    userRole: data.userRole || 'needy',
    location: { lat: data.latitude, lon: data.longitude },
    message: data.message,
  });
  
  try {
    const response = await axios.post(url, {
      latitude: data.latitude,
      longitude: data.longitude,
      message: data.message,
      quantityLiters: data.quantityLiters,
      urgency: data.urgency,
      userId: data.userId, // Real user ID from storage
      userRole: data.userRole || 'needy', // Role of user creating request
    });
    
    console.log('✅ Request created:', response.data.id);
    return response.data;
  } catch (error: any) {
    console.error('❌ Error creating request - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: POST');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const findNearestRequests = async (
  latitude: number,
  longitude: number,
  providerId: string, // Required - real provider ID
  maxDistance: number = 50,
  userRole?: 'needy' | 'provider', // Optional: user role to determine what to show
) => {
  if (!providerId) {
    throw new Error('Provider ID is required');
  }
  
  console.log('🔍 Finding nearest requests:', {
    providerId,
    userRole,
    realLocation: { latitude, longitude },
  });
  
  const params: any = { 
    latitude, 
    longitude, 
    maxDistance, 
    limit: 20, 
    providerId, // Always pass as providerId for backward compatibility
  };
  
  // If it's a needy user (check if userId starts with 'needy_'), also pass as needyId to include their own requests
  if (providerId.startsWith('needy_')) {
    params.needyId = providerId;
  }
  
  // Pass userRole if provided (important for providers to see accepted requests)
  if (userRole) {
    params.userRole = userRole;
  }
  
  const url = `${API_BASE_URL}${REQUEST_ENDPOINTS.NEAREST}`;
  
  try {
    const response = await axios.get(url, { params });
    console.log('✅ Found requests:', response.data.count);
    return response.data;
  } catch (error: any) {
    console.error('❌ Error finding nearest requests - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: GET');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const findNearestProviders = async (
  latitude: number,
  longitude: number,
  needyId: string, // Required - real needy ID
  maxDistance: number = 50,
) => {
  if (!needyId) {
    throw new Error('Needy ID is required');
  }
  
  console.log('🔍 Finding nearest providers for real needy:', {
    needyId,
    realLocation: { latitude, longitude },
  });
  
  const url = `${API_BASE_URL}${REQUEST_ENDPOINTS.PROVIDERS_NEAREST}`;
  
  try {
    const response = await axios.get(url, {
      params: {
        latitude,
        longitude,
        maxDistance,
        limit: 20,
        needyId, // Real needy ID
      },
    });
    
    console.log('✅ Found providers:', response.data.count);
    return response.data;
  } catch (error: any) {
    console.error('❌ Error finding nearest providers - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: GET');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const findNearestNeeders = async (
  latitude: number,
  longitude: number,
  providerId: string, // Required - real provider ID
  maxDistance: number = 50,
) => {
  if (!providerId) {
    throw new Error('Provider ID is required');
  }
  
  console.log('🔍 Finding nearest needers for real provider:', {
    providerId,
    realLocation: { latitude, longitude },
  });
  
  const url = `${API_BASE_URL}${REQUEST_ENDPOINTS.NEEDERS_NEAREST}`;
  
  try {
    const response = await axios.get(url, {
      params: {
        latitude,
        longitude,
        maxDistance,
        limit: 20,
        providerId, // Real provider ID
      },
    });
    
    console.log('✅ Found needers:', response.data.count);
    return response.data;
  } catch (error: any) {
    console.error('❌ Error finding nearest needers - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: GET');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const acceptRequest = async (requestId: string, providerId: string) => {
  const url = `${API_BASE_URL}${REQUEST_ENDPOINTS.ACCEPT(requestId)}`;
  console.log('✅ Accepting request:', { requestId, providerId });
  
  try {
    const response = await axios.post(url, { providerId });
    return response.data;
  } catch (error: any) {
    console.error('❌ Error accepting request - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: POST');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const updateLocation = async (
  userId: string,
  name: string,
  role: 'needy' | 'provider',
  latitude: number,
  longitude: number,
) => {
  const url = `${API_BASE_URL}${LOCATION_ENDPOINTS.UPDATE}`;
  console.log('📍 Updating location:', { userId, name, role, latitude, longitude });
  
  try {
    // IMPORTANT: Backend will preserve existing role if user is already registered
    // This role parameter is just for initial registration or if role is not set
    const response = await axios.post(url, {
      userId,
      name,
      role, // This will be preserved by backend if user already exists
      latitude,
      longitude,
      isAvailable: true, // Only active users are shown
    });
    
    return response.data;
  } catch (error: any) {
    console.error('❌ Error updating location - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: POST');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

// Quote APIs
export const createQuote = async (data: CreateQuoteData): Promise<Quote> => {
  const url = `${API_BASE_URL}${QUOTE_ENDPOINTS.CREATE}`;
  console.log('💰 Creating quote:', data);
  
  try {
    const response = await axios.post(url, data);
    console.log('✅ Quote created:', response.data.id);
    return response.data;
  } catch (error: any) {
    console.error('❌ Error creating quote - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: POST');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const getQuotesForRequest = async (requestId: string): Promise<Quote[]> => {
  const url = `${API_BASE_URL}${QUOTE_ENDPOINTS.GET_FOR_REQUEST(requestId)}`;
  
  try {
    const response = await axios.get(url);
    return response.data.quotes || [];
  } catch (error: any) {
    console.error('❌ Error getting quotes for request - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: GET');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const getQuotesForNeedy = async (needyId: string): Promise<Quote[]> => {
  const url = `${API_BASE_URL}${QUOTE_ENDPOINTS.GET_FOR_NEEDY(needyId)}`;
  
  try {
    const response = await axios.get(url);
    return response.data.quotes || [];
  } catch (error: any) {
    console.error('❌ Error getting quotes for needy - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: GET');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const acceptQuote = async (quoteId: string, needyId: string): Promise<Quote> => {
  const url = `${API_BASE_URL}${QUOTE_ENDPOINTS.ACCEPT(quoteId)}`;
  
  try {
    const response = await axios.post(url, { needyId });
    return response.data;
  } catch (error: any) {
    console.error('❌ Error accepting quote - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: POST');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const rejectQuote = async (quoteId: string, needyId: string): Promise<Quote> => {
  const url = `${API_BASE_URL}${QUOTE_ENDPOINTS.REJECT(quoteId)}`;
  
  try {
    const response = await axios.post(url, { needyId });
    return response.data;
  } catch (error: any) {
    console.error('❌ Error rejecting quote - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: POST');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

/**
 * Complete a request (mark as delivered)
 */
export const completeRequest = async (
  requestId: string,
  userId: string,
  userRole: 'needy' | 'provider',
): Promise<any> => {
  const url = `${API_BASE_URL}${REQUEST_ENDPOINTS.COMPLETE(requestId)}`;
  
  try {
    const response = await axios.post(url, { userId, userRole });
    return response.data;
  } catch (error: any) {
    console.error('❌ Error completing request - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: POST');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

/**
 * Get request history (completed requests)
 */
export const getRequestHistory = async (
  userId: string,
  userRole: 'needy' | 'provider',
): Promise<PetrolRequest[]> => {
  const url = `${API_BASE_URL}${REQUEST_ENDPOINTS.HISTORY}`;
  console.log('\n📜 ========== API CALL: getRequestHistory ==========');
  console.log(`📜 [${new Date().toISOString()}] Making API request`);
  console.log(`📜 Full URL: ${url}`);
  console.log(`📜 Query parameters:`);
  console.log(`📜   - userId: "${userId}"`);
  console.log(`📜   - userRole: "${userRole}"`);
  console.log(`📜 Request method: GET`);
  
  try {
    console.log(`📜 Sending request to backend...`);
    const response = await axios.get(url, { params: { userId, userRole } });
    
    console.log(`📜 ✅ Response received successfully!`);
    console.log(`📜 Response status: ${response.status} ${response.statusText}`);
    console.log(`📜 Response headers:`, response.headers);
    console.log(`📜 Response data structure:`, {
      hasHistory: !!response.data.history,
      historyLength: response.data.history?.length || 0,
      responseKeys: Object.keys(response.data),
      success: response.data.success,
      count: response.data.count,
    });
    
    console.log(`📜 Full response data:`, JSON.stringify(response.data, null, 2));
    
    // Handle response - check for error field first
    if (response.data.error && !response.data.history) {
      console.error(`❌ Backend returned error: ${response.data.error}`);
      console.error(`❌ This should not happen - backend should return empty array, not error`);
      // Return empty array instead of throwing error
      return [];
    }
    
    const history = response.data.history || [];
    console.log(`📜 Extracted history array: ${history.length} items`);
    
    if (history.length > 0) {
      console.log(`📜 History items preview:`);
      history.slice(0, 3).forEach((item: PetrolRequest, index: number) => {
        console.log(`📜   [${index + 1}] ${item.id} - ${item.status}`);
      });
      if (history.length > 3) {
        console.log(`📜   ... and ${history.length - 3} more items`);
      }
    } else {
      console.log(`📜 No history items found (empty array)`);
    }
    
    console.log(`📜 ✅ Returning ${history.length} history items to caller`);
    console.log(`📜 ========== END API CALL ==========\n`);
    return history;
  } catch (error: any) {
    console.error('\n❌ ========== API ERROR: getRequestHistory ==========');
    console.error(`❌ [${new Date().toISOString()}] Error occurred`);
    console.error(`❌ Request URL: ${url}`);
    console.error(`❌ Request params: userId="${userId}", userRole="${userRole}"`);
    
    if (axios.isAxiosError(error)) {
      console.error('❌ Error type: AxiosError');
      console.error(`❌ Error code: ${error.code || 'N/A'}`);
      console.error(`❌ Error message: ${error.message}`);
      
      if (error.response) {
        console.error('❌ Response received (error response):');
        console.error(`❌   Status: ${error.response.status} ${error.response.statusText}`);
        console.error(`❌   Data:`, JSON.stringify(error.response.data, null, 2));
        console.error(`❌   Headers:`, error.response.headers);
      } else if (error.request) {
        console.error('❌ No response received from server');
        console.error('❌ Request was made but no response received');
        console.error('❌ This usually means:');
        console.error('❌   - Backend server is not running');
        console.error('❌   - Network connectivity issue');
        console.error('❌   - CORS issue');
        console.error('❌   - Firewall blocking the request');
      }
      
      console.error('❌ Request config:', {
        url: error.config?.url,
        method: error.config?.method,
        params: error.config?.params,
        baseURL: error.config?.baseURL,
      });
    } else {
      console.error('❌ Error type: Non-Axios error');
      console.error('❌ Error:', error);
    }
    
    console.error(`❌ ========== END API ERROR ==========\n`);
    throw error;
  }
};

/**
 * Get active requests (pending, accepted, in_progress)
 */
export const getActiveRequests = async (
  userId: string,
  userRole: 'needy' | 'provider',
): Promise<PetrolRequest[]> => {
  const url = `${API_BASE_URL}${REQUEST_ENDPOINTS.ACTIVE}`;
  
  try {
    const response = await axios.get(url, { params: { userId, userRole } });
    return response.data.requests || [];
  } catch (error: any) {
    console.error('❌ Error getting active requests - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: GET');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

