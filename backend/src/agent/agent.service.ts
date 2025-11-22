import { Injectable } from '@nestjs/common';
import { AgentRequestDto, UserRole } from './dto/agent-request.dto';
import { AgentResponseDto, IntentType, BackendAction } from './dto/agent-response.dto';
import { IntentDetectorService } from './intent-detector.service';
import { SafetyValidatorService } from '../safety/safety-validator.service';

@Injectable()
export class AgentService {
  constructor(
    private readonly intentDetector: IntentDetectorService,
    private readonly safetyValidator: SafetyValidatorService,
  ) {}

  async processRequest(request: AgentRequestDto): Promise<AgentResponseDto> {
    // Validate safety first
    const safetyCheck = this.safetyValidator.validateMessage(request.message);
    if (!safetyCheck.isSafe) {
      return {
        intent: IntentType.UNKNOWN_INTENT,
        actions: [],
        naturalResponse: safetyCheck.warning || 'Please ensure all fuel transport complies with local regulations.',
      };
    }

    // Detect intent
    const intent = this.intentDetector.detectIntent(request.message, request.role);

    // Generate actions based on intent and role
    const actions = this.generateActions(intent, request.role, request);

    // Generate natural response
    const naturalResponse = this.generateNaturalResponse(intent, request.role, request.message);

    // Validate action safety
    const actionSafety = this.safetyValidator.validateAction(intent, request.role);
    if (!actionSafety.isSafe) {
      return {
        intent: IntentType.UNKNOWN_INTENT,
        actions: [],
        naturalResponse: actionSafety.warning || 'Invalid action for your role.',
      };
    }

    return {
      intent,
      actions,
      naturalResponse: this.safetyValidator.sanitizeResponse(naturalResponse),
    };
  }

  private generateActions(
    intent: IntentType,
    role: UserRole,
    request: AgentRequestDto,
  ): BackendAction[] {
    const actions: BackendAction[] = [];

    switch (intent) {
      case IntentType.CREATE_PETROL_REQUEST:
        // Both needers and providers can create requests
        actions.push({
          title: role === UserRole.NEEDY ? 'Create Petrol Request' : 'Create Provider Request',
          description: role === UserRole.NEEDY 
            ? 'Create a new request for petrol delivery'
            : 'Create a request to provide petrol to nearby needers',
          apiEndpoint: '/api/requests/create',
          payload: {
            latitude: request.latitude,
            longitude: request.longitude,
            message: request.message,
            urgency: 'normal',
          },
        });
        
        if (role === UserRole.NEEDY) {
          // Also show nearest providers
          actions.push({
            title: 'Find Nearest Providers',
            description: 'See nearby providers who can help',
            apiEndpoint: '/api/requests/providers/nearest',
            payload: {
              latitude: request.latitude,
              longitude: request.longitude,
              maxDistance: 10,
            },
          });
        } else {
          // Providers can also find nearest needers
          actions.push({
            title: 'Find Nearest Needers',
            description: 'See nearby needers who need petrol',
            apiEndpoint: '/api/requests/needers/nearest',
            payload: {
              latitude: request.latitude,
              longitude: request.longitude,
              maxDistance: 10,
            },
          });
        }
        break;

      case IntentType.FIND_NEAREST_PROVIDER:
        if (role === UserRole.NEEDY) {
          actions.push({
            title: 'Find Nearest Providers',
            description: 'Search for nearby petrol providers',
            apiEndpoint: '/api/providers/nearest',
            payload: {
              latitude: request.latitude,
              longitude: request.longitude,
              maxDistance: 10,
            },
          });
        }
        break;

      case IntentType.FIND_NEAREST_NEEDY:
        if (role === UserRole.PROVIDER) {
          actions.push({
            title: 'Find Nearest Requests',
            description: 'See nearby petrol requests from needers',
            apiEndpoint: '/api/requests/nearest',
            payload: {
              latitude: request.latitude,
              longitude: request.longitude,
              maxDistance: 10,
              limit: 10,
            },
          });
        }
        break;

      case IntentType.ACCEPT_PETROL_REQUEST:
        if (role === UserRole.PROVIDER) {
          actions.push({
            title: 'Accept Request',
            description: 'Accept a petrol delivery request',
            apiEndpoint: '/api/requests/accept',
            payload: {},
          });
        }
        break;

      case IntentType.TRACK_REQUEST:
        actions.push({
          title: 'Track Request',
          description: 'Get status of your petrol request',
          apiEndpoint: '/api/requests/track',
          payload: {},
        });
        break;

      case IntentType.CANCEL_REQUEST:
        actions.push({
          title: 'Cancel Request',
          description: 'Cancel your petrol request',
          apiEndpoint: '/api/requests/cancel',
          payload: {},
        });
        break;

      case IntentType.UPDATE_LOCATION:
        actions.push({
          title: 'Update Location',
          description: 'Update your current location',
          apiEndpoint: '/api/location/update',
          payload: {
            latitude: request.latitude,
            longitude: request.longitude,
          },
        });
        break;

      case IntentType.COMPLETE_DELIVERY:
        if (role === UserRole.PROVIDER) {
          actions.push({
            title: 'Complete Delivery',
            description: 'Mark delivery as completed',
            apiEndpoint: '/api/delivery/complete',
            payload: {},
          });
        }
        break;
    }

    return actions;
  }

  private generateNaturalResponse(
    intent: IntentType,
    role: UserRole,
    message: string,
  ): string {
    const responses: Record<IntentType, Record<UserRole, string>> = {
      [IntentType.CREATE_PETROL_REQUEST]: {
        [UserRole.NEEDY]: "I'll help you create a petrol request. Finding nearby providers...",
        [UserRole.PROVIDER]: "Providers cannot create requests. Would you like to see nearby needers instead?",
      },
      [IntentType.FIND_NEAREST_PROVIDER]: {
        [UserRole.NEEDY]: "Searching for nearest petrol providers in your area...",
        [UserRole.PROVIDER]: "This action is for needy users. Would you like to see nearby needers?",
      },
      [IntentType.FIND_NEAREST_NEEDY]: {
        [UserRole.NEEDY]: "This action is for providers. Would you like to find providers instead?",
        [UserRole.PROVIDER]: "Searching for nearby users needing petrol...",
      },
      [IntentType.ACCEPT_PETROL_REQUEST]: {
        [UserRole.NEEDY]: "Only providers can accept requests. Would you like to track your request?",
        [UserRole.PROVIDER]: "Accepting the petrol request. Connecting you with the needy user...",
      },
      [IntentType.TRACK_REQUEST]: {
        [UserRole.NEEDY]: "Tracking your petrol request status...",
        [UserRole.PROVIDER]: "Tracking delivery status...",
      },
      [IntentType.CANCEL_REQUEST]: {
        [UserRole.NEEDY]: "Cancelling your petrol request...",
        [UserRole.PROVIDER]: "Cancelling the delivery...",
      },
      [IntentType.UPDATE_LOCATION]: {
        [UserRole.NEEDY]: "Updating your location for better matching...",
        [UserRole.PROVIDER]: "Updating your location to receive nearby requests...",
      },
      [IntentType.COMPLETE_DELIVERY]: {
        [UserRole.NEEDY]: "Only providers can complete deliveries. Would you like to track your request?",
        [UserRole.PROVIDER]: "Marking delivery as completed. Thank you for using FuelMate!",
      },
      [IntentType.UNKNOWN_INTENT]: {
        [UserRole.NEEDY]: "I'm here to help you get petrol. You can request petrol, find providers, or track your request.",
        [UserRole.PROVIDER]: "I'm here to help you deliver petrol. You can find nearby needers, accept requests, or complete deliveries.",
      },
    };

    return responses[intent]?.[role] || "How can I help you today?";
  }
}

