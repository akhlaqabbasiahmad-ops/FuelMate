export enum IntentType {
  CREATE_PETROL_REQUEST = 'create_petrol_request',
  ACCEPT_PETROL_REQUEST = 'accept_petrol_request',
  CANCEL_REQUEST = 'cancel_request',
  UPDATE_LOCATION = 'update_location',
  FIND_NEAREST_PROVIDER = 'find_nearest_provider',
  FIND_NEAREST_NEEDY = 'find_nearest_needy',
  TRACK_REQUEST = 'track_request',
  COMPLETE_DELIVERY = 'complete_delivery',
  UNKNOWN_INTENT = 'unknown_intent',
}

export interface BackendAction {
  title: string;
  description: string;
  apiEndpoint: string;
  payload: Record<string, any>;
}

export class AgentResponseDto {
  intent: IntentType;
  actions: BackendAction[];
  naturalResponse: string;
}

