import React, { useState, useContext } from 'react';
import {
  View,
  Text,
  Modal,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
} from 'react-native';
import { createRequest } from '../services/requests-api';
import { LocationContext } from '../context/LocationContext';
import { getUserId } from '../services/user-storage';

interface CreateRequestModalProps {
  visible: boolean;
  onClose: () => void;
  onRequestCreated: () => void;
}

const CreateRequestModal: React.FC<CreateRequestModalProps> = ({
  visible,
  onClose,
  onRequestCreated,
}) => {
  const location = useContext(LocationContext);
  const [message, setMessage] = useState('');
  const [quantityLiters, setQuantityLiters] = useState('');
  const [urgency, setUrgency] = useState<'normal' | 'urgent'>('normal');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleCreateRequest = async () => {
    if (!message.trim()) {
      setError('Please enter a message describing your request');
      return;
    }

    if (!location) {
      setError('Location not available. Please enable location permissions.');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const userId = await getUserId('needy');
      
      const request = await createRequest({
        latitude: location.latitude,
        longitude: location.longitude,
        message: message.trim(),
        quantityLiters: quantityLiters ? parseFloat(quantityLiters) : undefined,
        urgency,
        userId,
        userRole: 'needy',
      });

      console.log('✅ Request created successfully:', request.id);
      
      // Reset form
      setMessage('');
      setQuantityLiters('');
      setUrgency('normal');
      
      Alert.alert(
        'Request Created!',
        `Your request has been created and will be visible to nearby providers.\n\nRequest ID: ${request.id}`,
        [
          {
            text: 'OK',
            onPress: () => {
              onRequestCreated();
              onClose();
            },
          },
        ]
      );
    } catch (err: any) {
      console.error('❌ Error creating request:', err);
      const errorMessage = err.response?.data?.message || err.message || 'Failed to create request';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    if (!loading) {
      setMessage('');
      setQuantityLiters('');
      setUrgency('normal');
      setError(null);
      onClose();
    }
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={handleClose}
    >
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.modalContainer}
      >
        <View style={styles.modalContent}>
          <View style={styles.header}>
            <Text style={styles.title}>Create Petrol Request</Text>
            <TouchableOpacity
              onPress={handleClose}
              disabled={loading}
              style={styles.closeButton}
            >
              <Text style={styles.closeButtonText}>✕</Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.form} showsVerticalScrollIndicator={false}>
            <View style={styles.inputGroup}>
              <Text style={styles.label}>Message *</Text>
              <TextInput
                style={styles.textInput}
                placeholder="Describe your request (e.g., Need 20 liters of petrol)"
                placeholderTextColor="#999"
                value={message}
                onChangeText={setMessage}
                multiline
                numberOfLines={3}
                editable={!loading}
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>Quantity (Liters)</Text>
              <TextInput
                style={styles.textInput}
                placeholder="Optional: Enter quantity in liters"
                placeholderTextColor="#999"
                value={quantityLiters}
                onChangeText={setQuantityLiters}
                keyboardType="numeric"
                editable={!loading}
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>Urgency</Text>
              <View style={styles.urgencyButtons}>
                <TouchableOpacity
                  style={[
                    styles.urgencyButton,
                    urgency === 'normal' && styles.urgencyButtonActive,
                  ]}
                  onPress={() => setUrgency('normal')}
                  disabled={loading}
                >
                  <Text
                    style={[
                      styles.urgencyButtonText,
                      urgency === 'normal' && styles.urgencyButtonTextActive,
                    ]}
                  >
                    Normal
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[
                    styles.urgencyButton,
                    urgency === 'urgent' && styles.urgencyButtonActive,
                  ]}
                  onPress={() => setUrgency('urgent')}
                  disabled={loading}
                >
                  <Text
                    style={[
                      styles.urgencyButtonText,
                      urgency === 'urgent' && styles.urgencyButtonTextActive,
                    ]}
                  >
                    Urgent
                  </Text>
                </TouchableOpacity>
              </View>
            </View>

            {error && (
              <View style={styles.errorContainer}>
                <Text style={styles.errorText}>{error}</Text>
              </View>
            )}

            <TouchableOpacity
              style={[styles.submitButton, loading && styles.submitButtonDisabled]}
              onPress={handleCreateRequest}
              disabled={loading || !message.trim()}
            >
              <Text style={styles.submitButtonText}>
                {loading ? 'Creating...' : 'Create Request'}
              </Text>
            </TouchableOpacity>
          </ScrollView>
        </View>
      </KeyboardAvoidingView>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalContainer: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: '90%',
    paddingBottom: Platform.OS === 'ios' ? 20 : 10,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  closeButton: {
    width: 30,
    height: 30,
    justifyContent: 'center',
    alignItems: 'center',
  },
  closeButtonText: {
    fontSize: 24,
    color: '#666',
  },
  form: {
    padding: 20,
  },
  inputGroup: {
    marginBottom: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },
  textInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: '#333',
    backgroundColor: '#f9f9f9',
    minHeight: 80,
    textAlignVertical: 'top',
  },
  urgencyButtons: {
    flexDirection: 'row',
    gap: 10,
  },
  urgencyButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#ddd',
    alignItems: 'center',
    backgroundColor: '#f9f9f9',
  },
  urgencyButtonActive: {
    borderColor: '#FF6B35',
    backgroundColor: '#FFF5F2',
  },
  urgencyButtonText: {
    fontSize: 16,
    color: '#666',
    fontWeight: '600',
  },
  urgencyButtonTextActive: {
    color: '#FF6B35',
  },
  errorContainer: {
    backgroundColor: '#FFEBEE',
    padding: 12,
    borderRadius: 8,
    marginBottom: 20,
  },
  errorText: {
    color: '#C62828',
    fontSize: 14,
  },
  submitButton: {
    backgroundColor: '#FF6B35',
    paddingVertical: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 10,
  },
  submitButtonDisabled: {
    backgroundColor: '#ccc',
  },
  submitButtonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
});

export default CreateRequestModal;

