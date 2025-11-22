import { IsString, IsNotEmpty, IsEnum, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ description: 'User name', example: 'John Doe', minLength: 2 })
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  name: string;

  @ApiProperty({ description: 'User role', enum: ['needy', 'provider'], example: 'needy' })
  @IsEnum(['needy', 'provider'])
  role: 'needy' | 'provider';
}

