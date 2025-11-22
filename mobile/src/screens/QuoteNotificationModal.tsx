import React from 'react';
import {
  View,
  Text,
  Modal,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
} from 'react-native';
import { Quote } from '../services/requests-api';

interface QuoteNotificationModalProps {
  visible: boolean;
  quotes: Quote[];
  onAcceptQuote: (quoteId: string) => void;
  onDismiss: () => void;
}

const QuoteNotificationModal: React.FC<QuoteNotificationModalProps> = ({
  visible,
  quotes,
  onAcceptQuote,
  onDismiss,
}) => {
  if (quotes.length === 0) {
    return null;
  }

  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onDismiss}
    >
      <View style={styles.modalOverlay}>
        <View style={styles.modalContent}>
          <View style={styles.header}>
            <Text style={styles.title}>💰 New Quotes Received!</Text>
            <TouchableOpacity onPress={onDismiss} style={styles.closeButton}>
              <Text style={styles.closeButtonText}>✕</Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.quotesList}>
            {quotes.map((quote) => (
              <View key={quote.id} style={styles.quoteCard}>
                <View style={styles.quoteHeader}>
                  <Text style={styles.quotePrice}>
                    {quote.currency} {quote.price.toLocaleString()}
                  </Text>
                  <Text style={styles.quoteTime}>
                    {quote.estimatedDeliveryTime} min
                  </Text>
                </View>
                {quote.message && (
                  <Text style={styles.quoteMessage}>{quote.message}</Text>
                )}
                {quote.status === 'pending' && (
                  <TouchableOpacity
                    style={styles.acceptButton}
                    onPress={() => {
                      onAcceptQuote(quote.id);
                      onDismiss();
                    }}
                  >
                    <Text style={styles.acceptButtonText}>Accept Quote</Text>
                  </TouchableOpacity>
                )}
                {quote.status === 'accepted' && (
                  <View style={styles.acceptedBadge}>
                    <Text style={styles.acceptedText}>✓ Accepted</Text>
                  </View>
                )}
              </View>
            ))}
          </ScrollView>

          <TouchableOpacity style={styles.dismissButton} onPress={onDismiss}>
            <Text style={styles.dismissButtonText}>View All Later</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderRadius: 20,
    width: '90%',
    maxHeight: '80%',
    padding: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
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
  quotesList: {
    maxHeight: 400,
  },
  quoteCard: {
    backgroundColor: '#f9f9f9',
    borderRadius: 12,
    padding: 15,
    marginBottom: 10,
    borderLeftWidth: 4,
    borderLeftColor: '#FF6B35',
  },
  quoteHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  quotePrice: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#FF6B35',
  },
  quoteTime: {
    fontSize: 14,
    color: '#666',
  },
  quoteMessage: {
    fontSize: 14,
    color: '#555',
    marginBottom: 10,
  },
  acceptButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 5,
  },
  acceptButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  acceptedBadge: {
    backgroundColor: '#4CAF50',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 6,
    alignSelf: 'flex-start',
  },
  acceptedText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  dismissButton: {
    marginTop: 15,
    padding: 12,
    alignItems: 'center',
  },
  dismissButtonText: {
    color: '#666',
    fontSize: 16,
  },
});

export default QuoteNotificationModal;

