import { Controller, Post, Get, Body, Param, Query, HttpException, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBody } from '@nestjs/swagger';
import { ChatService } from './chat.service';
import { SendMessageDto } from './dto/send-message.dto';
import { UsersService } from '../users/users.service';

@ApiTags('chat')
@Controller('api/chat')
export class ChatController {
  constructor(
    private readonly chatService: ChatService,
    private readonly usersService: UsersService,
  ) {}

  @Post('send')
  @ApiOperation({ summary: 'Send a chat message' })
  @ApiResponse({ status: 201, description: 'Message sent successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiBody({ type: SendMessageDto })
  async sendMessage(@Body() dto: SendMessageDto) {
    try {
      console.log('💬 Chat send request received:', { 
        requestId: dto.requestId, 
        senderId: dto.senderId, 
        messageLength: dto.message?.length,
        dtoKeys: Object.keys(dto),
        dtoValues: Object.values(dto),
      });
      
      // Validate required fields
      if (!dto.senderId) {
        console.error('❌ senderId is missing from request body');
        throw new HttpException('senderId is required', HttpStatus.BAD_REQUEST);
      }
      if (!dto.requestId) {
        console.error('❌ requestId is missing from request body');
        throw new HttpException('requestId is required', HttpStatus.BAD_REQUEST);
      }
      if (!dto.message) {
        console.error('❌ message is missing from request body');
        throw new HttpException('message is required', HttpStatus.BAD_REQUEST);
      }
      
      // Get sender info
      const sender = await this.usersService.getUserById(dto.senderId);
      if (!sender) {
        console.error(`❌ User not found: ${dto.senderId}`);
        throw new HttpException(`User not found: ${dto.senderId}`, HttpStatus.NOT_FOUND);
      }

      console.log('✅ Sender found:', { id: sender.id, name: sender.name, role: sender.role });

      const message = await this.chatService.sendMessage(
        dto.requestId,
        dto.senderId,
        sender.name,
        sender.role,
        dto.message,
      );

      return {
        ...message,
        message: 'Message sent successfully',
      };
    } catch (error: any) {
      console.error('❌ Error in sendMessage:', error);
      if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        error.message || 'Failed to send message',
        error.status || HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Get('messages/:requestId')
  @ApiOperation({ summary: 'Get all messages for a request' })
  @ApiParam({ name: 'requestId', description: 'Request ID' })
  @ApiResponse({ status: 200, description: 'List of messages' })
  @ApiResponse({ status: 404, description: 'Request not found' })
  async getMessages(
    @Param('requestId') requestId: string,
    @Query('userId') userId: string,
  ) {
    try {
      if (!userId) {
        throw new HttpException('userId query parameter is required', HttpStatus.BAD_REQUEST);
      }

      const messages = await this.chatService.getMessages(requestId, userId);
      return {
        messages,
        count: messages.length,
      };
    } catch (error: any) {
      console.error('❌ Error in getMessages:', error);
      if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        error.message || 'Failed to get messages',
        error.status || HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Get('participants/:requestId')
  async getParticipants(@Param('requestId') requestId: string) {
    try {
      const participants = await this.chatService.getChatParticipants(requestId);
      if (!participants) {
        throw new HttpException(`Request not found: ${requestId}`, HttpStatus.NOT_FOUND);
      }

      // Get user names
      const needy = await this.usersService.getUserById(participants.needyId);
      const provider = participants.providerId
        ? await this.usersService.getUserById(participants.providerId)
        : null;

      return {
        needyId: participants.needyId,
        needyName: needy?.name || 'Unknown',
        providerId: participants.providerId,
        providerName: provider?.name || null,
      };
    } catch (error: any) {
      console.error('❌ Error in getParticipants:', error);
      if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        error.message || 'Failed to get participants',
        error.status || HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Get('unread-counts/:userId')
  async getUnreadCounts(@Param('userId') userId: string) {
    try {
      const unreadCounts = await this.chatService.getUnreadCountsForUser(userId);
      const counts: Record<string, number> = {};
      unreadCounts.forEach((count, requestId) => {
        counts[requestId] = count;
      });
      return {
        success: true,
        unreadCounts: counts,
        totalUnread: Array.from(unreadCounts.values()).reduce((sum, count) => sum + count, 0),
      };
    } catch (error: any) {
      console.error('❌ Error in getUnreadCounts:', error);
      throw new HttpException(
        error.message || 'Failed to get unread counts',
        error.status || HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Post('mark-read/:requestId')
  async markAsRead(
    @Param('requestId') requestId: string,
    @Body('userId') userId: string,
  ) {
    try {
      if (!userId) {
        throw new HttpException('userId is required', HttpStatus.BAD_REQUEST);
      }
      this.chatService.markAsRead(requestId, userId);
      return {
        success: true,
        message: 'Messages marked as read',
      };
    } catch (error: any) {
      console.error('❌ Error in markAsRead:', error);
      if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        error.message || 'Failed to mark as read',
        error.status || HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
}

