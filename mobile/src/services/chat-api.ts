import axios from 'axios';
import { API_BASE_URL } from '../config/api.config';
import { CHAT_ENDPOINTS } from '../config/api-endpoints';

export interface ChatMessage {
  id: string;
  requestId: string;
  senderId: string;
  senderName: string;
  senderRole: 'needy' | 'provider';
  message: string;
  createdAt: string;
}

export interface ChatParticipants {
  needyId: string;
  needyName: string;
  providerId: string | null;
  providerName: string | null;
}

export const sendChatMessage = async (
  requestId: string,
  senderId: string,
  message: string,
): Promise<ChatMessage> => {
  const url = `${API_BASE_URL}${CHAT_ENDPOINTS.SEND}`;
  
  try {
    const response = await axios.post<ChatMessage>(url, {
      requestId,
      senderId,
      message,
    });
    return response.data;
  } catch (error: any) {
    console.error('❌ Error sending chat message - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: POST');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const getChatMessages = async (
  requestId: string,
  userId: string,
): Promise<ChatMessage[]> => {
  const url = `${API_BASE_URL}${CHAT_ENDPOINTS.GET_MESSAGES(requestId)}?userId=${encodeURIComponent(userId)}`;
  
  try {
    const response = await axios.get<{ messages: ChatMessage[]; count: number }>(url);
    return response.data.messages;
  } catch (error: any) {
    console.error('❌ Error getting chat messages - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: GET');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const getChatParticipants = async (
  requestId: string,
): Promise<ChatParticipants> => {
  const url = `${API_BASE_URL}${CHAT_ENDPOINTS.GET_PARTICIPANTS(requestId)}`;
  
  try {
    const response = await axios.get<ChatParticipants>(url);
    return response.data;
  } catch (error: any) {
    console.error('❌ Error getting chat participants - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: GET');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export interface UnreadCountsResponse {
  success: boolean;
  unreadCounts: Record<string, number>;
  totalUnread: number;
}

export const getUnreadCounts = async (userId: string): Promise<UnreadCountsResponse> => {
  const url = `${API_BASE_URL}${CHAT_ENDPOINTS.GET_UNREAD_COUNTS(userId)}`;
  
  try {
    const response = await axios.get<UnreadCountsResponse>(url);
    return response.data;
  } catch (error: any) {
    console.error('❌ Error getting unread counts - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: GET');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

export const markAsRead = async (requestId: string, userId: string): Promise<void> => {
  const url = `${API_BASE_URL}${CHAT_ENDPOINTS.MARK_AS_READ(requestId)}`;
  
  try {
    await axios.post(url, { userId });
  } catch (error: any) {
    console.error('❌ Error marking as read - URL:', url);
    if (axios.isAxiosError(error)) {
      console.error('❌ Network Error - Method: POST');
      console.error('❌ Network Error - Code:', error.code);
      console.error('❌ Network Error - Message:', error.message);
      if (error.response) {
        console.error('❌ Network Error - Status:', error.response.status);
        console.error('❌ Network Error - Response:', error.response.data);
      }
    }
    throw error;
  }
};

