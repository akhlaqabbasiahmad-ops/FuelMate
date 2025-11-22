import { IsEnum, IsNumber, IsString, Min, Max, MinLength } from 'class-validator';

export enum UserRole {
  NEEDY = 'needy',
  PROVIDER = 'provider',
}

export class AgentRequestDto {
  @IsEnum(UserRole)
  role: UserRole;

  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @IsString()
  @MinLength(1)
  message: string;
}

