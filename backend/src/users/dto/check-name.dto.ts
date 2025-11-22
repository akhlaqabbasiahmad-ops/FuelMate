import { IsString, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CheckNameDto {
  @ApiProperty({ description: 'Username to check', example: 'John Doe', minLength: 2 })
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  name: string;
}

