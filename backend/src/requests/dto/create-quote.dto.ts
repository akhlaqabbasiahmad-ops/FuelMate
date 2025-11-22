import { IsString, IsNumber, IsOptional, Min, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateQuoteDto {
  @ApiProperty({ description: 'Request ID', example: 'req-123' })
  @IsString()
  requestId: string;

  @ApiProperty({ description: 'Provider user ID', example: 'provider-456' })
  @IsString()
  providerId: string;

  @ApiProperty({ description: 'Price', example: 150.50, minimum: 0 })
  @IsNumber()
  @Min(0)
  price: number;

  @ApiProperty({ description: 'Currency code', example: 'USD' })
  @IsString()
  currency: string;

  @ApiProperty({ description: 'Estimated delivery time in minutes', example: 30, minimum: 0 })
  @IsNumber()
  @Min(0)
  estimatedDeliveryTime: number; // in minutes

  @ApiPropertyOptional({ description: 'Optional message with the quote', example: 'I can deliver within 30 minutes' })
  @IsOptional()
  @IsString()
  message?: string;
}

