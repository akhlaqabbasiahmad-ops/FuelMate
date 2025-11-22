import AsyncStorage from '@react-native-async-storage/async-storage';
import { USER_ID_KEY, USER_NAME_KEY } from './user-storage';
import { getUserById } from './users-api';

/**
 * Check if user is registered and validated in the database
 * Returns true if user exists in database, false otherwise
 */
export const isUserRegistered = async (): Promise<boolean> => {
  try {
    const userId = await AsyncStorage.getItem(USER_ID_KEY);
    const userName = await AsyncStorage.getItem(USER_NAME_KEY);
    
    // Must have both ID and name stored locally
    if (!userId || !userName) {
      console.log('⚠️ User not registered: Missing ID or name in storage');
      return false;
    }
    
    // Verify user exists in database
    try {
      const user = await getUserById(userId);
      if (user && user.id === userId) {
        console.log('✅ User validated in database:', user.name);
        return true;
      }
    } catch (error: any) {
      // Network error or user not found - handle gracefully
      const isNetworkError = !error.response || error.code === 'ECONNREFUSED' || error.code === 'NETWORK_ERROR';
      
      if (isNetworkError) {
        // Network error - don't clear storage, just return false
        // User can retry when network is available
        console.warn('⚠️ Network error checking user registration - will retry later');
        return false;
      } else if (error.response?.status === 404) {
        // User not found in database (404) - clear invalid storage
        console.error('❌ User not found in database (404)');
        await AsyncStorage.removeItem(USER_ID_KEY);
        await AsyncStorage.removeItem(USER_NAME_KEY);
        return false;
      } else {
        // Other error - log but don't crash
        console.error('❌ Error checking user registration:', error.response?.status || error.message);
        return false;
      }
    }
    
    return false;
  } catch (error) {
    console.error('❌ Error checking user registration:', error);
    return false;
  }
};

/**
 * Get registered user info if available
 */
export const getRegisteredUser = async (): Promise<{ userId: string; userName: string } | null> => {
  try {
    const userId = await AsyncStorage.getItem(USER_ID_KEY);
    const userName = await AsyncStorage.getItem(USER_NAME_KEY);
    
    if (!userId || !userName) {
      return null;
    }
    
    // Verify user exists in database
    try {
      const user = await getUserById(userId);
      if (user && user.id === userId) {
        return { userId, userName };
      }
    } catch (error: any) {
      // Network error - don't clear storage, just return null
      const isNetworkError = !error.response || error.code === 'ECONNREFUSED' || error.code === 'NETWORK_ERROR';
      
      if (isNetworkError) {
        console.warn('⚠️ Network error getting user - will retry later');
        return null;
      } else if (error.response?.status === 404) {
        // User not found in database, clear storage
        await AsyncStorage.removeItem(USER_ID_KEY);
        await AsyncStorage.removeItem(USER_NAME_KEY);
        return null;
      } else {
        // Other error - return null without clearing
        console.error('❌ Error getting user:', error.response?.status || error.message);
        return null;
      }
    }
    
    return null;
  } catch (error) {
    console.error('❌ Error getting registered user:', error);
    return null;
  }
};

