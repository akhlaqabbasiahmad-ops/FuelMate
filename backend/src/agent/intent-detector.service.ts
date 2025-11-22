import { Injectable } from '@nestjs/common';
import { IntentType } from './dto/agent-response.dto';
import { UserRole } from './dto/agent-request.dto';

@Injectable()
export class IntentDetectorService {
  // Keywords for intent detection (English and Urdu transliterations)
  private readonly intentKeywords: Record<IntentType, string[]> = {
    [IntentType.CREATE_PETROL_REQUEST]: [
      'need petrol', 'want petrol', 'require petrol', 'petrol chahiye',
      'petrol needed', 'need fuel', 'out of petrol', 'petrol khatam',
      'create request', 'new request', 'request petrol', 'order petrol',
    ],
    [IntentType.ACCEPT_PETROL_REQUEST]: [
      'accept', 'take', 'yes', 'okay', 'confirm', 'agree',
      'accept request', 'take request', 'haan', 'theek hai',
    ],
    [IntentType.CANCEL_REQUEST]: [
      'cancel', 'stop', 'delete', 'remove', 'cancel request',
      'cancel order', 'ruk jao', 'cancel karo',
    ],
    [IntentType.UPDATE_LOCATION]: [
      'update location', 'change location', 'new location', 'location update',
      'location badlo', 'nayi location',
    ],
    [IntentType.FIND_NEAREST_PROVIDER]: [
      'find provider', 'nearby provider', 'nearest provider', 'show providers',
      'provider dhundho', 'qareebi provider', 'provider dikhao',
    ],
    [IntentType.FIND_NEAREST_NEEDY]: [
      'find needy', 'nearby needy', 'nearest needy', 'show needers',
      'needy dhundho', 'qareebi needy', 'needy dikhao',
    ],
    [IntentType.TRACK_REQUEST]: [
      'track', 'status', 'where', 'location', 'progress',
      'track request', 'request status', 'kahan hai', 'status kya hai',
    ],
    [IntentType.COMPLETE_DELIVERY]: [
      'complete', 'done', 'finished', 'delivered', 'complete delivery',
      'delivery complete', 'ho gaya', 'complete ho gaya',
    ],
    [IntentType.UNKNOWN_INTENT]: [],
  };

  detectIntent(message: string, role: UserRole): IntentType {
    const lowerMessage = message.toLowerCase().trim();

    // Check each intent type
    for (const [intent, keywords] of Object.entries(this.intentKeywords)) {
      for (const keyword of keywords) {
        if (lowerMessage.includes(keyword.toLowerCase())) {
          const detectedIntent = intent as IntentType;

          // Role-based validation
          if (this.isValidIntentForRole(detectedIntent, role)) {
            return detectedIntent;
          }
        }
      }
    }

    // Default fallback based on role
    if (role === UserRole.NEEDY) {
      // If needy user says something unclear, assume they want to create request or find providers
      if (this.hasUrgencyKeywords(lowerMessage)) {
        return IntentType.CREATE_PETROL_REQUEST;
      }
      return IntentType.FIND_NEAREST_PROVIDER;
    } else {
      // If provider says something unclear, assume they want to find needy users
      return IntentType.FIND_NEAREST_NEEDY;
    }
  }

  private isValidIntentForRole(intent: IntentType, role: UserRole): boolean {
    // Role-based intent validation
    const needyIntents = [
      IntentType.CREATE_PETROL_REQUEST,
      IntentType.FIND_NEAREST_PROVIDER,
      IntentType.TRACK_REQUEST,
      IntentType.CANCEL_REQUEST,
      IntentType.UPDATE_LOCATION,
    ];

    const providerIntents = [
      IntentType.FIND_NEAREST_NEEDY,
      IntentType.ACCEPT_PETROL_REQUEST,
      IntentType.COMPLETE_DELIVERY,
      IntentType.TRACK_REQUEST,
      IntentType.UPDATE_LOCATION,
    ];

    if (role === UserRole.NEEDY) {
      return needyIntents.includes(intent);
    } else {
      return providerIntents.includes(intent);
    }
  }

  private hasUrgencyKeywords(message: string): boolean {
    const urgencyKeywords = ['urgent', 'asap', 'immediately', 'now', 'fast', 'jaldi', 'urgent'];
    return urgencyKeywords.some(keyword => message.includes(keyword));
  }
}

