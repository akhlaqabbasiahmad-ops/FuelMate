import { Controller, Post, Body } from '@nestjs/common';
import { AgentService } from './agent.service';
import { AgentRequestDto } from './dto/agent-request.dto';
import { AgentResponseDto } from './dto/agent-response.dto';

@Controller('api/agent')
export class AgentController {
  constructor(private readonly agentService: AgentService) {}

  @Post('process')
  async processRequest(@Body() request: AgentRequestDto): Promise<AgentResponseDto> {
    return this.agentService.processRequest(request);
  }
}

