import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';
import * as Location from 'expo-location';
import AsyncStorage from '@react-native-async-storage/async-storage';

import RoleSelectionScreen from './src/screens/RoleSelectionScreen';
import ChatScreen from './src/screens/ChatScreen';
import RequestsScreen from './src/screens/RequestsScreen';
import NameInputScreen from './src/screens/NameInputScreen';
import HistoryScreen from './src/screens/HistoryScreen';
import { LocationContext } from './src/context/LocationContext';
import { UserRoleContext } from './src/context/UserRoleContext';
import { isUserRegistered } from './src/services/user-validation';

export type RootStackParamList = {
  RoleSelection: undefined;
  Chat: { requestId: string };
  Requests: undefined;
  NameInput: { role: 'needy' | 'provider' };
  History: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  const [location, setLocation] = useState<{ latitude: number; longitude: number } | null>(null);
  const [userRole, setUserRole] = useState<'needy' | 'provider' | null>(null);
  const [locationPermissionGranted, setLocationPermissionGranted] = useState(false);
  const [isCheckingRegistration, setIsCheckingRegistration] = useState(true);

  useEffect(() => {
    initializeApp();
  }, []);

  const initializeApp = async () => {
    // Request location permission
    await requestLocationPermission();
    
    // Check if user is registered in database
    await checkUserRegistration();
    
    // Load user role from storage
    await loadUserRole();
  };

  const checkUserRegistration = async () => {
    try {
      const registered = await isUserRegistered();
      if (!registered) {
        console.log('⚠️ User not registered in database - redirecting to registration');
        // Clear any invalid user data
        await AsyncStorage.removeItem('userRole');
      } else {
        console.log('✅ User is registered and validated');
      }
    } catch (error) {
      console.error('Error checking user registration:', error);
    } finally {
      setIsCheckingRegistration(false);
    }
  };

  const requestLocationPermission = async () => {
    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status === 'granted') {
        setLocationPermissionGranted(true);
        const currentLocation = await Location.getCurrentPositionAsync({});
        setLocation({
          latitude: currentLocation.coords.latitude,
          longitude: currentLocation.coords.longitude,
        });
      }
    } catch (error) {
      console.error('Error requesting location permission:', error);
    }
  };

  const loadUserRole = async () => {
    try {
      const savedRole = await AsyncStorage.getItem('userRole');
      if (savedRole) {
        setUserRole(savedRole as 'needy' | 'provider');
      }
    } catch (error) {
      console.error('Error loading user role:', error);
    }
  };

  const saveUserRole = async (role: 'needy' | 'provider') => {
    try {
      await AsyncStorage.setItem('userRole', role);
      setUserRole(role);
    } catch (error) {
      console.error('Error saving user role:', error);
    }
  };

  // Show loading while initializing (location permission and registration check)
  if (isCheckingRegistration || (!location && !locationPermissionGranted)) {
    return (
      <SafeAreaProvider>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#FF6B35" />
          <Text style={styles.loadingText}>Initializing FuelMate...</Text>
          <Text style={styles.loadingSubtext}>Checking user registration...</Text>
        </View>
      </SafeAreaProvider>
    );
  }

  return (
    <SafeAreaProvider>
      <UserRoleContext.Provider value={{ userRole, setUserRole: saveUserRole }}>
        <LocationContext.Provider value={location}>
          <NavigationContainer>
            <StatusBar style="auto" />
            <Stack.Navigator
              initialRouteName="RoleSelection"
              screenOptions={{
                headerStyle: {
                  backgroundColor: '#FF6B35',
                },
                headerTintColor: '#fff',
                headerTitleStyle: {
                  fontWeight: 'bold',
                },
              }}
            >
              <Stack.Screen
                name="RoleSelection"
                component={RoleSelectionScreen}
                options={{ headerShown: false }}
              />
              <Stack.Screen
                name="NameInput"
                component={NameInputScreen}
                options={{ title: 'Enter Your Name', headerBackTitle: 'Back' }}
              />
              <Stack.Screen
                name="Chat"
                component={ChatScreen}
                options={{ title: 'FuelMate Chat' }}
              />
              <Stack.Screen
                name="Requests"
                component={RequestsScreen}
                options={{ title: 'Nearby Requests' }}
              />
              <Stack.Screen
                name="History"
                component={HistoryScreen}
                options={{ title: 'Request History' }}
              />
            </Stack.Navigator>
          </NavigationContainer>
        </LocationContext.Provider>
      </UserRoleContext.Provider>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5F5F5',
  },
  loadingText: {
    marginTop: 20,
    fontSize: 16,
    color: '#666',
  },
  loadingSubtext: {
    marginTop: 10,
    fontSize: 14,
    color: '#999',
  },
});

