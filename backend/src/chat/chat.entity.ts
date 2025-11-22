export interface ChatMessage {
  id: string;
  requestId: string;
  senderId: string;
  senderName: string;
  senderRole: 'needy' | 'provider';
  message: string;
  createdAt: Date;
}

