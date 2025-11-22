import { Module } from '@nestjs/common';
import { ChatController } from './chat.controller';
import { ChatService } from './chat.service';
import { RequestsModule } from '../requests/requests.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [RequestsModule, UsersModule],
  controllers: [ChatController],
  providers: [ChatService],
  exports: [ChatService],
})
export class ChatModule {}

