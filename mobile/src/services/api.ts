import axios from 'axios';
import { API_BASE_URL } from '../config/api.config';
import { HEALTH_ENDPOINTS } from '../config/api-endpoints';

// Test connection function - uses health endpoint
export const testConnection = async (): Promise<boolean> => {
  try {
    const healthUrl = `${API_BASE_URL}${HEALTH_ENDPOINTS.CHECK}`;
    console.log('🔗 Testing connection to:', healthUrl);
    
    const response = await axios.get(healthUrl, {
      timeout: 5000,
      validateStatus: () => true, // Don't throw on any status
    });
    
    console.log('🔗 Health check response:', {
      status: response.status,
      data: response.data,
    });
    
    return response.status === 200 && response.data?.status === 'ok';
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const requestUrl = error.config?.url || healthUrl;
      const fullUrl = requestUrl.startsWith('http') ? requestUrl : `${API_BASE_URL}${requestUrl}`;
      console.error('🔗 Connection test failed - URL:', fullUrl);
      console.error('🔗 Connection test failed:', {
        message: error.message,
        code: error.code,
        url: fullUrl,
      });
    } else {
      console.error('🔗 Connection test failed - URL:', healthUrl);
      console.error('🔗 Connection test failed:', error);
    }
    return false;
  }
};

