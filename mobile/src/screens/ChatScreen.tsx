import React, { useState, useContext, useRef, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  FlatList,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRoute, useNavigation, RouteProp } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { UserRoleContext } from '../context/UserRoleContext';
import { sendChatMessage, getChatMessages, getChatParticipants, markAsRead, ChatMessage, ChatParticipants } from '../services/chat-api';
import { getUserId, getUserName } from '../services/user-storage';
import { isUserRegistered } from '../services/user-validation';
import { RootStackParamList } from '../../App';

type ChatScreenRouteProp = RouteProp<RootStackParamList, 'Chat'>;
type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

interface Message {
  id: string;
  text: string;
  isUser: boolean;
  senderName: string;
  timestamp: Date;
}

const ChatScreen = () => {
  const route = useRoute<ChatScreenRouteProp>();
  const navigation = useNavigation<NavigationProp>();
  const { userRole } = useContext(UserRoleContext);
  const requestId = route.params?.requestId;

  const [messages, setMessages] = useState<Message[]>([]);
  const [inputText, setInputText] = useState('');
  const [loading, setLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const [participants, setParticipants] = useState<ChatParticipants | null>(null);
  const [error, setError] = useState<string | null>(null);
  const flatListRef = useRef<FlatList>(null);
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);

  // Load user ID and fetch initial data
  useEffect(() => {
    const initializeChat = async () => {
      try {
        // Check registration before proceeding
        const registered = await isUserRegistered();
        if (!registered) {
          console.log('⚠️ User not registered - redirecting to RoleSelection');
          Alert.alert('Registration Required', 'Please register first to use chat');
          navigation.navigate('RoleSelection');
          return;
        }

        if (!requestId) {
          console.error('❌ Chat initialization failed: requestId is missing');
          Alert.alert('Error', 'Request ID is required to open chat');
          navigation.goBack();
          return;
        }

        if (!userRole) {
          console.error('❌ Chat initialization failed: userRole is missing');
          Alert.alert('Error', 'User role not found');
          navigation.goBack();
          return;
        }

        const userId = await getUserId(userRole);
        console.log('💬 Chat initialized:', { requestId, userId, userRole });
        if (!userId) {
          throw new Error('Failed to get user ID');
        }
        setCurrentUserId(userId);

        // Fetch participants
        console.log('💬 Fetching chat participants for request:', requestId);
        const participantsData = await getChatParticipants(requestId);
        console.log('💬 Participants fetched:', participantsData);
        setParticipants(participantsData);

        // Fetch messages
        console.log('💬 Loading messages for request:', requestId);
        await loadMessages(userId);
        
        // Mark messages as read when opening chat
        try {
          console.log('💬 Marking messages as read for user:', userId);
          await markAsRead(requestId, userId);
          console.log('✅ Messages marked as read');
        } catch (err: any) {
          console.error('⚠️ Error marking as read (non-critical):', err.message || err);
          // Don't block chat if mark as read fails
        }
      } catch (err: any) {
        console.error('❌ Error initializing chat:', err);
        const errorMessage = err.response?.data?.message || err.message || 'Failed to initialize chat';
        setError(errorMessage);
        Alert.alert('Chat Error', errorMessage);
      }
    };

    if (requestId && userRole) {
      initializeChat();
    }
  }, [requestId, userRole, navigation]);

  // Poll for new messages every 3 seconds
  useEffect(() => {
    if (!currentUserId) return;

    const interval = setInterval(() => {
      loadMessages(currentUserId);
    }, 3000);

    return () => clearInterval(interval);
  }, [currentUserId, requestId]);

  const loadMessages = async (userId: string) => {
    if (!requestId) {
      console.error('❌ Cannot load messages: requestId is missing');
      return;
    }
    try {
      console.log('💬 Loading messages for request:', requestId, 'user:', userId);
      const chatMessages = await getChatMessages(requestId, userId);
      console.log('💬 Received', chatMessages.length, 'messages');
      
      // Convert ChatMessage to Message format
      const formattedMessages: Message[] = chatMessages.map((msg) => ({
        id: msg.id,
        text: msg.message,
        isUser: msg.senderId === userId,
        senderName: msg.senderName,
        timestamp: new Date(msg.createdAt),
      }));

      setMessages(formattedMessages);
      setError(null);

      // Scroll to bottom after loading
      setTimeout(() => {
        flatListRef.current?.scrollToEnd({ animated: true });
      }, 100);
    } catch (err: any) {
      console.error('❌ Error loading messages:', err);
      const errorMessage = err.response?.data?.message || err.message || 'Failed to load messages';
      if (!error) {
        setError(errorMessage);
      }
    }
  };

  const handleSend = async () => {
    if (!inputText.trim() || !requestId) {
      console.error('❌ Cannot send message - missing input or requestId');
      Alert.alert('Error', 'Please enter a message');
      return;
    }

    // Ensure we have a user ID - try to get it if missing
    let userIdToUse = currentUserId;
    if (!userIdToUse && userRole) {
      console.warn('⚠️ currentUserId is missing, attempting to fetch...');
      try {
        userIdToUse = await getUserId(userRole);
        if (userIdToUse) {
          setCurrentUserId(userIdToUse);
          console.log('✅ User ID retrieved:', userIdToUse);
        }
      } catch (err) {
        console.error('❌ Failed to get user ID:', err);
        Alert.alert('Error', 'User ID not found. Please try again.');
        return;
      }
    }

    if (!userIdToUse) {
      console.error('❌ Cannot send message - user ID is still missing');
      Alert.alert('Error', 'User ID not found. Please try again.');
      return;
    }

    const messageText = inputText.trim();
    console.log('💬 Sending message:', { 
      requestId, 
      senderId: userIdToUse, 
      messageLength: messageText.length,
      userRole 
    });
    setInputText('');
    setSending(true);

    try {
      console.log(`💬 Calling sendChatMessage API:`, { requestId, senderId: userIdToUse, message: messageText.substring(0, 50) });
      const sentMessage = await sendChatMessage(requestId, userIdToUse, messageText);
      console.log('✅ Message sent successfully:', sentMessage.id);
      
      // Reload messages to get the new one
      await loadMessages(userIdToUse);
    } catch (err: any) {
      console.error('❌ Error sending message:', err);
      console.error('❌ Error details:', {
        status: err.response?.status,
        data: err.response?.data,
        message: err.message,
      });
      const errorMessage = err.response?.data?.message || err.message || 'Failed to send message';
      Alert.alert('Send Error', errorMessage);
      setInputText(messageText); // Restore message text
    } finally {
      setSending(false);
    }
  };

  const getOtherParticipantName = (): string => {
    if (!participants || !currentUserId) return 'User';
    
    if (currentUserId === participants.needyId) {
      return participants.providerName || 'Provider';
    } else {
      return participants.needyName || 'Needy User';
    }
  };

  const renderMessage = ({ item }: { item: Message }) => (
    <View
      style={[
        styles.messageContainer,
        item.isUser ? styles.userMessage : styles.otherMessage,
      ]}
    >
      {!item.isUser && (
        <Text style={styles.senderName}>{item.senderName}</Text>
      )}
      <Text style={styles.messageText}>{item.text}</Text>
      <Text style={styles.timestamp}>
        {item.timestamp.toLocaleTimeString([], {
          hour: '2-digit',
          minute: '2-digit',
        })}
      </Text>
    </View>
  );

  if (error && messages.length === 0) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>⚠️ {error}</Text>
          <TouchableOpacity
            style={styles.retryButton}
            onPress={() => {
              if (currentUserId) {
                loadMessages(currentUserId);
              }
            }}
          >
            <Text style={styles.retryButtonText}>Retry</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      {participants && (
        <View style={styles.headerInfo}>
          <Text style={styles.headerText}>
            Chatting with: {getOtherParticipantName()}
          </Text>
          <Text style={styles.headerSubtext}>
            {userRole === 'provider' ? 'You can reply to the needy user' : 'You can reply to the provider'}
          </Text>
        </View>
      )}
      <KeyboardAvoidingView
        style={styles.container}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 90 : 0}
      >
        <FlatList
          ref={flatListRef}
          data={messages}
          renderItem={renderMessage}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.messagesList}
          onContentSizeChange={() => flatListRef.current?.scrollToEnd({ animated: true })}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Text style={styles.emptyText}>No messages yet. Start the conversation!</Text>
            </View>
          }
        />

        <View style={styles.inputContainer}>
          <TextInput
            style={styles.input}
            value={inputText}
            onChangeText={setInputText}
            placeholder="Type your message..."
            placeholderTextColor="#999"
            multiline
            maxLength={500}
            editable={!sending}
          />
          <TouchableOpacity
            style={[styles.sendButton, (sending || !inputText.trim()) && styles.sendButtonDisabled]}
            onPress={handleSend}
            disabled={sending || !inputText.trim()}
          >
            {sending ? (
              <ActivityIndicator color="#fff" size="small" />
            ) : (
              <Text style={styles.sendButtonText}>Send</Text>
            )}
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  headerInfo: {
    backgroundColor: '#fff',
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  headerText: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    fontWeight: '600',
  },
  headerSubtext: {
    fontSize: 12,
    color: '#999',
    textAlign: 'center',
    marginTop: 4,
  },
  messagesList: {
    padding: 15,
  },
  messageContainer: {
    maxWidth: '80%',
    padding: 12,
    borderRadius: 12,
    marginBottom: 10,
  },
  userMessage: {
    alignSelf: 'flex-end',
    backgroundColor: '#FF6B35',
  },
  otherMessage: {
    alignSelf: 'flex-start',
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  senderName: {
    fontSize: 12,
    fontWeight: '600',
    color: '#666',
    marginBottom: 4,
  },
  messageText: {
    fontSize: 16,
    color: '#333',
  },
  timestamp: {
    fontSize: 10,
    color: '#999',
    marginTop: 5,
  },
  inputContainer: {
    flexDirection: 'row',
    padding: 10,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
    alignItems: 'flex-end',
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    borderRadius: 20,
    paddingHorizontal: 15,
    paddingVertical: 10,
    maxHeight: 100,
    fontSize: 16,
    marginRight: 10,
  },
  sendButton: {
    backgroundColor: '#FF6B35',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    minWidth: 70,
  },
  sendButtonDisabled: {
    opacity: 0.5,
  },
  sendButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  errorText: {
    fontSize: 16,
    color: '#F44336',
    textAlign: 'center',
    marginBottom: 20,
  },
  retryButton: {
    backgroundColor: '#FF6B35',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
  },
  retryButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyText: {
    fontSize: 16,
    color: '#999',
    textAlign: 'center',
  },
});

export default ChatScreen;
