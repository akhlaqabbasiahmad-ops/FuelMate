import { Module } from '@nestjs/common';
import { AgentController } from './agent.controller';
import { AgentService } from './agent.service';
import { IntentDetectorService } from './intent-detector.service';
import { SafetyModule } from '../safety/safety.module';

@Module({
  imports: [SafetyModule],
  controllers: [AgentController],
  providers: [AgentService, IntentDetectorService],
  exports: [AgentService],
})
export class AgentModule {}

