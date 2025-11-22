import { Injectable } from '@nestjs/common';
import { ChatMessage } from './chat.entity';
import { RequestsService } from '../requests/requests.service';

@Injectable()
export class ChatService {
  private messages: Map<string, ChatMessage[]> = new Map(); // requestId -> messages[]
  private lastReadMessage: Map<string, string> = new Map(); // "requestId_userId" -> lastReadMessageId
  private messageCounter = 0;

  constructor(private readonly requestsService: RequestsService) {}

  async sendMessage(
    requestId: string,
    senderId: string,
    senderName: string,
    senderRole: 'needy' | 'provider',
    message: string,
  ): Promise<ChatMessage> {
    console.log(`💬 sendMessage called: requestId=${requestId}, senderId=${senderId}, senderName=${senderName}, senderRole=${senderRole}, messageLength=${message?.length || 0}`);
    
    // Validate message
    if (!message || message.trim().length === 0) {
      console.error(`❌ Empty message provided`);
      throw new Error('Message cannot be empty');
    }

    // Verify that the request exists and is accepted
    const request = await this.requestsService.getRequest(requestId);
    if (!request) {
      console.error(`❌ Request not found: ${requestId}`);
      throw new Error(`Request not found: ${requestId}`);
    }

    console.log(`📋 Request found: id=${request.id}, status=${request.status}, needyId=${request.needyId}, acceptedBy=${request.acceptedBy || 'none'}`);

    // Only allow chat if request is accepted
    if (request.status !== 'accepted' && request.status !== 'in_progress') {
      console.error(`❌ Request status invalid for chat: ${request.status}`);
      throw new Error(`Chat is only available for accepted requests. Current status: ${request.status}`);
    }

    // Verify sender is either the needy or the provider who accepted
    const isNeedy = senderId === request.needyId;
    const isProvider = request.acceptedBy && senderId === request.acceptedBy;
    
    console.log(`🔍 Authorization check: senderId=${senderId}, isNeedy=${isNeedy}, isProvider=${isProvider}, request.needyId=${request.needyId}, request.acceptedBy=${request.acceptedBy || 'none'}`);
    
    if (!isNeedy && !isProvider) {
      console.error(`❌ Unauthorized sender: senderId=${senderId}, request.needyId=${request.needyId}, request.acceptedBy=${request.acceptedBy || 'none'}`);
      throw new Error(`Unauthorized: You are not part of this request. Request belongs to needy "${request.needyId}" and provider "${request.acceptedBy || 'none'}"`);
    }

    console.log(`✅ Authorization passed for sender ${senderId} (${isNeedy ? 'needy' : 'provider'})`);

    const chatMessage: ChatMessage = {
      id: `msg_${Date.now()}_${++this.messageCounter}`,
      requestId,
      senderId,
      senderName,
      senderRole,
      message: message.trim(),
      createdAt: new Date(),
    };

    // Get or create messages array for this request
    const requestMessages = this.messages.get(requestId) || [];
    requestMessages.push(chatMessage);
    this.messages.set(requestId, requestMessages);

    // Mark this message as read by sender (they just sent it)
    const senderReadKey = `${requestId}_${senderId}`;
    this.lastReadMessage.set(senderReadKey, chatMessage.id);

    console.log(`💬 Message sent successfully in request ${requestId} by ${senderName} (${senderRole}). Total messages: ${requestMessages.length}`);
    return chatMessage;
  }

  async getMessages(requestId: string, userId: string): Promise<ChatMessage[]> {
    console.log(`💬 getMessages called: requestId=${requestId}, userId=${userId}`);
    
    // Verify that the request exists
    const request = await this.requestsService.getRequest(requestId);
    if (!request) {
      console.error(`❌ Request not found: ${requestId}`);
      throw new Error(`Request not found: ${requestId}`);
    }

    console.log(`📋 Request found: id=${request.id}, status=${request.status}, needyId=${request.needyId}, acceptedBy=${request.acceptedBy || 'none'}`);

    // Verify user is part of this request
    const isNeedy = userId === request.needyId;
    const isProvider = request.acceptedBy && userId === request.acceptedBy;
    
    if (!isNeedy && !isProvider) {
      console.error(`❌ Unauthorized user: userId=${userId}, request.needyId=${request.needyId}, request.acceptedBy=${request.acceptedBy || 'none'}`);
      throw new Error(`Unauthorized: You are not part of this request`);
    }

    const messages = this.messages.get(requestId) || [];
    console.log(`💬 Returning ${messages.length} messages for request ${requestId}`);
    return messages.sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime());
  }

  /**
   * Mark messages as read for a user in a request
   * Marks all current messages as read
   */
  markAsRead(requestId: string, userId: string): void {
    const messages = this.messages.get(requestId) || [];
    if (messages.length === 0) {
      return;
    }

    // Find the latest message ID
    const latestMessage = messages[messages.length - 1];
    const readKey = `${requestId}_${userId}`;
    this.lastReadMessage.set(readKey, latestMessage.id);
    
    console.log(`✅ Marked messages as read for user ${userId} in request ${requestId} (last message: ${latestMessage.id})`);
  }

  /**
   * Get unread message count for a user in a request
   */
  async getUnreadCount(requestId: string, userId: string): Promise<number> {
    const request = await this.requestsService.getRequest(requestId);
    if (!request) {
      return 0;
    }

    // Verify user is part of this request
    if (userId !== request.needyId && userId !== request.acceptedBy) {
      return 0;
    }

    const messages = this.messages.get(requestId) || [];
    if (messages.length === 0) {
      return 0;
    }

    const readKey = `${requestId}_${userId}`;
    const lastReadMessageId = this.lastReadMessage.get(readKey);

    // If user has never read messages, all messages from others are unread
    if (!lastReadMessageId) {
      const unreadCount = messages.filter(msg => msg.senderId !== userId).length;
      console.log(`📊 Unread count for ${userId} in ${requestId}: ${unreadCount} (never read)`);
      return unreadCount;
    }

    // Find the index of the last read message
    const lastReadIndex = messages.findIndex(msg => msg.id === lastReadMessageId);
    
    // Count messages after the last read message that weren't sent by this user
    if (lastReadIndex === -1) {
      // Last read message not found, count all messages from others
      return messages.filter(msg => msg.senderId !== userId).length;
    }

    const unreadMessages = messages.slice(lastReadIndex + 1).filter(msg => msg.senderId !== userId);
    console.log(`📊 Unread count for ${userId} in ${requestId}: ${unreadMessages.length} (last read: ${lastReadMessageId})`);
    return unreadMessages.length;
  }

  /**
   * Get unread counts for all requests a user is part of
   */
  async getUnreadCountsForUser(userId: string): Promise<Map<string, number>> {
    const unreadCounts = new Map<string, number>();
    
    // Get all request IDs from messages map (these are requests with chat activity)
    const requestIds = Array.from(this.messages.keys());
    
    for (const requestId of requestIds) {
      try {
        const request = await this.requestsService.getRequest(requestId);
        if (request && (request.status === 'accepted' || request.status === 'in_progress')) {
          if (request.needyId === userId || request.acceptedBy === userId) {
            const count = await this.getUnreadCount(requestId, userId);
            if (count > 0) {
              unreadCounts.set(requestId, count);
              console.log(`📬 User ${userId} has ${count} unread messages in request ${requestId}`);
            }
          }
        }
      } catch (err) {
        // Request might not exist, skip it
        continue;
      }
    }
    
    return unreadCounts;
  }

  async getChatParticipants(requestId: string): Promise<{ needyId: string; providerId: string | null } | null> {
    const request = await this.requestsService.getRequest(requestId);
    if (!request) {
      return null;
    }

    return {
      needyId: request.needyId,
      providerId: request.acceptedBy || null,
    };
  }
}

