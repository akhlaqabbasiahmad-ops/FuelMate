import React, { useState } from 'react';
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
} from 'react-native';
import { createQuote } from '../services/requests-api';

interface QuoteModalProps {
  visible: boolean;
  onClose: () => void;
  requestId: string;
  providerId: string;
  onQuoteSent: () => void;
}

const QuoteModal: React.FC<QuoteModalProps> = ({
  visible,
  onClose,
  requestId,
  providerId,
  onQuoteSent,
}) => {
  const [price, setPrice] = useState('');
  const [deliveryTime, setDeliveryTime] = useState('');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSendQuote = async () => {
    if (!price || !deliveryTime) {
      setError('Please fill all required fields');
      return;
    }

    if (!providerId) {
      setError('Provider ID not available. Please try again.');
      console.error('❌ Provider ID missing when sending quote');
      return;
    }

    const priceNum = parseFloat(price);
    const timeNum = parseInt(deliveryTime, 10);

    if (isNaN(priceNum) || priceNum <= 0) {
      setError('Please enter a valid price');
      return;
    }

    if (isNaN(timeNum) || timeNum <= 0) {
      setError('Please enter valid delivery time');
      return;
    }

    setLoading(true);
    setError(null);

    console.log('📤 Sending quote:', {
      requestId,
      providerId,
      price: priceNum,
      estimatedDeliveryTime: timeNum,
    });

    try {
      await createQuote({
        requestId,
        providerId,
        price: priceNum,
        currency: 'PKR', // Default currency
        estimatedDeliveryTime: timeNum,
        message: message || undefined,
      });

      console.log('✅ Quote sent successfully');
      // Reset form
      setPrice('');
      setDeliveryTime('');
      setMessage('');
      onQuoteSent();
      onClose();
    } catch (err: any) {
      console.error('❌ Error sending quote:', err);
      const errorMessage = err.response?.data?.message || err.message || 'Failed to send quote';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={styles.modalContainer}
      >
        <View style={styles.modalContent}>
          <View style={styles.header}>
            <Text style={styles.title}>Send Quote</Text>
            <TouchableOpacity onPress={onClose} style={styles.closeButton}>
              <Text style={styles.closeButtonText}>✕</Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.form}>
            {error && (
              <View style={styles.errorContainer}>
                <Text style={styles.errorText}>{error}</Text>
              </View>
            )}

            <View style={styles.inputGroup}>
              <Text style={styles.label}>Price (PKR) *</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter price"
                value={price}
                onChangeText={setPrice}
                keyboardType="numeric"
                editable={!loading}
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>Estimated Delivery Time (minutes) *</Text>
              <TextInput
                style={styles.input}
                placeholder="e.g., 30"
                value={deliveryTime}
                onChangeText={setDeliveryTime}
                keyboardType="numeric"
                editable={!loading}
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>Message (Optional)</Text>
              <TextInput
                style={[styles.input, styles.textArea]}
                placeholder="Add a message..."
                value={message}
                onChangeText={setMessage}
                multiline
                numberOfLines={4}
                editable={!loading}
              />
            </View>

            <TouchableOpacity
              style={[styles.sendButton, loading && styles.sendButtonDisabled]}
              onPress={handleSendQuote}
              disabled={loading}
            >
              <Text style={styles.sendButtonText}>
                {loading ? 'Sending...' : 'Send Quote'}
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
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    maxHeight: '80%',
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
  errorContainer: {
    backgroundColor: '#fee',
    padding: 10,
    borderRadius: 8,
    marginBottom: 15,
  },
  errorText: {
    color: '#c00',
    fontSize: 14,
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
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    backgroundColor: '#fff',
  },
  textArea: {
    height: 100,
    textAlignVertical: 'top',
  },
  sendButton: {
    backgroundColor: '#FF6B35',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 10,
  },
  sendButtonDisabled: {
    opacity: 0.6,
  },
  sendButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default QuoteModal;

