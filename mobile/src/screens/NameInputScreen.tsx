import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { UserRoleContext } from '../context/UserRoleContext';
import { saveUserName, getUserName, USER_ID_KEY } from '../services/user-storage';
import { checkName, registerUser, getUserById } from '../services/users-api';

type RootStackParamList = {
  RoleSelection: undefined;
  Chat: { requestId: string };
  Requests: undefined;
  NameInput: { role: 'needy' | 'provider' };
};

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const NameInputScreen: React.FC<{ route: { params: { role: 'needy' | 'provider' } } }> = ({ route }) => {
  const navigation = useNavigation<NavigationProp>();
  const { setUserRole } = React.useContext(UserRoleContext);
  const [name, setName] = useState('');
  const [suggestedName, setSuggestedName] = useState<string | null>(null);
  const [isChecking, setIsChecking] = useState(false);
  const [isRegistering, setIsRegistering] = useState(false);
  const role = route.params.role;

  // Check for existing user on mount
  useEffect(() => {
    const checkExistingUser = async () => {
      try {
        const existingName = await getUserName();
        if (existingName) {
          // User already has a name, try to login
          setName(existingName);
          // Auto-login will be handled when user clicks continue
        }
      } catch (error) {
        console.log('No existing user found');
      }
    };
    checkExistingUser();
  }, []);

  // Check name availability as user types
  useEffect(() => {
    const checkNameAvailability = async () => {
      const trimmedName = name.trim();
      if (trimmedName.length >= 2) {
        setIsChecking(true);
        try {
          const result = await checkName(trimmedName);
          setSuggestedName(result.suggestedName);
        } catch (error: any) {
          console.error('Error checking name:', error);
        } finally {
          setIsChecking(false);
        }
      } else {
        setSuggestedName(null);
      }
    };

    const timeoutId = setTimeout(checkNameAvailability, 500); // Debounce
    return () => clearTimeout(timeoutId);
  }, [name]);

  const handleLogin = async (userName: string) => {
    try {
      setIsRegistering(true);
      const result = await registerUser(userName, role);
      
      // IMPORTANT: Use the user ID assigned by the backend system during signup/login
      // Save the backend-assigned user ID to AsyncStorage
      await AsyncStorage.setItem(USER_ID_KEY, result.user.id);
      
      // Save user name
      await saveUserName(result.user.name);
      
      Alert.alert(
        result.isNewUser ? 'Welcome!' : 'Welcome Back!',
        result.message,
        [
          {
            text: 'OK',
              onPress: () => {
                setUserRole(role);
                navigation.navigate('Requests');
              },
          },
        ]
      );
    } catch (error: any) {
      console.error('Login error:', error);
      Alert.alert('Error', error.response?.data?.message || 'Failed to login. Please try again.');
    } finally {
      setIsRegistering(false);
    }
  };

  const handleContinue = async () => {
    const trimmedName = name.trim();
    
    if (!trimmedName) {
      Alert.alert('Name Required', 'Please enter your name to continue.');
      return;
    }

    if (trimmedName.length < 2) {
      Alert.alert('Invalid Name', 'Name must be at least 2 characters long.');
      return;
    }

    try {
      setIsRegistering(true);
      
      // Register or login user
      const result = await registerUser(trimmedName, role);
      
      // IMPORTANT: Verify user was created in database before proceeding
      try {
        const verifiedUser = await getUserById(result.user.id);
        if (!verifiedUser || verifiedUser.id !== result.user.id) {
          throw new Error('User verification failed - user not found in database');
        }
        console.log('✅ User verified in database:', verifiedUser.name);
      } catch (verifyError: any) {
        console.error('❌ User verification failed:', verifyError);
        Alert.alert('Registration Error', 'Failed to verify user registration. Please try again.');
        return;
      }
      
      // IMPORTANT: Use the user ID assigned by the backend system during signup
      // Save the backend-assigned user ID to AsyncStorage
      await AsyncStorage.setItem(USER_ID_KEY, result.user.id);
      
      // Save the actual name (might be different if suggested)
      await saveUserName(result.user.name);
      
      console.log('✅ User registered and saved:', { id: result.user.id, name: result.user.name, role });
      
      // Show message if name was changed
      if (result.user.name !== trimmedName) {
        Alert.alert(
          'Name Updated',
          `The name "${trimmedName}" was already taken. Your name is now "${result.user.name}".`,
          [
            {
              text: 'OK',
              onPress: () => {
                setName(result.user.name);
                setUserRole(role);
                navigation.navigate('Requests');
              },
            },
          ]
        );
      } else {
        // Name was available, proceed
        setUserRole(role);
        navigation.navigate('Requests');
      }
    } catch (error: any) {
      console.error('Registration error:', error);
      Alert.alert('Error', error.response?.data?.message || 'Failed to register. Please try again.');
    } finally {
      setIsRegistering(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>
          {role === 'needy' ? '⛽' : '🚗'} Welcome!
        </Text>
        <Text style={styles.subtitle}>
          Please enter your name so others can see who you are
        </Text>

        <View style={styles.inputContainer}>
          <Text style={styles.label}>Your Name</Text>
          <TextInput
            style={styles.input}
            placeholder="Enter your name"
            value={name}
            onChangeText={setName}
            autoCapitalize="words"
            autoFocus
            maxLength={50}
            editable={!isRegistering}
          />
          {isChecking && (
            <View style={styles.checkingContainer}>
              <ActivityIndicator size="small" color="#FF6B35" />
              <Text style={styles.checkingText}>Checking availability...</Text>
            </View>
          )}
          {!isChecking && suggestedName && name.trim().length >= 2 && (
            <View style={styles.suggestionContainer}>
              {suggestedName !== name.trim().toLowerCase() ? (
                <>
                  <Text style={styles.suggestionText}>
                    "{name.trim()}" is already taken
                  </Text>
                  <Text style={styles.suggestedNameText}>
                    Suggested: "{suggestedName}"
                  </Text>
                </>
              ) : (
                <Text style={styles.availableText}>
                  ✓ "{name.trim()}" is available!
                </Text>
              )}
            </View>
          )}
        </View>

        <TouchableOpacity
          style={[
            styles.button,
            name.trim().length >= 2 && !isRegistering && styles.buttonActive,
            isRegistering && styles.buttonDisabled,
          ]}
          onPress={handleContinue}
          disabled={name.trim().length < 2 || isRegistering}
        >
          {isRegistering ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="small" color="#fff" />
              <Text style={styles.buttonText}>Registering...</Text>
            </View>
          ) : (
            <Text style={styles.buttonText}>Continue</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backButtonText}>← Go Back</Text>
        </TouchableOpacity>
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
  inputContainer: {
    marginBottom: 30,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 10,
  },
  input: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  checkingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
    gap: 8,
  },
  checkingText: {
    fontSize: 14,
    color: '#666',
  },
  suggestionContainer: {
    marginTop: 8,
    padding: 10,
    backgroundColor: '#FFF5F2',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#FFE0D6',
  },
  suggestionText: {
    fontSize: 14,
    color: '#FF6B35',
    fontWeight: '600',
  },
  suggestedNameText: {
    fontSize: 14,
    color: '#333',
    marginTop: 4,
    fontWeight: 'bold',
  },
  availableText: {
    fontSize: 14,
    color: '#4CAF50',
    fontWeight: '600',
  },
  button: {
    backgroundColor: '#ccc',
    borderRadius: 12,
    padding: 18,
    alignItems: 'center',
    marginBottom: 15,
  },
  buttonActive: {
    backgroundColor: '#FF6B35',
  },
  buttonDisabled: {
    backgroundColor: '#999',
  },
  loadingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  backButton: {
    alignItems: 'center',
    padding: 10,
  },
  backButtonText: {
    color: '#666',
    fontSize: 16,
  },
});

export default NameInputScreen;

