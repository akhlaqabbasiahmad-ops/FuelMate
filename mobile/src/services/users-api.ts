import axios from 'axios';
import { API_BASE_URL } from '../config/api.config';
import { USER_ENDPOINTS } from '../config/api-endpoints';

export interface CheckNameResponse {
  requestedName: string;
  isAvailable: boolean;
  suggestedName: string;
  message: string;
}

export interface RegisterResponse {
  success: boolean;
  user: {
    id: string;
    name: string;
    role: 'needy' | 'provider';
  };
  isNewUser: boolean;
  message: string;
}

export interface User {
  id: string;
  name: string;
  role: 'needy' | 'provider';
  createdAt?: string;
  lastLoginAt?: string;
}

/**
 * Check if a name is available and get suggestions
 */
export const checkName = async (name: string): Promise<CheckNameResponse> => {
  const url = `${API_BASE_URL}${USER_ENDPOINTS.CHECK_NAME}`;
  
  try {
    const response = await axios.post(url, { name: name.trim() });
    return response.data;
  } catch (error: any) {
    console.error('❌ Error checking name - URL:', url);
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
 * Register a new user or login existing user
 */
export const registerUser = async (
  name: string,
  role: 'needy' | 'provider',
): Promise<RegisterResponse> => {
  const url = `${API_BASE_URL}${USER_ENDPOINTS.REGISTER}`;
  
  try {
    const response = await axios.post(url, {
      name: name.trim(),
      role,
    });
    return response.data;
  } catch (error: any) {
    console.error('❌ Error registering user - URL:', url);
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
 * Get user by ID
 */
export const getUserById = async (userId: string): Promise<User> => {
  const url = `${API_BASE_URL}${USER_ENDPOINTS.GET_BY_ID(userId)}`;
  
  try {
    const response = await axios.get(url);
    return response.data.user;
  } catch (error: any) {
    console.error('❌ Error getting user by ID - URL:', url);
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

