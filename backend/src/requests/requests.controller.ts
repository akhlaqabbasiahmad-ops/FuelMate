import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBody } from '@nestjs/swagger';
import { RequestsService } from './requests.service';
import { CreateRequestDto } from './dto/create-request.dto';
import { CreateQuoteDto } from './dto/create-quote.dto';

// Simple auth guard - in production, use proper JWT auth
class SimpleAuthGuard {
  canActivate(context: any) {
    // For now, extract userId from request headers or body
    // In production, use JWT token
    return true;
  }
}

@ApiTags('requests')
@Controller('api/requests')
export class RequestsController {
  constructor(private readonly requestsService: RequestsService) {}

  @Post('create')
  @ApiOperation({ summary: 'Create a new fuel request' })
  @ApiResponse({ status: 201, description: 'Request created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiBody({ type: CreateRequestDto })
  async createRequest(@Body() createDto: CreateRequestDto) {
    if (!createDto.userId) {
      return {
        error: 'User ID is required',
        message: 'Please provide a valid user ID',
      };
    }

    // Get actual user role from location service to preserve it
    const locationService = this.requestsService['locationService'];
    const existingLocation = locationService.getLocation(createDto.userId);
    const actualUserRole = existingLocation?.role || createDto.userRole || 'needy';
    
    // Request role defaults to user's actual role if not specified
    const requestRole = createDto.userRole || actualUserRole;
    
    console.log(`📝 Creating request:`, {
      userId: createDto.userId,
      actualUserRole: actualUserRole,
      requestRole: requestRole,
      location: { lat: createDto.latitude, lon: createDto.longitude },
      message: createDto.message,
    });
    
    const request = await this.requestsService.createRequest(
      createDto.userId,
      createDto.latitude,
      createDto.longitude,
      createDto.message,
      createDto.quantityLiters,
      createDto.urgency || 'normal',
      requestRole, // Pass request role (who created it)
    );
    
    console.log('✅ Request created:', request.id, 'by', requestRole, createDto.userId, `(user's role: ${actualUserRole})`);
    return {
      ...request,
      message: `Request created successfully. It will be visible to nearby ${requestRole === 'needy' ? 'providers' : 'needers'}.`,
    };
  }

  @Get('nearest')
  @ApiOperation({ summary: 'Find nearest fuel requests' })
  @ApiQuery({ name: 'latitude', type: Number, description: 'Latitude of the search location' })
  @ApiQuery({ name: 'longitude', type: Number, description: 'Longitude of the search location' })
  @ApiQuery({ name: 'maxDistance', type: Number, required: false, description: 'Maximum distance in km (default: 10)' })
  @ApiQuery({ name: 'limit', type: Number, required: false, description: 'Maximum number of results (default: 10)' })
  @ApiQuery({ name: 'providerId', type: String, required: false, description: 'Provider user ID' })
  @ApiQuery({ name: 'needyId', type: String, required: false, description: 'Needy user ID' })
  @ApiQuery({ name: 'userRole', enum: ['needy', 'provider'], required: false, description: 'User role' })
  @ApiResponse({ status: 200, description: 'List of nearest requests' })
  async findNearestRequests(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @Query('maxDistance') maxDistance: number = 10,
    @Query('limit') limit: number = 10,
    @Query('providerId') providerId: string, // Can be provider ID or needy ID
    @Query('needyId') needyId?: string, // Optional: if provided, include needy's own requests
    @Query('userRole') userRole?: 'needy' | 'provider', // User role to determine what to show
  ) {
    // Use needyId if provided, otherwise use providerId
    const userId = needyId || providerId;
    if (!userId) {
      return {
        error: 'User ID is required (providerId or needyId)',
        requests: [],
        count: 0,
      };
    }

    console.log('🔍 Searching for requests:', {
      userId: userId,
      userRole: userRole,
      isNeedy: !!needyId,
      realLocation: { latitude: Number(latitude), longitude: Number(longitude) },
      maxDistance: Number(maxDistance),
    });

    // Register user location - PRESERVE existing role!
    const locationService = this.requestsService['locationService'];
    const existingLocation = locationService.getLocation(userId);
    
    // IMPORTANT: Preserve the user's actual role, don't hardcode it
    const actualRole = existingLocation?.role || userRole || (needyId ? 'needy' : 'provider');
    
    locationService.updateLocation(userId, {
      userId: userId,
      name: existingLocation?.name || (needyId ? 'Needy User' : 'Provider'), // Use existing name or default
      role: actualRole, // Preserve existing role, don't change it
      latitude: Number(latitude),
      longitude: Number(longitude),
      isAvailable: true,
    });
    // Don't log routine location updates - too verbose

    // Pass userId and userRole to include relevant requests (pending + accepted for providers)
    // Use actualRole determined from location service, fallback to userRole parameter
    const finalUserRole = actualRole as 'needy' | 'provider';
    console.log(`🔍 Final userRole for findNearestRequests: ${finalUserRole} (from location: ${existingLocation?.role}, param: ${userRole})`);
    const requests = await this.requestsService.findNearestRequests(
      Number(latitude),
      Number(longitude),
      Number(maxDistance),
      Number(limit),
      userId, // Pass userId for both needy and provider
      finalUserRole, // Pass determined user role
    );
    
    console.log(`✅ Found ${requests.length} requests nearby`);
    return {
      requests,
      count: requests.length,
      searchLocation: { latitude: Number(latitude), longitude: Number(longitude) },
    };
  }

  @Get('providers/nearest')
  async findNearestProviders(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @Query('maxDistance') maxDistance: number = 10,
    @Query('limit') limit: number = 10,
    @Query('needyId') needyId: string, // Required - real needy ID
  ) {
    if (!needyId) {
      return {
        error: 'Needy ID is required',
        providers: [],
        count: 0,
      };
    }

    console.log('🔍 Real needy searching for providers:', {
      needyId: needyId,
      realLocation: { latitude: Number(latitude), longitude: Number(longitude) },
      maxDistance: Number(maxDistance),
    });

    // Register real needy location - PRESERVE existing role!
    const locationService = this.requestsService['locationService'];
    const existingLocation = locationService.getLocation(needyId);
    
    // IMPORTANT: Preserve the user's actual role, don't hardcode it
    const actualRole = existingLocation?.role || 'needy';
    
    locationService.updateLocation(needyId, {
      userId: needyId,
      name: existingLocation?.name || 'Needy User', // Use existing name or default
      role: actualRole, // Preserve existing role, don't change it
      latitude: Number(latitude),
      longitude: Number(longitude),
      isAvailable: true,
    });
    // Don't log routine location updates - too verbose

    const providers = this.requestsService.findNearestProviders(
      Number(latitude),
      Number(longitude),
      Number(maxDistance),
      Number(limit),
      needyId, // Pass needyId to exclude themselves from results
    );
    
    console.log(`✅ Found ${providers.length} providers nearby`);
    return {
      providers,
      count: providers.length,
      searchLocation: { latitude: Number(latitude), longitude: Number(longitude) },
    };
  }

  @Get('needers/nearest')
  async findNearestNeeders(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @Query('maxDistance') maxDistance: number = 10,
    @Query('limit') limit: number = 10,
    @Query('providerId') providerId: string, // Required - real provider ID
  ) {
    if (!providerId) {
      return {
        error: 'Provider ID is required',
        needers: [],
        count: 0,
      };
    }

    console.log('🔍 Real provider searching for needers:', {
      providerId: providerId,
      realLocation: { latitude: Number(latitude), longitude: Number(longitude) },
      maxDistance: Number(maxDistance),
    });

    // Register real provider location - PRESERVE existing role!
    const locationService = this.requestsService['locationService'];
    const existingLocation = locationService.getLocation(providerId);
    
    // IMPORTANT: Preserve the user's actual role, don't hardcode it
    const actualRole = existingLocation?.role || 'provider';
    
    locationService.updateLocation(providerId, {
      userId: providerId,
      name: existingLocation?.name || 'Provider',
      role: actualRole, // Preserve existing role, don't change it
      latitude: Number(latitude),
      longitude: Number(longitude),
      isAvailable: true,
    });
    // Don't log routine location updates - too verbose

    const needers = this.requestsService.findNearestNeeders(
      Number(latitude),
      Number(longitude),
      Number(maxDistance),
      Number(limit),
      providerId, // Pass providerId to exclude themselves from results
    );
    
    console.log(`✅ Found ${needers.length} needers nearby`);
    return {
      needers,
      count: needers.length,
      searchLocation: { latitude: Number(latitude), longitude: Number(longitude) },
    };
  }

  @Post(':id/accept')
  @ApiOperation({ summary: 'Accept a fuel request' })
  @ApiParam({ name: 'id', description: 'Request ID' })
  @ApiResponse({ status: 200, description: 'Request accepted successfully' })
  @ApiResponse({ status: 404, description: 'Request not found' })
  async acceptRequest(
    @Param('id') requestId: string,
    @Body('providerId') providerId: string,
  ) {
    const request = await this.requestsService.acceptRequest(requestId, providerId);
    return request;
  }

  /**
   * Get request history (completed requests)
   * IMPORTANT: This route MUST come before @Get(':id') to avoid route conflicts
   */
  @Get('history')
  @ApiOperation({ summary: 'Get request history (completed requests)' })
  @ApiQuery({ name: 'userId', type: String, description: 'User ID' })
  @ApiQuery({ name: 'userRole', enum: ['needy', 'provider'], description: 'User role' })
  @ApiResponse({ status: 200, description: 'Request history retrieved successfully' })
  async getRequestHistory(
    @Query('userId') userId: string,
    @Query('userRole') userRole: 'needy' | 'provider',
  ) {
    console.log(`\n\n📜 ========== HISTORY ENDPOINT CALLED ==========`);
    console.log(`📜 History endpoint called: userId=${userId}, userRole=${userRole}`);
    console.log(`📜 Query params received:`, { userId, userRole });
    console.log(`📜 Request received at: ${new Date().toISOString()}`);
    
    if (!userId || !userRole) {
      console.error('❌ Missing userId or userRole');
      console.error('❌ userId:', userId, 'userRole:', userRole);
      return {
        error: 'User ID and role are required',
        message: 'Please provide userId and userRole',
        history: [],
        count: 0,
      };
    }

    try {
      console.log(`📜 Calling getRequestHistory service method...`);
      const history = await this.requestsService.getRequestHistory(userId, userRole);
      console.log(`📜 Service returned ${history.length} history items`);
      console.log(`📜 History items:`, history.map(h => ({
        id: h.id,
        status: h.status,
        needyId: h.needyId,
        acceptedBy: h.acceptedBy,
      })));
      return {
        success: true,
        history,
        count: history.length,
      };
    } catch (error: any) {
      console.error('❌ Error getting history:', error);
      console.error('❌ Error stack:', error.stack);
      return {
        success: false,
        error: error.message || 'Failed to get history',
        history: [],
        count: 0,
      };
    }
  }

  /**
   * Get active requests (pending, accepted, in_progress)
   * IMPORTANT: This route MUST come before @Get(':id') to avoid route conflicts
   */
  @Get('active')
  async getActiveRequests(
    @Query('userId') userId: string,
    @Query('userRole') userRole: 'needy' | 'provider',
  ) {
    if (!userId || !userRole) {
      return {
        error: 'User ID and role are required',
        message: 'Please provide userId and userRole',
      };
    }

    const activeRequests = await this.requestsService.getActiveRequests(userId, userRole);
    return {
      success: true,
      requests: activeRequests,
      count: activeRequests.length,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a specific request by ID' })
  @ApiParam({ name: 'id', description: 'Request ID' })
  @ApiResponse({ status: 200, description: 'Request found' })
  @ApiResponse({ status: 404, description: 'Request not found' })
  async getRequest(@Param('id') requestId: string) {
    const request = await this.requestsService.getRequest(requestId);
    if (!request) {
      return { error: 'Request not found' };
    }
    return request;
  }

  @Get('user/:userId')
  async getUserRequests(@Param('userId') userId: string) {
    const requests = await this.requestsService.getUserRequests(userId);
    return { requests };
  }

  @Post(':id/cancel')
  async cancelRequest(
    @Param('id') requestId: string,
    @Body('userId') userId: string,
  ) {
    const request = await this.requestsService.cancelRequest(requestId, userId);
    return request;
  }

  @Post(':id/complete')
  async completeRequest(
    @Param('id') requestId: string,
    @Body('userId') userId: string,
    @Body('userRole') userRole: 'needy' | 'provider',
    @Body('providerId') providerId?: string, // Backward compatibility
  ) {
    // Support both old and new API formats
    const finalUserId = userId || providerId;
    const finalUserRole = userRole || (providerId ? 'provider' : 'needy');
    
    if (!finalUserId) {
      return {
        error: 'User ID is required',
        message: 'Please provide userId (or providerId for backward compatibility)',
      };
    }

    try {
      const request = await this.requestsService.completeRequest(requestId, finalUserId, finalUserRole);
      return {
        success: true,
        request: {
          id: request.id,
          status: request.status,
          completedAt: request.updatedAt,
        },
        message: 'Request completed successfully. Moved to history.',
      };
    } catch (error: any) {
      return {
        error: error.message || 'Failed to complete request',
        message: error.message || 'An error occurred while completing the request',
      };
    }
  }

  // Quote Endpoints
  @Post('quotes/create')
  @ApiOperation({ summary: 'Create a quote for a fuel request' })
  @ApiResponse({ status: 201, description: 'Quote created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiBody({ type: CreateQuoteDto })
  async createQuote(@Body() createQuoteDto: CreateQuoteDto) {
    if (!createQuoteDto.providerId) {
      return {
        error: 'Provider ID is required',
        message: 'Please provide a valid provider ID',
      };
    }

    if (!createQuoteDto.requestId) {
      return {
        error: 'Request ID is required',
        message: 'Please provide a valid request ID',
      };
    }

    console.log('💰 Creating quote:', {
      requestId: createQuoteDto.requestId,
      providerId: createQuoteDto.providerId,
      price: createQuoteDto.price,
      currency: createQuoteDto.currency,
      estimatedDeliveryTime: createQuoteDto.estimatedDeliveryTime,
    });

    try {
      const quote = await this.requestsService.createQuote(
        createQuoteDto.requestId,
        createQuoteDto.providerId,
        createQuoteDto.price,
        createQuoteDto.currency,
        createQuoteDto.estimatedDeliveryTime,
        createQuoteDto.message,
      );
      console.log('✅ Quote created successfully:', quote.id);
      return {
        ...quote,
        message: 'Quote sent successfully to needy user',
      };
    } catch (error: any) {
      console.error('❌ Error creating quote:', error);
      return {
        error: error.message || 'Failed to create quote',
        message: error.message || 'An error occurred while creating the quote',
      };
    }
  }

  @Get('quotes/request/:requestId')
  async getQuotesForRequest(@Param('requestId') requestId: string) {
    const quotes = await this.requestsService.getQuotesForRequest(requestId);
    return {
      quotes,
      count: quotes.length,
    };
  }

  @Get('quotes/needy/:needyId')
  async getQuotesForNeedy(@Param('needyId') needyId: string) {
    const quotes = await this.requestsService.getQuotesForNeedy(needyId);
    return {
      quotes,
      count: quotes.length,
    };
  }

  @Get('quotes/provider/:providerId')
  async getQuotesForProvider(@Param('providerId') providerId: string) {
    const quotes = await this.requestsService.getQuotesForProvider(providerId);
    return {
      quotes,
      count: quotes.length,
    };
  }

  @Post('quotes/:quoteId/accept')
  @ApiOperation({ summary: 'Accept a quote' })
  @ApiParam({ name: 'quoteId', description: 'Quote ID' })
  @ApiResponse({ status: 200, description: 'Quote accepted successfully' })
  @ApiResponse({ status: 404, description: 'Quote not found' })
  async acceptQuote(
    @Param('quoteId') quoteId: string,
    @Body('needyId') needyId: string,
  ) {
    try {
      console.log('✅ Accepting quote:', { quoteId, needyId });
      
      if (!needyId || needyId.trim() === '') {
        console.error('❌ Needy ID is missing or empty');
        throw new Error('Needy ID is required');
      }

      const quote = await this.requestsService.acceptQuote(quoteId, needyId);
      console.log('✅ Quote accepted successfully:', quote.id);
      
      const request = await this.requestsService.getRequest(quote.requestId);
      if (!request) {
        console.error(`❌ Request ${quote.requestId} not found after accepting quote`);
        // Still return success since quote was accepted, but warn about missing request
        return {
          ...quote,
          request: null,
          warning: 'Request not found',
          message: 'Quote accepted successfully, but request details could not be retrieved.',
        };
      }
      
      console.log('✅ Request retrieved:', { id: request.id, status: request.status, needyId: request.needyId, acceptedBy: request.acceptedBy });
      
      return {
        ...quote,
        request: {
          id: request.id,
          status: request.status,
          needyId: request.needyId,
          acceptedBy: request.acceptedBy,
        },
        message: 'Quote accepted successfully. Request is now hidden from other providers.',
      };
    } catch (error: any) {
      console.error('❌ Error accepting quote:', error);
      console.error('Error details:', {
        message: error.message,
        stack: error.stack,
        quoteId,
        needyId,
      });
      throw error; // Let NestJS handle the error response
    }
  }

  @Post('quotes/:quoteId/reject')
  async rejectQuote(
    @Param('quoteId') quoteId: string,
    @Body('needyId') needyId: string,
  ) {
    const quote = await this.requestsService.rejectQuote(quoteId, needyId);
    return {
      ...quote,
      message: 'Quote rejected',
    };
  }

  @Get('quotes/:quoteId')
  async getQuote(@Param('quoteId') quoteId: string) {
    const quote = await this.requestsService.getQuote(quoteId);
    if (!quote) {
      return { error: 'Quote not found' };
    }
    return quote;
  }

}

