import AsyncStorage from '@react-native-async-storage/async-storage';

export const USER_ID_KEY = 'fuelmate_user_id';
export const USER_NAME_KEY = 'fuelmate_user_name';

/**
 * Get the persistent user ID assigned by the backend during signup
 * IMPORTANT: This ID comes from the backend system, not generated locally
 * If no ID exists, user must register/login first
 */
export const getUserId = async (role: 'needy' | 'provider'): Promise<string> => {
  try {
    const existingId = await AsyncStorage.getItem(USER_ID_KEY);
    if (existingId) {
      return existingId;
    }
    
    // No ID found - user must register/login first
    // Don't generate a local ID - it must come from backend
    throw new Error('User ID not found. Please register or login first.');
  } catch (error: any) {
    console.error('Error getting user ID:', error);
    // Re-throw the error so caller knows registration is required
    throw error;
  }
};

/**
 * Save user name
 */
export const saveUserName = async (name: string): Promise<void> => {
  try {
    await AsyncStorage.setItem(USER_NAME_KEY, name);
  } catch (error) {
    console.error('Error saving user name:', error);
  }
};

/**
 * Get user name
 */
export const getUserName = async (): Promise<string | null> => {
  try {
    return await AsyncStorage.getItem(USER_NAME_KEY);
  } catch (error) {
    console.error('Error getting user name:', error);
    return null;
  }
};

/**
 * Clear user ID and name (for logout or role change)
 */
export const clearUserId = async (): Promise<void> => {
  try {
    await AsyncStorage.removeItem(USER_ID_KEY);
    await AsyncStorage.removeItem(USER_NAME_KEY);
  } catch (error) {
    console.error('Error clearing user ID:', error);
  }
};

