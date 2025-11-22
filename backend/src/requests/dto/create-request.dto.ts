import { IsNumber, IsString, IsOptional, IsEnum, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateRequestDto {
  @ApiProperty({ description: 'User ID from mobile app', example: 'user-123' })
  @IsString()
  userId: string; // Required - real user ID from mobile app

  @ApiPropertyOptional({ description: 'Role of user creating request', enum: ['needy', 'provider'] })
  @IsString()
  @IsOptional()
  userRole?: 'needy' | 'provider'; // Role of user creating request

  @ApiProperty({ description: 'Latitude coordinate', example: 40.7128, minimum: -90, maximum: 90 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({ description: 'Longitude coordinate', example: -74.0060, minimum: -180, maximum: 180 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @ApiProperty({ description: 'Request message', example: 'Need 20 liters of fuel urgently' })
  @IsString()
  message: string;

  @ApiPropertyOptional({ description: 'Quantity in liters', example: 20, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  quantityLiters?: number;

  @ApiPropertyOptional({ description: 'Urgency level', enum: ['normal', 'urgent'], example: 'urgent' })
  @IsOptional()
  @IsEnum(['normal', 'urgent'])
  urgency?: 'normal' | 'urgent';
}

