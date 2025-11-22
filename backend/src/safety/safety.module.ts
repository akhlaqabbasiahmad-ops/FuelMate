import { Module } from '@nestjs/common';
import { SafetyValidatorService } from './safety-validator.service';

@Module({
  providers: [SafetyValidatorService],
  exports: [SafetyValidatorService],
})
export class SafetyModule {}

