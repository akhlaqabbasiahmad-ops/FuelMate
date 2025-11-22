import React, { useContext } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { UserRoleContext } from '../context/UserRoleContext';
import { LocationContext } from '../context/LocationContext';
import { clearUserId } from '../services/user-storage';

type RootStackParamList = {
  RoleSelection: undefined;
  Chat: { requestId: string };
  Requests: undefined;
  NameInput: { role: 'needy' | 'provider' };
};

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const RoleSelectionScreen = () => {
  const navigation = useNavigation<NavigationProp>();
  const { setUserRole } = useContext(UserRoleContext);
  const location = useContext(LocationContext);

  const handleRoleSelection = async (role: 'needy' | 'provider') => {
    if (!location) {
      alert('Please enable location permissions to continue.');
      return;
    }

    // Clear old user ID when changing role
    await clearUserId();
    
    // Navigate to name input screen first
    navigation.navigate('NameInput', { role });
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Welcome to FuelMate</Text>
        <Text style={styles.subtitle}>
          Select your role to get started
        </Text>

        <TouchableOpacity
          style={[styles.button, styles.needyButton]}
          onPress={() => handleRoleSelection('needy')}
        >
          <Text style={styles.buttonIcon}>⛽</Text>
          <Text style={styles.buttonTitle}>I Need Petrol</Text>
          <Text style={styles.buttonDescription}>
            Request petrol delivery to your location
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.providerButton]}
          onPress={() => handleRoleSelection('provider')}
        >
          <Text style={styles.buttonIcon}>🚗</Text>
          <Text style={styles.buttonTitle}>I Provide Petrol</Text>
          <Text style={styles.buttonDescription}>
            Deliver petrol to nearby users
          </Text>
        </TouchableOpacity>

        {!location && (
          <Text style={styles.warning}>
            ⚠️ Location permission required
          </Text>
        )}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 40,
    textAlign: 'center',
  },
  button: {
    width: '100%',
    backgroundColor: '#fff',
    borderRadius: 15,
    padding: 25,
    marginBottom: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  needyButton: {
    borderLeftWidth: 5,
    borderLeftColor: '#4CAF50',
  },
  providerButton: {
    borderLeftWidth: 5,
    borderLeftColor: '#FF6B35',
  },
  buttonIcon: {
    fontSize: 48,
    marginBottom: 10,
  },
  buttonTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  buttonDescription: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
  },
  warning: {
    marginTop: 20,
    color: '#FF6B35',
    fontSize: 14,
    textAlign: 'center',
  },
});

export default RoleSelectionScreen;

