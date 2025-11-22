import { Injectable } from '@nestjs/common';
import { IntentType } from '../agent/dto/agent-response.dto';
import { UserRole } from '../agent/dto/agent-request.dto';

@Injectable()
export class SafetyValidatorService {
  private readonly unsafeKeywords = [
    'illegal',
    'smuggle',
    'black market',
    'unauthorized',
    'dangerous',
    'explosive',
    'unsafe',
    'risk',
    'bypass',
    'avoid',
    'illegal transport',
  ];

  validateMessage(message: string): { isSafe: boolean; warning?: string } {
    const lowerMessage = message.toLowerCase();

    for (const keyword of this.unsafeKeywords) {
      if (lowerMessage.includes(keyword)) {
        return {
          isSafe: false,
          warning: 'Safety warning: Message contains potentially unsafe content. Please ensure all fuel transport follows legal regulations.',
        };
      }
    }

    return { isSafe: true };
  }

  validateAction(intent: IntentType, role: UserRole): { isSafe: boolean; warning?: string } {
    // Ensure needy can't accept requests
    if (intent === IntentType.ACCEPT_PETROL_REQUEST && role === UserRole.NEEDY) {
      return {
        isSafe: false,
        warning: 'Invalid action: Needers cannot accept requests.',
      };
    }

    // Ensure providers can't create requests
    if (intent === IntentType.CREATE_PETROL_REQUEST && role === UserRole.PROVIDER) {
      return {
        isSafe: false,
        warning: 'Invalid action: Providers cannot create requests.',
      };
    }

    return { isSafe: true };
  }

  sanitizeResponse(response: string): string {
    // Remove potentially harmful patterns
    const unsafePatterns = [
      /ignore.*safety/gi,
      /bypass.*regulation/gi,
      /illegal.*method/gi,
    ];

    let sanitized = response;
    for (const pattern of unsafePatterns) {
      sanitized = sanitized.replace(pattern, '');
    }

    // Add safety disclaimer if not present
    if (!sanitized.toLowerCase().includes('regulation')) {
      sanitized += ' Please ensure all fuel transport complies with local regulations.';
    }

    return sanitized.trim();
  }
}

