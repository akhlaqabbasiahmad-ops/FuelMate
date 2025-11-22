import React, { useState, useEffect, useContext, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFocusEffect, useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { UserRoleContext } from '../context/UserRoleContext';
import { getRequestHistory } from '../services/requests-api';
import type { PetrolRequest } from '../services/requests-api';
import { getUserId } from '../services/user-storage';
import { getUnreadCounts } from '../services/chat-api';
import { isUserRegistered } from '../services/user-validation';
import { RootStackParamList } from '../../App';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const HistoryScreen = () => {
  const navigation = useNavigation<NavigationProp>();
  const { userRole } = useContext(UserRoleContext);
  const [history, setHistory] = useState<PetrolRequest[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [unreadCounts, setUnreadCounts] = useState<Record<string, number>>({});
  const [lastFetchTime, setLastFetchTime] = useState<number>(0);
  const [isFetching, setIsFetching] = useState(false);

  // Check user registration on mount and redirect if not registered
  useEffect(() => {
    const checkRegistration = async () => {
      try {
        const registered = await isUserRegistered();
        if (!registered) {
          console.log('⚠️ User not registered - redirecting to RoleSelection');
          alert('Please register first to view history');
          navigation.navigate('RoleSelection');
        }
      } catch (error) {
        console.error('Error checking registration:', error);
        navigation.navigate('RoleSelection');
      }
    };
    
    checkRegistration();
  }, [navigation]);

  const fetchHistory = useCallback(async () => {
    console.log('\n📜 ========== FETCH HISTORY FUNCTION CALLED ==========');
    console.log(`📜 [${new Date().toISOString()}] fetchHistory() invoked`);
    console.log(`📜 Current userRole: ${userRole}`);
    console.log(`📜 Current history.length: ${history.length}`);
    console.log(`📜 Current loading state: ${loading}`);
    
    if (!userRole) {
      console.log('⚠️ No user role available - aborting fetch');
      return;
    }

    console.log('📜 Setting loading state to true...');
    setLoading(true);
    try {
      // IMPORTANT: Get the backend-assigned user ID from AsyncStorage
      // This ID was saved during signup/login and must be consistent
      console.log(`📜 Getting userId from AsyncStorage for role: ${userRole}`);
      const userId = await getUserId(userRole);
      console.log(`📜 ✅ Retrieved userId: "${userId}"`);
      console.log(`📜 User ID type: ${typeof userId}, length: ${userId.length}`);
      console.log(`📜 About to call getRequestHistory API with:`);
      console.log(`📜   - userId: "${userId}"`);
      console.log(`📜   - userRole: "${userRole}"`);
      
      const historyData = await getRequestHistory(userId, userRole);
      
      console.log(`📜 ✅ API call completed successfully!`);
      console.log(`📜 Received ${historyData.length} history items`);
      
      // Fetch unread message counts
      try {
        console.log(`📬 Fetching unread counts for userId: "${userId}"`);
        const unreadData = await getUnreadCounts(userId);
        console.log(`📬 ✅ Unread counts received:`, unreadData.unreadCounts);
        console.log(`📬 Total unread: ${unreadData.totalUnread}`);
        setUnreadCounts(unreadData.unreadCounts);
      } catch (err) {
        console.error('❌ Error fetching unread counts:', err);
      }
      
      console.log(`📜 History items details:`);
      if (historyData.length > 0) {
        historyData.forEach((r, index) => {
          console.log(`📜   [${index + 1}] Request ID: ${r.id}`);
          console.log(`📜        Status: ${r.status}`);
          console.log(`📜        NeedyId: ${r.needyId} (matches: ${r.needyId === userId})`);
          console.log(`📜        AcceptedBy: ${r.acceptedBy || 'none'} (matches: ${r.acceptedBy === userId})`);
        });
      } else {
        console.log(`⚠️ ⚠️ ⚠️ NO HISTORY ITEMS RETURNED ⚠️ ⚠️ ⚠️`);
        console.log(`⚠️ This could mean:`);
        console.log(`⚠️   - No requests have been accepted/completed yet`);
        console.log(`⚠️   - User ID mismatch (check backend logs for exact IDs)`);
        console.log(`⚠️   - Requests are still in 'pending' status`);
        console.log(`⚠️   - User ID format: "${userId}"`);
        console.log(`⚠️   - Check backend logs for: "📜 ========== HISTORY ENDPOINT CALLED =========="`);
      }
      
      console.log(`📜 Updating state with ${historyData.length} history items...`);
      setHistory(historyData);
      console.log(`📜 ✅ State updated successfully`);
    } catch (error: any) {
      console.error('\n❌ ========== ERROR FETCHING HISTORY ==========');
      console.error(`❌ [${new Date().toISOString()}] Error occurred`);
      console.error('❌ Error object:', error);
      console.error('❌ Error message:', error.message);
      console.error('❌ Error stack:', error.stack);
      
      if (error.response) {
        console.error('❌ Response status:', error.response.status);
        console.error('❌ Response data:', JSON.stringify(error.response.data, null, 2));
        console.error('❌ Response headers:', error.response.headers);
      } else if (error.request) {
        console.error('❌ No response received - request details:', error.request);
        console.error('❌ This usually means the backend is not reachable');
      }
      
      console.error('❌ Full error details:', {
        message: error.message,
        code: error.code,
        response: error.response?.data,
        status: error.response?.status,
        url: error.config?.url,
        method: error.config?.method,
      });
      
      alert(`Failed to load history: ${error.message || 'Unknown error'}`);
    } finally {
      console.log(`📜 Setting loading state to false...`);
      setLoading(false);
      setRefreshing(false);
      console.log(`📜 ✅ Fetch history completed`);
      console.log(`📜 ========== END FETCH HISTORY ==========\n`);
    }
  }, [userRole, history.length, loading]);

  // Refresh history when screen comes into focus (e.g., after accepting a quote)
  // This is the PRIMARY way history is fetched - runs every time screen is focused
  useFocusEffect(
    useCallback(() => {
      console.log('\n📜 ========== HISTORY SCREEN FOCUSED ==========');
      console.log(`📜 [${new Date().toISOString()}] Screen focus event triggered`);
      console.log(`📜 Current userRole: ${userRole}`);
      console.log(`📜 Current history.length: ${history.length}`);
      console.log(`📜 Last fetch time: ${lastFetchTime ? new Date(lastFetchTime).toISOString() : 'never'}`);
      console.log(`📜 Is currently fetching: ${isFetching}`);
      
      if (!userRole) {
        console.log('⚠️ ⚠️ ⚠️ No user role available yet - aborting');
        console.log('⚠️ This means UserRoleContext is not providing a role');
        return;
      }
      
      // Prevent concurrent fetches
      if (isFetching || loading) {
        console.log(`📜 ⏭️  SKIPPING FETCH - Already fetching`);
        return;
      }
      
      // Only fetch if we haven't fetched recently (within last 3 seconds)
      // This prevents multiple rapid API calls when navigating back and forth
      const now = Date.now();
      const timeSinceLastFetch = now - lastFetchTime;
      const FETCH_COOLDOWN = 3000; // 3 seconds (reduced from 5)
      
      console.log(`📜 Time since last fetch: ${timeSinceLastFetch}ms`);
      console.log(`📜 Cooldown period: ${FETCH_COOLDOWN}ms`);
      
      if (timeSinceLastFetch < FETCH_COOLDOWN) {
        console.log(`📜 ⏭️  SKIPPING FETCH - Cooldown active`);
        console.log(`📜    Reason: Last fetch was ${timeSinceLastFetch}ms ago (< ${FETCH_COOLDOWN}ms cooldown)`);
        console.log(`📜    Cached history items: ${history.length}`);
        return;
      }
      
      console.log(`📜 ✅ Proceeding with fetch...`);
      console.log(`📜    Reason: Cooldown expired (${timeSinceLastFetch}ms >= ${FETCH_COOLDOWN}ms)`);
      setLastFetchTime(now);
      setIsFetching(true);
      console.log(`📜 Calling fetchHistory() function...`);
      fetchHistory().finally(() => {
        setIsFetching(false);
      });
      
      // Poll for unread counts every 5 seconds while screen is focused
      const pollUnreadCounts = async () => {
        try {
          const userId = await getUserId(userRole);
          const unreadData = await getUnreadCounts(userId);
          console.log(`📬 Polling unread counts for ${userRole} (${userId}):`, unreadData.unreadCounts, `Total: ${unreadData.totalUnread}`);
          setUnreadCounts(unreadData.unreadCounts);
        } catch (err) {
          console.error('Error polling unread counts:', err);
        }
      };
      
      pollUnreadCounts();
      const interval = setInterval(pollUnreadCounts, 5000);
      
      return () => {
        console.log('📜 History screen unfocused, cleaning up...');
        clearInterval(interval);
      };
    }, [userRole, fetchHistory, lastFetchTime, history.length, isFetching, loading])
  );

  const onRefresh = () => {
    setRefreshing(true);
    fetchHistory();
  };

  const formatDate = (dateString?: string | Date) => {
    if (!dateString) return 'Unknown date';
    const date = typeof dateString === 'string' ? new Date(dateString) : dateString;
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const renderHistoryItem = ({ item }: { item: PetrolRequest }) => {
    const status = item.status || 'unknown';
    const statusColors: Record<string, { bg: string; text: string }> = {
      completed: { bg: '#4CAF50', text: '#fff' },
      accepted: { bg: '#2196F3', text: '#fff' },
      in_progress: { bg: '#FF9800', text: '#fff' },
      pending: { bg: '#9E9E9E', text: '#fff' },
      cancelled: { bg: '#F44336', text: '#fff' },
    };
    const statusConfig = statusColors[status] || { bg: '#757575', text: '#fff' };

    return (
      <View style={styles.historyCard}>
        <View style={styles.historyHeader}>
          <View style={styles.historyHeaderLeft}>
            <Text style={styles.historyTitle}>
              {userRole === 'provider' ? item.needyName || item.name || 'Needy User' : 'My Request'}
            </Text>
            <Text style={styles.historyMessage}>{item.message}</Text>
          </View>
          <View style={[styles.statusBadge, { backgroundColor: statusConfig.bg }]}>
            <Text style={[styles.statusText, { color: statusConfig.text }]}>
              {status === 'completed' ? '✓ Completed' : status === 'accepted' ? '✓ Accepted' : status.toUpperCase()}
            </Text>
          </View>
        </View>

        {item.quantityLiters && (
          <Text style={styles.historyDetail}>
            Quantity: {item.quantityLiters} liters
          </Text>
        )}

        <View style={styles.historyFooter}>
          <Text style={styles.historyDate}>
            {status === 'completed' ? 'Completed' : status === 'accepted' ? 'Accepted' : 'Updated'}: {formatDate(item.updatedAt || item.createdAt)}
          </Text>
          {item.urgency === 'urgent' && (
            <View style={styles.urgentBadge}>
              <Text style={styles.urgentText}>URGENT</Text>
            </View>
          )}
        </View>
        
        {(status === 'accepted' || status === 'in_progress') && (
          <TouchableOpacity
            style={styles.chatButton}
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
        )}
      </View>
    );
  };

  if (loading && history.length === 0) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centerContainer}>
          <ActivityIndicator size="large" color="#FF6B35" />
          <Text style={styles.loadingText}>Loading history...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Request History</Text>
        <Text style={styles.headerSubtitle}>
          {history.length} {history.length === 1 ? 'request' : 'requests'} (accepted/completed)
        </Text>
      </View>

      <FlatList
        data={history}
        renderItem={renderHistoryItem}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyIcon}>📋</Text>
            <Text style={styles.emptyText}>No history yet</Text>
            <Text style={styles.emptySubtext}>
              {userRole === 'provider' 
                ? 'Requests you have accepted will appear here. Accept a quote from a needy user to see it in history.'
                : 'Accepted and completed requests will appear here. Accept a quote from a provider to see it in history.'}
            </Text>
            <Text style={styles.debugText}>
              {userRole === 'provider' 
                ? `Provider ID: ${userRole ? 'Loading...' : 'Unknown'}`
                : `Needy ID: ${userRole ? 'Loading...' : 'Unknown'}`}
            </Text>
          </View>
        }
      />
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
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  headerSubtitle: {
    fontSize: 14,
    color: '#fff',
    opacity: 0.9,
    marginTop: 5,
  },
  list: {
    padding: 15,
  },
  historyCard: {
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
  historyHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 10,
  },
  historyHeaderLeft: {
    flex: 1,
  },
  historyTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  historyMessage: {
    fontSize: 14,
    color: '#666',
  },
  statusBadge: {
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: 6,
    marginLeft: 10,
  },
  statusText: {
    fontSize: 11,
    fontWeight: 'bold',
  },
  historyDetail: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  historyFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  historyDate: {
    fontSize: 12,
    color: '#999',
  },
  urgentBadge: {
    backgroundColor: '#FF6B35',
    paddingVertical: 2,
    paddingHorizontal: 8,
    borderRadius: 4,
  },
  urgentText: {
    color: '#fff',
    fontSize: 10,
    fontWeight: 'bold',
  },
  chatButton: {
    backgroundColor: '#2196F3',
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 8,
    marginTop: 10,
    alignItems: 'center',
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
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 60,
  },
  emptyIcon: {
    fontSize: 64,
    marginBottom: 20,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#666',
    marginBottom: 8,
  },
      emptySubtext: {
        fontSize: 14,
        color: '#999',
        textAlign: 'center',
        marginTop: 10,
        paddingHorizontal: 20,
      },
      debugText: {
        fontSize: 12,
        color: '#ccc',
        textAlign: 'center',
        marginTop: 10,
        fontFamily: 'monospace',
      },
    });

export default HistoryScreen;

