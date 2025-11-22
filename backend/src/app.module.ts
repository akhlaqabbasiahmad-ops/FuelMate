import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LocationModule } from './location/location.module';
import { SafetyModule } from './safety/safety.module';
import { HealthModule } from './health/health.module';
import { RequestsModule } from './requests/requests.module';
import { UsersModule } from './users/users.module';
import { ChatModule } from './chat/chat.module';
import { User } from './users/user.entity';
import { PetrolRequestEntity } from './requests/request.entity';
import { QuoteEntity } from './requests/quote.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env', // Explicitly specify .env file path
      ignoreEnvFile: false, // Make sure we're loading .env file
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432'), 
      username: process.env.DB_USERNAME || 'postgres',
      password: process.env.DB_PASSWORD || '123456',
      database: process.env.DB_NAME || 'fuelmate',
      entities: [User, PetrolRequestEntity, QuoteEntity],
      synchronize: process.env.NODE_ENV !== 'production', // Auto-create tables (set to false in production)
      logging: false,
      retryAttempts: 3,
      retryDelay: 3000,
    }),
    LocationModule,
    SafetyModule,
    HealthModule,
    RequestsModule,
    UsersModule,
    ChatModule,
  ],
})
export class AppModule {}

