import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SendMessageDto {
  @ApiProperty({ description: 'Request ID', example: 'req-123' })
  @IsString()
  @IsNotEmpty()
  requestId: string;

  @ApiProperty({ description: 'Sender user ID', example: 'user-456' })
  @IsString()
  @IsNotEmpty()
  senderId: string;

  @ApiProperty({ description: 'Message content', example: 'Hello, I can help you with fuel delivery' })
  @IsString()
  @IsNotEmpty()
  message: string;
}

