import React, { useState, useEffect, useContext } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  RefreshControl,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../App';
import { LocationContext } from '../context/LocationContext';
import { UserRoleContext } from '../context/UserRoleContext';
import {
  findNearestRequests,
  findNearestProviders,
  findNearestNeeders,
  acceptRequest,
  updateLocation,
  getQuotesForRequest,
  getQuotesForNeedy,
  acceptQuote,
  createQuote,
  createRequest,
  completeRequest,
  Quote,
} from '../services/requests-api';
import { getUserId, getUserName } from '../services/user-storage';
import { getUnreadCounts } from '../services/chat-api';
import { isUserRegistered } from '../services/user-validation';
import QuoteModal from './QuoteModal';
import QuoteNotificationModal from './QuoteNotificationModal';
import CreateRequestModal from './CreateRequestModal';

// Wrapper component to handle async providerId
const QuoteModalWrapper: React.FC<{
  visible: boolean;
  onClose: () => void;
  requestId: string;
  onQuoteSent: () => void;
}> = ({ visible, onClose, requestId, onQuoteSent }) => {
  const { userRole } = useContext(UserRoleContext);
  const [providerId, setProviderId] = useState<string>('');
  const [loading, setLoading] = useState(true);

  React.useEffect(() => {
    if (visible && userRole === 'provider') {
      setLoading(true);
      getUserId('provider')
        .then((id) => {
          console.log('📝 Retrieved provider ID for quote:', id);
          setProviderId(id);
          setLoading(false);
        })
        .catch((error) => {
          console.error('❌ Error getting provider ID:', error);
          setLoading(false);
        });
    } else if (visible) {
      console.warn('⚠️ QuoteModalWrapper: userRole is not provider:', userRole);
      setLoading(false);
    }
  }, [visible, userRole]);

  if (!visible) {
    return null;
  }

  if (loading) {
    return null; // Show nothing while loading
  }

  if (!providerId) {
    console.error('❌ Provider ID not available');
    return null;
  }

  return (
    <QuoteModal
      visible={visible}
      onClose={onClose}
      requestId={requestId}
      providerId={providerId}
      onQuoteSent={onQuoteSent}
    />
  );
};

interface PetrolRequest {
  id: string;
  needyId: string;
  name?: string; // User name (needyName from backend)
  latitude: number;
  longitude: number;
  message: string;
  quantityLiters?: number;
  urgency: 'normal' | 'urgent';
  status: string;
  createdAt?: string;
  distance?: number;
  type?: 'request' | 'needy' | 'provider'; // Type of item
}

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const RequestsScreen = () => {
  const navigation = useNavigation<NavigationProp>();
  const { userRole } = useContext(UserRoleContext);
  const location = useContext(LocationContext);
  const [requests, setRequests] = useState<PetrolRequest[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [selectedRequest, setSelectedRequest] = useState<PetrolRequest | null>(null);
  const [quoteModalVisible, setQuoteModalVisible] = useState(false);
  const [quotes, setQuotes] = useState<Map<string, Quote[]>>(new Map());
  
  // Quote notification for needers
  const [newQuotes, setNewQuotes] = useState<Quote[]>([]);
  const [quoteNotificationVisible, setQuoteNotificationVisible] = useState(false);
  const [lastQuoteCheck, setLastQuoteCheck] = useState<Date>(new Date());
  
  // Create request modal for needy users
  const [createRequestModalVisible, setCreateRequestModalVisible] = useState(false);
  
  // Unread message counts
  const [unreadCounts, setUnreadCounts] = useState<Record<string, number>>({});
  
  // Store current user ID for checking accepted requests
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);

  // Check user registration on mount and redirect if not registered
  useEffect(() => {
    const checkRegistration = async () => {
      try {
        const registered = await isUserRegistered();
        if (!registered) {
          console.log('⚠️ User not registered - redirecting to RoleSelection');
          Alert.alert('Registration Required', 'Please register first to use this feature');
          navigation.navigate('RoleSelection');
        }
      } catch (error) {
        console.error('Error checking registration:', error);
        navigation.navigate('RoleSelection');
      }
    };
    
    checkRegistration();
  }, [navigation]);

  const fetchRequests = async () => {
    if (!location) {
      console.log('⚠️ No location available');
      return;
    }

    setLoading(true);
    try {
      // Get persistent user ID and name
      const userId = await getUserId(userRole!);
      const userName = await getUserName();
      
      // Store userId for checking accepted requests
      setCurrentUserId(userId);
      
      if (!userName) {
        console.error('⚠️ User name not found');
        Alert.alert('Registration Required', 'Please register your name first');
        return;
      }

      console.log('👤 Using user ID:', userId, 'Name:', userName);

      // First, register user location with real coordinates and name
      await updateLocation(userId, userName, userRole!, location.latitude, location.longitude);
      console.log('📍 Location registered for:', userName, 'at', location.latitude, location.longitude);

      if (userRole === 'provider') {
        // Fetch both requests AND active needers
        console.log('🔍 Provider fetching requests and needers...');
        
        const [requestsResponse, needersResponse] = await Promise.all([
          findNearestRequests(
            location.latitude,
            location.longitude,
            userId,
            50, // 50km radius for testing
            userRole || 'provider', // Pass userRole so providers can see accepted requests
          ),
          findNearestNeeders(
            location.latitude,
            location.longitude,
            userId,
            50, // 50km radius for testing
          ),
        ]);
        
        console.log('✅ Received requests:', requestsResponse.requests?.length || 0);
        console.log('✅ Received needers:', needersResponse.needers?.length || 0);
        
        const requestsList = requestsResponse.requests || [];
        const needersList = needersResponse.needers || [];
        
        // Combine requests and needers (show needers who don't have requests yet)
        const allItems: PetrolRequest[] = [];
        
        // Add requests first - ensure type and status are set
        requestsList.forEach((req: any) => {
          console.log('📋 Adding request to list:', {
            id: req.id,
            status: req.status,
            role: req.role,
            needyId: req.needyId,
            acceptedBy: req.acceptedBy || 'none', // Log acceptedBy to debug
          });
          allItems.push({
            ...req,
            id: req.id,
            type: 'request', // Explicitly set type
            status: req.status || 'pending', // Ensure status is set, default to 'pending'
            acceptedBy: req.acceptedBy, // Ensure acceptedBy is included
          });
        });
        
        // Add needers who don't have requests
        needersList.forEach((needy: any) => {
          const hasRequest = requestsList.some((req: any) => req.needyId === needy.userId);
          if (!hasRequest) {
            allItems.push({
              id: `needy_${needy.userId}`,
              needyId: needy.userId,
              name: needy.name,
              latitude: needy.latitude,
              longitude: needy.longitude,
              message: `${needy.name} is looking for petrol`,
              urgency: 'normal',
              status: 'available',
              distance: needy.distance,
              type: 'needy',
            });
          }
        });
        
        setRequests(allItems);
        
        // Load quotes for requests only
        const quotesMap = new Map<string, Quote[]>();
        for (const req of requestsList) {
          try {
            const requestQuotes = await getQuotesForRequest(req.id);
            quotesMap.set(req.id, requestQuotes);
          } catch (err) {
            console.error('Error loading quotes for request:', req.id, err);
          }
        }
        setQuotes(quotesMap);
        
        // Fetch unread message counts
        try {
          const unreadData = await getUnreadCounts(userId);
          setUnreadCounts(unreadData.unreadCounts);
        } catch (err) {
          console.error('Error fetching unread counts:', err);
        }
      } else {
        // Fetch nearest providers AND requests for needers
        console.log('🔍 Needy fetching providers and requests...');
        
        const [providersResponse, requestsResponse] = await Promise.all([
          findNearestProviders(
            location.latitude,
            location.longitude,
            userId,
            50, // 50km radius for testing
          ),
          findNearestRequests(
            location.latitude,
            location.longitude,
            userId,
            50, // 50km radius for testing
            userRole || 'needy', // Pass userRole so needy users can see their own requests
          ),
        ]);
        
        console.log('✅ Received providers:', providersResponse.providers?.length || 0);
        console.log('✅ Received requests:', requestsResponse.requests?.length || 0);
        
        const providers = providersResponse.providers || [];
        const requestsList = requestsResponse.requests || [];
        
        // Combine providers and requests
        const allItems: PetrolRequest[] = [];
        
        // Add providers first
        providers.forEach((p: any) => {
          allItems.push({
            id: p.userId || `provider_${Date.now()}`,
            needyId: p.userId,
            name: p.name || 'Provider',
            latitude: p.latitude,
            longitude: p.longitude,
            message: `${p.name || 'Provider'} is available nearby`,
            status: p.isAvailable ? 'available' : 'busy',
            distance: p.distance,
            type: 'provider',
          });
        });
        
        // Add requests from providers (provider-created requests)
        requestsList.forEach((req: any) => {
          if (req.role === 'provider') {
            allItems.push({
              ...req,
              type: 'request',
            });
          }
        });
        
        // IMPORTANT: Add needy's own requests so they can see quotes on them
        requestsList.forEach((req: any) => {
          if (req.needyId === userId && req.role === 'needy') {
            console.log(`📋 Adding needy's own request to list: ${req.id}`);
            allItems.push({
              ...req,
              type: 'request',
            });
          }
        });
        
        setRequests(allItems);
        
        // Load quotes for needy's own requests (requests created by this needy user)
        const quotesMap = new Map<string, Quote[]>();
        
        // First, load all quotes for this needy user
        try {
          const allNeedyQuotes = await getQuotesForNeedy(userId);
          console.log(`💰 Total quotes for needy ${userId}: ${allNeedyQuotes.length}`);
          
          // Add quotes to map by request ID
          allNeedyQuotes.forEach(quote => {
            if (!quotesMap.has(quote.requestId)) {
              quotesMap.set(quote.requestId, []);
            }
            const existingQuotes = quotesMap.get(quote.requestId) || [];
            // Avoid duplicates
            if (!existingQuotes.find(q => q.id === quote.id)) {
              existingQuotes.push(quote);
              quotesMap.set(quote.requestId, existingQuotes);
            }
          });
        } catch (err) {
          console.error('Error loading all quotes for needy:', err);
        }
        
        // Also load quotes for each of needy's requests individually
        for (const req of requestsList) {
          // Check if this request belongs to the needy user
          if (req.needyId === userId && req.role === 'needy') {
            try {
              console.log(`📋 Loading quotes for needy's request: ${req.id}`);
              const requestQuotes = await getQuotesForRequest(req.id);
              console.log(`   Found ${requestQuotes.length} quotes for request ${req.id}`);
              
              // Merge with existing quotes
              const existingQuotes = quotesMap.get(req.id) || [];
              requestQuotes.forEach(quote => {
                if (!existingQuotes.find(q => q.id === quote.id)) {
                  existingQuotes.push(quote);
                }
              });
              quotesMap.set(req.id, existingQuotes);
            } catch (err) {
              console.error('Error loading quotes for request:', req.id, err);
            }
          }
        }
        
        console.log(`✅ Quotes map size: ${quotesMap.size} requests have quotes`);
        setQuotes(quotesMap);
        
        // Fetch unread message counts
        try {
          const unreadData = await getUnreadCounts(userId);
          setUnreadCounts(unreadData.unreadCounts);
        } catch (err) {
          console.error('Error fetching unread counts:', err);
        }
      }
    } catch (error: any) {
      console.error('❌ Error fetching requests:', error);
      if (error.response) {
        console.error('Error response:', error.response.data);
      }
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchRequests();
    // Refresh every 10 seconds
    const interval = setInterval(fetchRequests, 10000);
    return () => clearInterval(interval);
  }, [location, userRole]);

  // Poll for unread message counts every 5 seconds
  useEffect(() => {
    if (!userRole) return;

    const pollUnreadCounts = async () => {
      try {
        const userId = await getUserId(userRole);
        const unreadData = await getUnreadCounts(userId);
        console.log(`📬 Unread counts for ${userRole} (${userId}):`, unreadData.unreadCounts, `Total: ${unreadData.totalUnread}`);
        setUnreadCounts(unreadData.unreadCounts);
      } catch (err) {
        console.error('Error polling unread counts:', err);
      }
    };

    pollUnreadCounts();
    const interval = setInterval(pollUnreadCounts, 5000);
    return () => clearInterval(interval);
  }, [userRole]);

  // Poll for new quotes if user is needy
  useEffect(() => {
    if (userRole !== 'needy' || !location) return;

    const checkForNewQuotes = async () => {
      try {
        const userId = await getUserId('needy');
        const allQuotes = await getQuotesForNeedy(userId);
        
        // Filter for new pending quotes (created after last check)
        const newPendingQuotes = allQuotes.filter(
          (quote) =>
            quote.status === 'pending' &&
            new Date(quote.createdAt) > lastQuoteCheck
        );

        if (newPendingQuotes.length > 0) {
          console.log('💰 New quotes received:', newPendingQuotes.length);
          setNewQuotes((prev) => [...prev, ...newPendingQuotes]);
          setQuoteNotificationVisible(true);
          setLastQuoteCheck(new Date());
        }
      } catch (error) {
        console.error('Error checking for quotes:', error);
      }
    };

    // Check every 3 seconds for new quotes
    const quoteInterval = setInterval(checkForNewQuotes, 3000);
    
    // Initial check after 2 seconds
    const initialTimeout = setTimeout(checkForNewQuotes, 2000);

    return () => {
      clearInterval(quoteInterval);
      clearTimeout(initialTimeout);
    };
  }, [userRole, location, lastQuoteCheck]);

  const onRefresh = () => {
    setRefreshing(true);
    fetchRequests();
  };

  const handleAccept = async (requestId: string) => {
    try {
      if (!userRole) {
        Alert.alert('Error', 'User role not set');
        return;
      }
      const providerId = await getUserId('provider');
      await acceptRequest(requestId, providerId);
      fetchRequests(); // Refresh list
      Alert.alert('Success', 'Request accepted! Contact the needy user.');
    } catch (error: any) {
      console.error('Error accepting request:', error);
      Alert.alert('Error', `Failed to accept request: ${error.response?.data?.message || error.message}`);
    }
  };

  const handleSendQuote = async (requestId: string) => {
    const request = requests.find((r) => r.id === requestId);
    if (request) {
      setSelectedRequest(request);
      setQuoteModalVisible(true);
    }
  };

  const handleQuickQuote = async (requestId: string) => {
    try {
      if (!userRole || userRole !== 'provider') {
        Alert.alert('Error', 'Only providers can send quotes');
        return;
      }

      const request = requests.find((r) => r.id === requestId);
      if (!request) {
        Alert.alert('Error', 'Request not found');
        return;
      }

      const providerId = await getUserId('provider');
      
      // Calculate price: 390 per liter + 50 delivery charges
      const pricePerLiter = 390;
      const deliveryCharges = 50;
      const quantityLiters = request.quantityLiters || 10; // Default to 10 liters if not specified
      const totalPrice = (pricePerLiter * quantityLiters) + deliveryCharges;
      
      // Default delivery time: 30 minutes
      const estimatedDeliveryTime = 30;
      
      // Message explaining the quote
      const message = `I am giving you PKR ${pricePerLiter} per liter (${quantityLiters} liters) with delivery charges PKR ${deliveryCharges}. Total: PKR ${totalPrice.toLocaleString()}. I will deliver to your location.`;

      console.log('🚀 Sending quick quote:', {
        requestId,
        providerId,
        totalPrice,
        quantityLiters,
        deliveryCharges,
      });

      await createQuote({
        requestId,
        providerId,
        price: totalPrice,
        currency: 'PKR',
        estimatedDeliveryTime,
        message,
      });

      Alert.alert('Quote Sent', `Quick quote sent! Total: PKR ${totalPrice.toLocaleString()}\n(${pricePerLiter}/liter × ${quantityLiters}L + ${deliveryCharges} delivery)`);
      fetchRequests(); // Refresh to show the quote
    } catch (error: any) {
      console.error('Error sending quick quote:', error);
      Alert.alert('Error', `Failed to send quick quote: ${error.response?.data?.message || error.message}`);
    }
  };

  const handleQuoteSent = () => {
    fetchRequests(); // Refresh to show new quote
  };

  const handleAcceptQuote = async (quoteId: string) => {
    try {
      if (!userRole || userRole !== 'needy') {
        Alert.alert('Error', 'Only needers can accept quotes');
        return;
      }
      // IMPORTANT: Use the backend-assigned user ID from AsyncStorage
      // This ID must match the one used when creating requests and querying history
      const needyId = await getUserId('needy');
      console.log('✅ Accepting quote:', quoteId, 'for needy:', `"${needyId}"`);
      console.log('📋 Needy ID type:', typeof needyId, 'length:', needyId.length);
      
      const result = await acceptQuote(quoteId, needyId);
      console.log('✅ Quote accepted result:', result);
      console.log('📋 Request status after acceptance:', result.request?.status);
      console.log('📋 Request needyId:', result.request?.needyId || 'N/A');
      console.log('📋 Request acceptedBy:', result.request?.acceptedBy || 'N/A');
      
      // Verify ID consistency
      if (result.request && result.request.needyId !== needyId) {
        console.error(`⚠️ WARNING: Request needyId (${result.request.needyId}) doesn't match current userId (${needyId})`);
      }
      
      fetchRequests(); // Refresh list - accepted request will be hidden from providers
      Alert.alert('Quote Accepted', `Request status: ${result.request?.status || 'accepted'}\n\nRequest is now in your history.`);
      // Remove from new quotes
      setNewQuotes((prev) => prev.filter((q) => q.id !== quoteId));
    } catch (error: any) {
      console.error('Error accepting quote:', error);
      Alert.alert('Error', `Failed to accept quote: ${error.response?.data?.message || error.message}`);
    }
  };

  const handleCompleteRequest = async (requestId: string) => {
    try {
      if (!userRole) {
        Alert.alert('Error', 'User role not set');
        return;
      }
      const userId = await getUserId(userRole);
      
      Alert.alert(
        'Complete Request',
        'Mark this request as delivered/completed?',
        [
          { text: 'Cancel', style: 'cancel' },
          {
            text: 'Complete',
            onPress: async () => {
              try {
                await completeRequest(requestId, userId, userRole);
                Alert.alert('Success', 'Request completed! Moved to history.');
                fetchRequests(); // Refresh list
              } catch (error: any) {
                console.error('Error completing request:', error);
                Alert.alert('Error', `Failed to complete request: ${error.response?.data?.message || error.message}`);
              }
            },
          },
        ]
      );
    } catch (error: any) {
      console.error('Error completing request:', error);
      Alert.alert('Error', `Failed to complete request: ${error.message}`);
    }
  };

  const renderRequest = ({ item }: { item: PetrolRequest }) => {
    const requestQuotes = quotes.get(item.id) || [];
    const hasQuotes = requestQuotes.length > 0;
    
    // Check if this is needy's own request
    const isNeedyOwnRequest = userRole === 'needy' && item.type === 'request' && item.role === 'needy';
    
    // Check if provider has accepted this request (for showing chat buttons)
    const providerAcceptedThis = userRole === 'provider' && 
                                  currentUserId !== null && 
                                  item.acceptedBy === currentUserId;
    
    // Debug: Log item details for providers
    if (userRole === 'provider') {
      console.log('🔍 Rendering request item:', {
        id: item.id,
        status: item.status,
        type: item.type,
        role: (item as any).role,
        acceptedBy: item.acceptedBy || 'none',
        currentUserId: currentUserId || 'null',
        providerAcceptedThis: providerAcceptedThis,
        canShowButtons: item.status === 'pending' && (item.type === 'request' || !item.type),
      });
    }

    return (
      <View style={styles.requestCard}>
        <View style={styles.requestHeader}>
          <View style={styles.titleContainer}>
            <Text style={styles.userName}>
              {isNeedyOwnRequest ? 'My Request' : (item.name || (userRole === 'provider' ? 'Needy User' : 'Provider'))}
            </Text>
            <Text style={styles.requestMessage}>{item.message}</Text>
          </View>
          {item.urgency === 'urgent' && (
            <View style={styles.urgentBadge}>
              <Text style={styles.urgentText}>URGENT</Text>
            </View>
          )}
        </View>
        
        {item.quantityLiters && (
          <Text style={styles.detailText}>
            Quantity: {item.quantityLiters} liters
          </Text>
        )}
        
        {item.distance !== undefined && (
          <Text style={styles.detailText}>
            Distance: {item.distance.toFixed(2)} km away
          </Text>
        )}
        
        <Text style={styles.detailText}>
          Status: {item.status} | Type: {item.type || 'undefined'}
        </Text>

        {/* Show Quotes Section - For needy's own requests */}
        {isNeedyOwnRequest && hasQuotes && (
          <View style={styles.quotesSection}>
            <Text style={styles.quotesTitle}>
              💰 Quotes Received: ({requestQuotes.length})
            </Text>
            {requestQuotes.map((quote) => (
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
                    style={styles.acceptQuoteButton}
                    onPress={() => handleAcceptQuote(quote.id)}
                  >
                    <Text style={styles.acceptQuoteButtonText}>Accept Quote</Text>
                  </TouchableOpacity>
                )}
                {quote.status === 'accepted' && (
                  <View>
                    <View style={styles.acceptedBadge}>
                      <Text style={styles.acceptedText}>✓ Accepted</Text>
                    </View>
                    {item.status === 'accepted' && (
                      <View style={styles.actionButtonsRow}>
                        <TouchableOpacity
                          style={[styles.chatButton, { flex: 1, marginRight: 5 }]}
                          onPress={() => navigation.navigate('Chat', { requestId: item.id })}
                        >
                          <View style={styles.chatButtonContent}>
                            <Text style={styles.chatButtonText}>💬 Chat</Text>
                            {unreadCounts[item.id] > 0 && (
                              <View style={styles.notificationBadge}>
                                <Text style={styles.notificationBadgeText}>
                                  {unreadCounts[item.id] > 99 ? '99+' : unreadCounts[item.id]}
                                </Text>
                              </View>
                            )}
                          </View>
                        </TouchableOpacity>
                        <TouchableOpacity
                          style={[styles.completeButton, { flex: 1, marginLeft: 5 }]}
                          onPress={() => handleCompleteRequest(item.id)}
                        >
                          <Text style={styles.completeButtonText}>Mark as Delivered</Text>
                        </TouchableOpacity>
                      </View>
                    )}
                  </View>
                )}
              </View>
            ))}
          </View>
        )}

        {/* Show Quotes Section - For providers viewing requests */}
        {userRole === 'provider' && hasQuotes && (
          <View style={styles.quotesSection}>
            <Text style={styles.quotesTitle}>
              Quotes Sent: ({requestQuotes.length})
            </Text>
            {requestQuotes.map((quote) => (
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
                {quote.status === 'accepted' && (
                  <View>
                    <View style={styles.acceptedBadge}>
                      <Text style={styles.acceptedText}>✓ Accepted by Needy</Text>
                    </View>
                    {item.status === 'accepted' && (
                      <View style={styles.actionButtonsRow}>
                        <TouchableOpacity
                          style={[styles.chatButton, { flex: 1, marginRight: 5 }]}
                          onPress={() => navigation.navigate('Chat', { requestId: item.id })}
                        >
                          <View style={styles.chatButtonContent}>
                            <Text style={styles.chatButtonText}>💬 Chat</Text>
                            {unreadCounts[item.id] > 0 && (
                              <View style={styles.notificationBadge}>
                                <Text style={styles.notificationBadgeText}>
                                  {unreadCounts[item.id] > 99 ? '99+' : unreadCounts[item.id]}
                                </Text>
                              </View>
                            )}
                          </View>
                        </TouchableOpacity>
                        <TouchableOpacity
                          style={[styles.completeButton, { flex: 1, marginLeft: 5 }]}
                          onPress={() => handleCompleteRequest(item.id)}
                        >
                          <Text style={styles.completeButtonText}>Mark as Delivered</Text>
                        </TouchableOpacity>
                      </View>
                    )}
                  </View>
                )}
              </View>
            ))}
          </View>
        )}

        {/* Show message if needy's request has no quotes yet */}
        {isNeedyOwnRequest && !hasQuotes && item.status === 'pending' && (
          <Text style={styles.waitingText}>Waiting for quotes from providers...</Text>
        )}

        {/* Chat and Complete buttons for providers on accepted requests (even without quotes loaded) */}
        {/* Show buttons if: provider role AND (accepted/in_progress status) AND (request type) AND (acceptedBy exists and matches currentUserId) */}
        {userRole === 'provider' && 
         (item.status === 'accepted' || item.status === 'in_progress') && 
         item.type === 'request' && 
         item.acceptedBy && 
         currentUserId && 
         item.acceptedBy === currentUserId && (
          <View style={styles.actionButtonsRow}>
            <TouchableOpacity
              style={[styles.chatButton, { flex: 1, marginRight: 5 }]}
              onPress={() => navigation.navigate('Chat', { requestId: item.id })}
            >
              <View style={styles.chatButtonContent}>
                <Text style={styles.chatButtonText}>💬 Chat</Text>
                {unreadCounts[item.id] > 0 && (
                  <View style={styles.notificationBadge}>
                    <Text style={styles.notificationBadgeText}>
                      {unreadCounts[item.id] > 99 ? '99+' : unreadCounts[item.id]}
                    </Text>
                  </View>
                )}
              </View>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.completeButton, { flex: 1, marginLeft: 5 }]}
              onPress={() => handleCompleteRequest(item.id)}
            >
              <Text style={styles.completeButtonText}>Mark as Delivered</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Action Buttons - Show for providers on pending requests */}
        {/* Show buttons if: provider role AND (status is pending OR no status) AND (type is request OR no type) AND type is NOT needy */}
        {userRole === 'provider' && (item.status === 'pending' || !item.status) && item.type !== 'needy' && (
          <View style={styles.actionButtons}>
            <TouchableOpacity
              style={styles.quickQuoteButton}
              onPress={() => handleQuickQuote(item.id)}
            >
              <Text style={styles.quickQuoteButtonText}>Quick Quote</Text>
              <Text style={styles.quickQuoteSubtext}>390/L + 50 delivery</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.quoteButton}
              onPress={() => handleSendQuote(item.id)}
            >
              <Text style={styles.quoteButtonText}>Custom Quote</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.acceptButton}
              onPress={() => handleAccept(item.id)}
            >
              <Text style={styles.acceptButtonText}>Accept</Text>
            </TouchableOpacity>
          </View>
        )}
        
        {/* Debug info for providers - temporary to help diagnose */}
        {userRole === 'provider' && item.status && item.status !== 'pending' && (
          <Text style={styles.debugText}>⚠️ Status: {item.status} (buttons hidden - need 'pending')</Text>
        )}
        {userRole === 'provider' && item.type === 'needy' && (
          <Text style={styles.debugText}>ℹ️ Type: needy (no buttons - this is a needy user, not a request)</Text>
        )}

        {userRole === 'provider' && item.type === 'needy' && (
          <Text style={styles.infoText}>
            {item.name} is available. They haven't created a request yet.
          </Text>
        )}

        {userRole === 'needy' && item.status === 'pending' && !hasQuotes && (
          <Text style={styles.waitingText}>Waiting for quotes...</Text>
        )}
      </View>
    );
  };

  if (loading && requests.length === 0) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerContainer}>
          <ActivityIndicator size="large" color="#FF6B35" />
          <Text style={styles.loadingText}>Loading nearby requests...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <View style={styles.headerTopRow}>
          <View style={styles.headerTextContainer}>
            <Text style={styles.headerTitle}>
              {userRole === 'provider' ? 'Nearby Needers & Requests' : 'Nearby Providers'}
            </Text>
            <Text style={styles.headerSubtitle}>
              {requests.length} {userRole === 'provider' ? 'items' : 'providers'} found
            </Text>
          </View>
        </View>
        {/* Action Buttons Row - Always visible */}
        <View style={styles.headerButtonsRow}>
          {userRole === 'needy' && (
            <TouchableOpacity
              style={styles.createRequestButton}
              onPress={() => setCreateRequestModalVisible(true)}
            >
              <Text style={styles.createRequestButtonText}>+ Create Request</Text>
            </TouchableOpacity>
          )}
          <TouchableOpacity
            style={styles.historyButton}
            onPress={async () => {
              console.log('\n📋 ========== HISTORY BUTTON CLICKED ==========');
              console.log(`📋 [${new Date().toISOString()}] History button pressed`);
              console.log(`📋 Current userRole: ${userRole}`);
              console.log(`📋 Navigation object exists: ${!!navigation}`);
              console.log(`📋 Navigation type: ${typeof navigation}`);
              console.log(`📋 Navigation.navigate function exists: ${navigation && typeof navigation.navigate === 'function'}`);
              
              try {
                if (navigation && typeof navigation.navigate === 'function') {
                  console.log(`📋 Calling navigation.navigate('History')...`);
                  
                  // Get userId and log API endpoint details
                  try {
                    const { getUserId } = await import('../services/user-storage');
                    const { API_BASE_URL } = await import('../config/api.config');
                    const { REQUEST_ENDPOINTS } = await import('../config/api-endpoints');
                    const userId = await getUserId(userRole);
                    
                    // Log API endpoint details
                    console.log(`\n🌐 ========== API ENDPOINT INFO ==========`);
                    console.log(`🌐 Endpoint Path: ${REQUEST_ENDPOINTS.HISTORY}`);
                    console.log(`🌐 HTTP Method: GET`);
                    console.log(`🌐 Query Parameters:`);
                    console.log(`🌐   - userId: "${userId}"`);
                    console.log(`🌐   - userRole: "${userRole}"`);
                    console.log(`🌐 Base URL: ${API_BASE_URL}`);
                    console.log(`🌐 Full URL: ${API_BASE_URL}${REQUEST_ENDPOINTS.HISTORY}?userId=${encodeURIComponent(userId)}&userRole=${encodeURIComponent(userRole)}`);
                    console.log(`🌐 Expected Backend Log: "📜 ========== HISTORY ENDPOINT CALLED =========="`);
                    console.log(`🌐 =========================================\n`);
                  } catch (err) {
                    console.log(`📋 Could not retrieve userId for logging: ${err}`);
                  }
                  
                  navigation.navigate('History');
                  console.log(`📋 ✅ Navigation successful - History screen should now be focused`);
                  console.log(`📋 Expected behavior:`);
                  console.log(`📋   1. History screen will focus`);
                  console.log(`📋   2. useFocusEffect will trigger`);
                  console.log(`📋   3. fetchHistory() will be called`);
                  console.log(`📋   4. API endpoint GET /api/requests/history will be called`);
                  console.log(`📋   5. Backend will log: "📜 ========== HISTORY ENDPOINT CALLED =========="`);
                } else {
                  console.error('❌ Navigation not available');
                  console.error('❌ Navigation object:', navigation);
                  Alert.alert('Navigation Error', 'Navigation not ready. Please restart the app.');
                }
              } catch (error: any) {
                console.error('❌ Navigation error occurred:');
                console.error('❌ Error type:', typeof error);
                console.error('❌ Error message:', error.message);
                console.error('❌ Error stack:', error.stack);
                Alert.alert('Navigation Error', error.message || 'Unknown error');
              }
              console.log(`📋 ========== END HISTORY BUTTON CLICK ==========\n`);
            }}
            testID="history-button"
          >
            <Text style={styles.historyButtonText}>📋 History</Text>
          </TouchableOpacity>
        </View>
      </View>

      <FlatList
        data={requests}
        renderItem={renderRequest}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>
              {userRole === 'provider'
                ? 'No nearby requests found. Pull to refresh.'
                : 'No nearby providers found. Pull to refresh.'}
            </Text>
          </View>
        }
      />

      {/* Quote Modal for Providers */}
      {selectedRequest && userRole === 'provider' && (
        <QuoteModalWrapper
          visible={quoteModalVisible}
          onClose={() => {
            setQuoteModalVisible(false);
            setSelectedRequest(null);
          }}
          requestId={selectedRequest.id}
          onQuoteSent={handleQuoteSent}
        />
      )}

      {/* Quote Notification Modal for Needers */}
      {userRole === 'needy' && (
        <QuoteNotificationModal
          visible={quoteNotificationVisible}
          quotes={newQuotes}
          onAcceptQuote={handleAcceptQuote}
          onDismiss={() => {
            setQuoteNotificationVisible(false);
            setNewQuotes([]);
          }}
        />
      )}

      {/* Create Request Modal for Needy Users */}
      {userRole === 'needy' && (
        <CreateRequestModal
          visible={createRequestModalVisible}
          onClose={() => setCreateRequestModalVisible(false)}
          onRequestCreated={() => {
            fetchRequests(); // Refresh the list after creating request
          }}
        />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    color: '#666',
  },
  header: {
    backgroundColor: '#FF6B35',
    padding: 20,
    paddingBottom: 15,
  },
  headerTopRow: {
    marginBottom: 15,
  },
  headerTextContainer: {
    flex: 1,
  },
  headerTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#fff',
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#fff',
    opacity: 0.9,
    marginTop: 5,
  },
  headerButtonsRow: {
    flexDirection: 'row',
    gap: 10,
    alignItems: 'center',
    justifyContent: 'flex-end',
    width: '100%',
    marginTop: 10,
    paddingTop: 10,
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.2)',
  },
  createRequestButton: {
    backgroundColor: '#fff',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
  },
  createRequestButtonText: {
    color: '#FF6B35',
    fontSize: 13,
    fontWeight: 'bold',
  },
  historyButton: {
    backgroundColor: '#fff',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#fff',
    minWidth: 100,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  historyButtonText: {
    color: '#FF6B35',
    fontSize: 13,
    fontWeight: 'bold',
  },
  list: {
    padding: 15,
  },
  requestCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 15,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
    elevation: 3,
  },
  requestHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 10,
  },
  titleContainer: {
    flex: 1,
    marginRight: 10,
  },
  userName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FF6B35',
    marginBottom: 5,
  },
  requestMessage: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  urgentBadge: {
    backgroundColor: '#FF4444',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  urgentText: {
    color: '#fff',
    fontSize: 10,
    fontWeight: 'bold',
  },
  detailText: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
  },
  quotesSection: {
    marginTop: 15,
    paddingTop: 15,
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  quotesTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#666',
    marginBottom: 10,
  },
  quoteCard: {
    backgroundColor: '#f9f9f9',
    padding: 12,
    borderRadius: 8,
    marginBottom: 8,
  },
  quoteHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 5,
  },
  quotePrice: {
    fontSize: 18,
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
    marginTop: 5,
  },
  acceptQuoteButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 8,
    borderRadius: 6,
    marginTop: 8,
    alignItems: 'center',
  },
  acceptQuoteButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  acceptedBadge: {
    backgroundColor: '#4CAF50',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 6,
    marginTop: 8,
    alignSelf: 'flex-start',
  },
  acceptedText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  actionButtonsRow: {
    flexDirection: 'row',
    marginTop: 8,
  },
  chatButton: {
    backgroundColor: '#2196F3',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 8,
  },
  chatButtonContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  chatButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
    textAlign: 'center',
  },
  notificationBadge: {
    backgroundColor: '#FF6B35',
    borderRadius: 10,
    minWidth: 20,
    height: 20,
    paddingHorizontal: 6,
    marginLeft: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  notificationBadgeText: {
    color: '#fff',
    fontSize: 11,
    fontWeight: 'bold',
  },
  completeButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 8,
    marginTop: 8,
    alignItems: 'center',
  },
  completeButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  actionButtons: {
    flexDirection: 'row',
    gap: 5,
    marginTop: 10,
  },
  quickQuoteButton: {
    flex: 1.2,
    backgroundColor: '#4CAF50',
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  quickQuoteButtonText: {
    color: '#fff',
    fontSize: 13,
    fontWeight: 'bold',
  },
  quickQuoteSubtext: {
    color: '#fff',
    fontSize: 9,
    marginTop: 2,
    opacity: 0.9,
  },
  quoteButton: {
    flex: 1,
    backgroundColor: '#FF6B35',
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  quoteButtonText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  acceptButton: {
    flex: 0.8,
    backgroundColor: '#2196F3',
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  acceptButtonText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '600',
  },
  waitingText: {
    fontSize: 14,
    color: '#999',
    fontStyle: 'italic',
    marginTop: 10,
    textAlign: 'center',
  },
  debugText: {
    fontSize: 10,
    color: '#999',
    marginTop: 5,
    fontStyle: 'italic',
  },
  infoText: {
    fontSize: 14,
    color: '#666',
    marginTop: 10,
    textAlign: 'center',
    fontStyle: 'italic',
  },
  emptyContainer: {
    padding: 40,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: 16,
    color: '#999',
    textAlign: 'center',
  },
});

export default RequestsScreen;

