import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RequestsController } from './requests.controller';
import { RequestsService } from './requests.service';
import { LocationModule } from '../location/location.module';
import { PetrolRequestEntity } from './request.entity';
import { QuoteEntity } from './quote.entity';

@Module({
  imports: [
    LocationModule,
    TypeOrmModule.forFeature([PetrolRequestEntity, QuoteEntity]),
  ],
  controllers: [RequestsController],
  providers: [RequestsService],
  exports: [RequestsService],
})
export class RequestsModule {}

