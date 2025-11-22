import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PetrolRequest, PetrolRequestEntity } from './request.entity';
import { Quote, QuoteStatus, QuoteEntity } from './quote.entity';
import { LocationService } from '../location/location.service';

@Injectable()
export class RequestsService {
  private requestCounter = 0;
  private quoteCounter = 0;

  constructor(
    private readonly locationService: LocationService,
    @InjectRepository(PetrolRequestEntity)
    private readonly requestRepository: Repository<PetrolRequestEntity>,
    @InjectRepository(QuoteEntity)
    private readonly quoteRepository: Repository<QuoteEntity>,
  ) {}

  // Helper to convert entity to interface
  private entityToRequest(entity: PetrolRequestEntity): PetrolRequest {
    return {
      id: entity.id,
      needyId: entity.needyId,
      needyName: entity.needyName,
      role: entity.role,
      latitude: entity.latitude,
      longitude: entity.longitude,
      message: entity.message,
      quantityLiters: entity.quantityLiters,
      urgency: entity.urgency,
      status: entity.status,
      acceptedBy: entity.acceptedBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    };
  }

  // Helper to convert interface to entity
  private requestToEntity(request: Partial<PetrolRequest>): PetrolRequestEntity {
    const entity = this.requestRepository.create();
    Object.assign(entity, request);
    return entity;
  }

  // Helper to convert quote entity to interface
  private entityToQuote(entity: QuoteEntity): Quote {
    return {
      id: entity.id,
      requestId: entity.requestId,
      providerId: entity.providerId,
      needyId: entity.needyId,
      price: entity.price,
      currency: entity.currency,
      estimatedDeliveryTime: entity.estimatedDeliveryTime,
      message: entity.message,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      expiresAt: entity.expiresAt,
    };
  }

  // Helper to convert quote interface to entity
  private quoteToEntity(quote: Partial<Quote>): QuoteEntity {
    const entity = this.quoteRepository.create();
    Object.assign(entity, quote);
    return entity;
  }

  async createRequest(
    userId: string,
    latitude: number,
    longitude: number,
    message: string,
    quantityLiters?: number,
    urgency: 'normal' | 'urgent' = 'normal',
    userRole: 'needy' | 'provider' = 'needy', // Default to needy for backward compatibility
  ): Promise<PetrolRequest> {
    // Get existing user location to preserve their actual role
    const existingLocation = this.locationService.getLocation(userId);
    
    // IMPORTANT: Preserve the user's actual role from location service, don't change it
    // The userRole parameter is only for the request's role field (who created it)
    // But the user's location role should remain what they registered as
    const actualUserRole = existingLocation?.role || userRole;
    const userName = existingLocation?.name || (actualUserRole === 'needy' ? 'Needy User' : 'Provider');

    // Removed verbose logging - focus on history debugging only

    const requestEntity = this.requestRepository.create({
      id: `req_${Date.now()}_${++this.requestCounter}`,
      needyId: userId, // IMPORTANT: This is the backend-assigned user ID - must match userId used in history queries
      needyName: userName,
      role: userRole, // Who created the request (can be different from user's role)
      latitude,
      longitude,
      message,
      quantityLiters,
      urgency,
      status: 'pending',
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const savedEntity = await this.requestRepository.save(requestEntity);
    const request = this.entityToRequest(savedEntity);
    
    // Update user location - PRESERVE their actual role, don't change it!
    // Only update location coordinates and availability, keep role as-is
    this.locationService.updateLocation(userId, {
      userId: userId,
      name: userName,
      role: actualUserRole, // Use actual user role, not request role
      latitude,
      longitude,
      isAvailable: true, // Keep them active when they create a request
    });

    // Removed verbose logging - focus on history debugging only
    return request;
  }

  async findNearestRequests(
    providerLat: number,
    providerLon: number,
    maxDistanceKm: number = 10,
    limit: number = 10,
    userId?: string, // Optional: if provided, include user's own requests even if not pending
    userRole?: 'needy' | 'provider', // Optional: user role to determine what to show
  ): Promise<PetrolRequest[]> {
    const allEntities = await this.requestRepository.find();
    const allRequests = allEntities.map(e => this.entityToRequest(e));
    // Removed verbose logging - focus on history debugging only
    
    // Show pending requests, OR if userId is provided, also show relevant requests based on role
    let requestsToShow: PetrolRequest[];
    if (userId && userRole === 'provider') {
      // For providers: Show pending requests AND requests they've accepted
      requestsToShow = allRequests.filter(
        (req) => 
          req.status === 'pending' || 
          (req.acceptedBy === userId && (req.status === 'accepted' || req.status === 'in_progress')),
      );
    } else if (userId && userRole === 'needy') {
      // For needy users: Include pending requests AND user's own requests (even if accepted)
      requestsToShow = allRequests.filter(
        (req) => req.status === 'pending' || (req.needyId === userId && req.status !== 'completed' && req.status !== 'cancelled'),
      );
    } else if (userId) {
      // Fallback: if userId provided but no role, include user's own requests
      requestsToShow = allRequests.filter(
        (req) => req.status === 'pending' || (req.needyId === userId && req.status !== 'completed' && req.status !== 'cancelled'),
      );
    } else {
      // Only show pending requests (for providers without userId)
      requestsToShow = allRequests.filter(
        (req) => req.status === 'pending',
      );
    }

    const requestsWithDistance = requestsToShow.map((request) => {
      const distance = this.locationService.calculateDistance(
        providerLat,
        providerLon,
        request.latitude,
        request.longitude,
      );
      // Include name in response for display
      return { ...request, name: request.needyName, distance };
    });

    const filtered = requestsWithDistance.filter((req) => req.distance <= maxDistanceKm);
    console.log(`📍 Requests within ${maxDistanceKm}km: ${filtered.length}`);

    const sorted = filtered
      .sort((a, b) => {
        // Sort by urgency first, then distance
        if (a.urgency === 'urgent' && b.urgency !== 'urgent') return -1;
        if (a.urgency !== 'urgent' && b.urgency === 'urgent') return 1;
        return a.distance - b.distance;
      })
      .slice(0, limit)
      .map(({ distance, ...request }) => ({ ...request, distance })); // Keep distance in response

    console.log(`✅ Returning ${sorted.length} requests`);
    return sorted;
  }

  findNearestProviders(
    needyLat: number,
    needyLon: number,
    maxDistanceKm: number = 10,
    limit: number = 10,
    needyId?: string, // Optional: exclude this needy user's own ID
  ) {
    const providers = this.locationService.findNearestProviders(
      needyLat,
      needyLon,
      maxDistanceKm,
      limit,
      needyId, // Pass needyId to exclude themselves
    );
    console.log(`📊 Found ${providers.length} providers within ${maxDistanceKm}km${needyId ? ` (excluding needy ${needyId})` : ''}`);
    return providers;
  }

  findNearestNeeders(
    providerLat: number,
    providerLon: number,
    maxDistanceKm: number = 10,
    limit: number = 10,
    providerId?: string, // Optional: exclude this provider's own ID
  ) {
    const needers = this.locationService.findNearestNeedy(
      providerLat,
      providerLon,
      maxDistanceKm,
      limit,
      providerId, // Pass providerId to exclude themselves
    );
    console.log(`📊 Found ${needers.length} needers within ${maxDistanceKm}km${providerId ? ` (excluding provider ${providerId})` : ''}`);
    return needers;
  }

  async acceptRequest(requestId: string, providerId: string): Promise<PetrolRequest> {
    const requestEntity = await this.requestRepository.findOne({ where: { id: requestId } });
    if (!requestEntity) {
      throw new Error('Request not found');
    }
    if (requestEntity.status !== 'pending') {
      throw new Error(`Request is already ${requestEntity.status}`);
    }

    requestEntity.status = 'accepted';
    requestEntity.acceptedBy = providerId;
    requestEntity.updatedAt = new Date();

    // Update provider location
    const providerLocation = this.locationService.getLocation(providerId);
    if (providerLocation) {
      this.locationService.updateLocation(providerId, {
        ...providerLocation,
        isAvailable: false, // Provider is now busy
      });
    }

    const savedEntity = await this.requestRepository.save(requestEntity);
    return this.entityToRequest(savedEntity);
  }

  async getRequest(requestId: string): Promise<PetrolRequest | undefined> {
    const entity = await this.requestRepository.findOne({ where: { id: requestId } });
    return entity ? this.entityToRequest(entity) : undefined;
  }

  async getUserRequests(userId: string): Promise<PetrolRequest[]> {
    const entities = await this.requestRepository.find({ where: { needyId: userId } });
    return entities.map(e => this.entityToRequest(e));
  }

  async cancelRequest(requestId: string, userId: string): Promise<PetrolRequest> {
    const requestEntity = await this.requestRepository.findOne({ where: { id: requestId } });
    if (!requestEntity) {
      throw new Error('Request not found');
    }
    if (requestEntity.needyId !== userId) {
      throw new Error('Unauthorized to cancel this request');
    }

    requestEntity.status = 'cancelled';
    requestEntity.updatedAt = new Date();
    const savedEntity = await this.requestRepository.save(requestEntity);

    // Free up provider if request was accepted
    if (requestEntity.acceptedBy) {
      const providerLocation = this.locationService.getLocation(
        requestEntity.acceptedBy,
      );
      if (providerLocation) {
        this.locationService.updateLocation(requestEntity.acceptedBy, {
          ...providerLocation,
          isAvailable: true,
        });
      }
    }

    return this.entityToRequest(savedEntity);
  }

  async completeRequest(requestId: string, userId: string, userRole: 'needy' | 'provider'): Promise<PetrolRequest> {
    const requestEntity = await this.requestRepository.findOne({ where: { id: requestId } });
    if (!requestEntity) {
      throw new Error('Request not found');
    }

    // Validate completion authorization
    if (userRole === 'provider') {
      // Provider can complete if they accepted the request
      if (requestEntity.acceptedBy !== userId) {
        throw new Error('Unauthorized to complete this request');
      }
    } else {
      // Needy can complete their own request
      if (requestEntity.needyId !== userId) {
        throw new Error('Unauthorized to complete this request');
      }
    }

    if (requestEntity.status !== 'accepted' && requestEntity.status !== 'in_progress') {
      throw new Error(`Cannot complete request with status ${requestEntity.status}`);
    }

    // Mark request as completed
    requestEntity.status = 'completed';
    requestEntity.updatedAt = new Date();
    console.log(`💾 Saving completed request ${requestId} to database...`);
    const savedEntity = await this.requestRepository.save(requestEntity);
    console.log(`✅ Completed request saved: id=${savedEntity.id}, status=${savedEntity.status}, needyId=${savedEntity.needyId}, acceptedBy=${savedEntity.acceptedBy || 'none'}`);
    
    // Verify it was saved correctly by querying it back
    const verifyEntity = await this.requestRepository.findOne({ where: { id: requestId } });
    if (verifyEntity) {
      console.log(`✅ Verified saved request: id=${verifyEntity.id}, status=${verifyEntity.status}`);
    } else {
      console.error(`❌ ERROR: Completed request ${requestId} not found in database after saving!`);
    }

    // Free up provider if they were assigned
    if (requestEntity.acceptedBy) {
      const providerLocation = this.locationService.getLocation(requestEntity.acceptedBy);
      if (providerLocation) {
        this.locationService.updateLocation(requestEntity.acceptedBy, {
          ...providerLocation,
          isAvailable: true,
        });
      }
    }

    const completedRequest = this.entityToRequest(savedEntity);
    console.log(`✅ Request ${requestId} completed by ${userRole} ${userId}. Moved to history.`);
    console.log(`   - Status: ${completedRequest.status}`);
    console.log(`   - NeedyId: ${completedRequest.needyId}`);
    console.log(`   - AcceptedBy: ${completedRequest.acceptedBy || 'none'}`);
    console.log(`   ✅ This request should appear in history for needy "${completedRequest.needyId}" and provider "${completedRequest.acceptedBy || 'none'}"`);
    return completedRequest;
  }

  /**
   * Get request history for a user
   * - Needy users: See ALL their requests (pending, accepted, in_progress, completed) - exclude only cancelled
   * - Provider users: See requests they accepted (accepted, in_progress, completed) AND requests they created (all statuses except cancelled)
   */
  async getRequestHistory(userId: string, userRole: 'needy' | 'provider'): Promise<PetrolRequest[]> {
    // IMPORTANT: userId must be the backend-assigned ID from signup
    // This ID is consistent across all operations (requests, quotes, history)
    
    if (!userId || userId.trim() === '') {
      console.error('❌ Invalid userId provided to getRequestHistory:', userId);
      return [];
    }
    
    // Query all requests from database, including completed ones
    console.log(`📜 Querying database for all requests...`);
    const allEntities = await this.requestRepository.find({
      order: { updatedAt: 'DESC' }, // Order by most recent first
    });
    console.log(`📜 Database returned ${allEntities.length} entities`);
    const allRequests = allEntities.map(e => this.entityToRequest(e));
    console.log(`📜 Getting history for ${userRole} user: ${userId}`);
    console.log(`📜 Total requests in system: ${allRequests.length}`);
    console.log(`📜 All request IDs:`, allRequests.map(r => ({ 
      id: r.id, 
      status: r.status, 
      needyId: r.needyId, 
      acceptedBy: r.acceptedBy || 'none',
      updatedAt: r.updatedAt instanceof Date ? r.updatedAt.toISOString() : r.updatedAt
    })));
    
    // Log completed requests specifically
    const completedRequests = allRequests.filter(req => req.status === 'completed');
    console.log(`📜 Total completed requests in system: ${completedRequests.length}`);
    completedRequests.forEach(req => {
      console.log(`   ✅ Completed Request ${req.id}: needyId=${req.needyId}, acceptedBy=${req.acceptedBy || 'none'}`);
    });
    
    // Log all requests for debugging ID matching
    console.log(`📜 All requests in system:`);
    allRequests.forEach(req => {
      const matchesNeedy = req.needyId === userId;
      const matchesProvider = req.acceptedBy === userId;
      const matchIndicator = matchesNeedy || matchesProvider ? '✅' : '❌';
      console.log(`   ${matchIndicator} Request ${req.id}: status=${req.status}, needyId=${req.needyId}, acceptedBy=${req.acceptedBy || 'none'}`);
    });
    
    if (userRole === 'provider') {
      // Provider sees:
      // 1. Requests they accepted (where acceptedBy === userId) - accepted, in_progress, completed
      // 2. Requests they created (where needyId === userId) - all statuses except cancelled
      const allMatchingAcceptedBy = allRequests.filter(req => req.acceptedBy === userId);
      const allMatchingNeedyId = allRequests.filter(req => req.needyId === userId);
      console.log(`📜 Requests where acceptedBy="${userId}": ${allMatchingAcceptedBy.length}`);
      console.log(`📜 Requests where needyId="${userId}" (provider's own requests): ${allMatchingNeedyId.length}`);
      allMatchingAcceptedBy.forEach(req => {
        console.log(`   ✅ Accepted Request ${req.id}: status=${req.status}, needyId=${req.needyId}`);
      });
      allMatchingNeedyId.forEach(req => {
        console.log(`   ✅ Own Request ${req.id}: status=${req.status}, acceptedBy=${req.acceptedBy || 'none'}`);
      });
      
      // Also check for partial matches to help debug ID mismatches
      const partialMatches = allRequests.filter(req => 
        req.acceptedBy && req.acceptedBy.includes(userId.split('_')[0]) && req.acceptedBy !== userId
      );
      if (partialMatches.length > 0) {
        console.log(`⚠️ Found ${partialMatches.length} requests with similar but different provider IDs:`);
        partialMatches.forEach(req => {
          console.log(`   - Request ${req.id}: acceptedBy="${req.acceptedBy}" (expected: "${userId}")`);
        });
      }
      
      const providerHistory = allRequests
        .filter((req) => {
          // Include requests where provider accepted (acceptedBy === userId) with status accepted/in_progress/completed
          const acceptedMatch = req.acceptedBy === userId && 
            (req.status === 'completed' || req.status === 'accepted' || req.status === 'in_progress');
          
          // OR include requests where provider created (needyId === userId) with any status except cancelled
          const ownRequestMatch = req.needyId === userId && req.status !== 'cancelled';
          
          const included = acceptedMatch || ownRequestMatch;
          if (included && req.status === 'completed') {
            console.log(`   ✅ Including completed request ${req.id} for provider ${userId} (acceptedMatch: ${acceptedMatch}, ownRequestMatch: ${ownRequestMatch})`);
          }
          return included;
        })
        .sort((a, b) => {
          // Sort by status priority first (accepted > in_progress > pending > completed), then by date
          const statusOrder = { 'accepted': 1, 'in_progress': 2, 'pending': 3, 'completed': 4 };
          const statusDiff = (statusOrder[a.status as keyof typeof statusOrder] || 99) - 
                            (statusOrder[b.status as keyof typeof statusOrder] || 99);
          if (statusDiff !== 0) return statusDiff;
          // If same status, newest first
          // Ensure dates are Date objects
          const aDate = a.updatedAt instanceof Date ? a.updatedAt : new Date(a.updatedAt);
          const bDate = b.updatedAt instanceof Date ? b.updatedAt : new Date(b.updatedAt);
          return bDate.getTime() - aDate.getTime();
        });
      console.log(`📜 Provider "${userId}" history: ${providerHistory.length} requests`);
      providerHistory.forEach(req => {
        console.log(`   ✅ Request ${req.id}: status=${req.status}, needyId=${req.needyId}, acceptedBy=${req.acceptedBy || 'none'}`);
      });
      return providerHistory;
    } else {
      // Needy sees ALL their own requests (pending, accepted, in_progress, completed)
      // Exclude only cancelled requests
      // Match by needyId field - must match exactly
      const allMatchingNeedyId = allRequests.filter(req => req.needyId === userId);
      console.log(`📜 Requests where needyId="${userId}": ${allMatchingNeedyId.length}`);
      allMatchingNeedyId.forEach(req => {
        console.log(`   ✅ Request ${req.id}: status=${req.status}, acceptedBy=${req.acceptedBy || 'none'}`);
      });
      
      // Also check for partial matches to help debug ID mismatches
      const partialMatches = allRequests.filter(req => 
        req.needyId.includes(userId.split('_')[0]) && req.needyId !== userId
      );
      if (partialMatches.length > 0) {
        console.log(`⚠️ Found ${partialMatches.length} requests with similar but different needy IDs:`);
        partialMatches.forEach(req => {
          console.log(`   - Request ${req.id}: needyId="${req.needyId}" (expected: "${userId}")`);
        });
      }
      
      const needyHistory = allRequests
        .filter((req) => {
          // Exact match required - userId must match needyId exactly
          // Include ALL statuses except cancelled (pending, accepted, in_progress, completed)
          const matches = req.needyId === userId && req.status !== 'cancelled';
          if (matches && req.status === 'completed') {
            console.log(`   ✅ Including completed request ${req.id} for needy ${userId}`);
          }
          return matches;
        })
        .sort((a, b) => {
          // Sort by status priority first (accepted > in_progress > pending > completed), then by date
          const statusOrder = { 'accepted': 1, 'in_progress': 2, 'pending': 3, 'completed': 4 };
          const statusDiff = (statusOrder[a.status as keyof typeof statusOrder] || 99) - 
                            (statusOrder[b.status as keyof typeof statusOrder] || 99);
          if (statusDiff !== 0) return statusDiff;
          // If same status, newest first
          // Ensure dates are Date objects
          const aDate = a.updatedAt instanceof Date ? a.updatedAt : new Date(a.updatedAt);
          const bDate = b.updatedAt instanceof Date ? b.updatedAt : new Date(b.updatedAt);
          return bDate.getTime() - aDate.getTime();
        });
      console.log(`📜 Needy "${userId}" history: ${needyHistory.length} requests`);
      needyHistory.forEach(req => {
        console.log(`   ✅ Request ${req.id}: status=${req.status}, needyId=${req.needyId}, acceptedBy=${req.acceptedBy || 'none'}`);
      });
      return needyHistory;
    }
  }

  /**
   * Get active requests for a user (pending, accepted, in_progress)
   */
  async getActiveRequests(userId: string, userRole: 'needy' | 'provider'): Promise<PetrolRequest[]> {
    const allEntities = await this.requestRepository.find();
    const allRequests = allEntities.map(e => this.entityToRequest(e));
    
    if (userRole === 'provider') {
      // Provider sees requests they accepted (accepted/in_progress)
      return allRequests
        .filter((req) => req.acceptedBy === userId && (req.status === 'accepted' || req.status === 'in_progress'))
        .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime());
    } else {
      // Needy sees their own active requests
      return allRequests
        .filter((req) => req.needyId === userId && req.status !== 'completed' && req.status !== 'cancelled')
        .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime());
    }
  }

  // Quote Management
  async createQuote(
    requestId: string,
    providerId: string,
    price: number,
    currency: string,
    estimatedDeliveryTime: number,
    message?: string,
  ): Promise<Quote> {
    if (!providerId || providerId.trim() === '') {
      throw new Error('Provider ID is required and cannot be empty');
    }

    if (!requestId || requestId.trim() === '') {
      throw new Error('Request ID is required and cannot be empty');
    }

    const requestEntity = await this.requestRepository.findOne({ where: { id: requestId } });
    if (!requestEntity) {
      console.error(`❌ Request not found: ${requestId}`);
      throw new Error(`Request not found: ${requestId}`);
    }
    const request = this.entityToRequest(requestEntity);

    if (request.status !== 'pending') {
      throw new Error(`Cannot quote on ${request.status} request`);
    }

    // Check if provider already quoted on this request
    const existingQuoteEntities = await this.quoteRepository.find({
      where: { requestId, providerId, status: QuoteStatus.PENDING },
    });
    const existingQuotes = existingQuoteEntities.map(e => this.entityToQuote(e));
    if (existingQuotes.length > 0) {
      console.warn(`⚠️ Provider ${providerId} already has a pending quote on request ${requestId}`);
      // Allow updating existing quote or throw error - for now, allow multiple quotes
    }

    const quoteEntity = this.quoteRepository.create({
      id: `quote_${Date.now()}_${++this.quoteCounter}`,
      requestId,
      providerId,
      needyId: request.needyId,
      price,
      currency,
      estimatedDeliveryTime,
      message,
      status: QuoteStatus.PENDING,
      createdAt: new Date(),
      updatedAt: new Date(),
      expiresAt: new Date(Date.now() + 30 * 60 * 1000), // Expires in 30 minutes
    });

    // IMPORTANT: Ensure IDs are consistent
    // request.needyId is the backend-assigned user ID from signup
    // providerId is the backend-assigned provider ID from signup
    // These IDs must match exactly when querying history
    
    const savedEntity = await this.quoteRepository.save(quoteEntity);
    const quote = this.entityToQuote(savedEntity);
    console.log(`💰 Quote created: ${quote.id} for request ${requestId} by provider "${providerId}"`);
    console.log(`   Linked to needy: "${request.needyId}"`);
    console.log(`   Price: ${currency} ${price}, Delivery: ${estimatedDeliveryTime} min`);
    console.log(`   ✅ Needy "${request.needyId}" can retrieve this quote via getQuotesForNeedy()`);
    console.log(`   ✅ When accepted, request.acceptedBy will be set to "${providerId}" for history queries`);
    return quote;
  }

  async getQuotesForRequest(requestId: string): Promise<Quote[]> {
    const requestEntity = await this.requestRepository.findOne({ where: { id: requestId } });
    if (!requestEntity) {
      throw new Error('Request not found');
    }

    const quoteEntities = await this.quoteRepository.find({
      where: { requestId, status: QuoteStatus.PENDING },
    });
    
    const quotes = quoteEntities
      .map(e => this.entityToQuote(e))
      .filter((quote) => quote.expiresAt > new Date()) // Remove expired quotes
      .sort((a, b) => a.price - b.price); // Sort by price (lowest first)

    return quotes;
  }

  async getQuotesForNeedy(needyId: string): Promise<Quote[]> {
    const quoteEntities = await this.quoteRepository.find({
      where: [
        { needyId, status: QuoteStatus.PENDING },
        { needyId, status: QuoteStatus.ACCEPTED },
      ],
    });
    
    const needyQuotes = quoteEntities
      .map(e => this.entityToQuote(e))
      .filter((quote) => quote.expiresAt > new Date()) // Remove expired quotes
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime()); // Newest first
    
    return needyQuotes;
  }

  async getQuotesForProvider(providerId: string): Promise<Quote[]> {
    const quoteEntities = await this.quoteRepository.find({
      where: { providerId },
      order: { createdAt: 'DESC' },
    });
    return quoteEntities.map(e => this.entityToQuote(e));
  }

  async acceptQuote(quoteId: string, needyId: string): Promise<Quote> {
    console.log(`🔍 Accepting quote: quoteId=${quoteId}, needyId=${needyId}`);
    
    if (!needyId || needyId.trim() === '') {
      throw new Error('Needy ID is required and cannot be empty');
    }
    
    const quoteEntity = await this.quoteRepository.findOne({ where: { id: quoteId } });
    if (!quoteEntity) {
      console.error(`❌ Quote ${quoteId} not found in database`);
      const totalQuotes = await this.quoteRepository.count();
      console.error(`   Total quotes in system: ${totalQuotes}`);
      throw new Error(`Quote not found: ${quoteId}`);
    }
    const quote = this.entityToQuote(quoteEntity);
    
    console.log(`📋 Found quote: ${quote.id}, needyId=${quote.needyId}, requestId=${quote.requestId}`);
    
    if (quote.needyId !== needyId) {
      console.error(`❌ Unauthorized: Quote needyId (${quote.needyId}) does not match provided needyId (${needyId})`);
      throw new Error(`Unauthorized to accept this quote. Quote belongs to needy ${quote.needyId}, but you are ${needyId}`);
    }
    
    if (quote.status !== QuoteStatus.PENDING) {
      console.error(`❌ Quote already ${quote.status}`);
      throw new Error(`Quote is already ${quote.status}`);
    }
    
    // Handle expiresAt - could be Date object or string
    const expiresAtDate = quote.expiresAt instanceof Date ? quote.expiresAt : new Date(quote.expiresAt);
    if (expiresAtDate < new Date()) {
      console.error(`❌ Quote expired at ${expiresAtDate}`);
      throw new Error('Quote has expired');
    }

    // Accept the quote
    quoteEntity.status = QuoteStatus.ACCEPTED;
    quoteEntity.updatedAt = new Date();

    // Reject all other quotes for this request
    const otherQuoteEntities = await this.quoteRepository.find({
      where: { requestId: quote.requestId, status: QuoteStatus.PENDING },
    });
    for (const qEntity of otherQuoteEntities) {
      if (qEntity.id !== quoteId) {
        qEntity.status = QuoteStatus.REJECTED;
        qEntity.updatedAt = new Date();
        await this.quoteRepository.save(qEntity);
      }
    }

    // Update request status to 'accepted' - this will hide it from other providers
    const requestEntity = await this.requestRepository.findOne({ where: { id: quote.requestId } });
    if (requestEntity) {
      // IMPORTANT: Ensure IDs are consistent
      // request.needyId should match the needyId from the quote (which matches the userId)
      // request.acceptedBy should be set to quote.providerId (backend-assigned provider ID)
      
      requestEntity.status = 'accepted';
      requestEntity.acceptedBy = quote.providerId; // IMPORTANT: This must be the backend-assigned provider ID
      requestEntity.updatedAt = new Date();
      const savedRequestEntity = await this.requestRepository.save(requestEntity);
      const request = this.entityToRequest(savedRequestEntity);
      
      console.log(`📋 Request ${request.id} status changed to 'accepted'`);
      console.log(`   - Needy ID: "${request.needyId}" (must match userId in history queries)`);
      console.log(`   - Provider ID (acceptedBy): "${request.acceptedBy}" (must match providerId in history queries)`);
      console.log(`   - Status: ${request.status}`);
      console.log(`   - Updated at: ${request.updatedAt}`);
      console.log(`   ✅ This request will now appear in history for needy "${request.needyId}" and provider "${request.acceptedBy}"`);
      
      // Validate ID consistency
      if (request.needyId !== quote.needyId) {
        console.error(`⚠️ WARNING: Request needyId ("${request.needyId}") doesn't match quote needyId ("${quote.needyId}")`);
      }
    } else {
      console.error(`❌ Request ${quote.requestId} not found when accepting quote ${quoteId}`);
    }

    const savedQuoteEntity = await this.quoteRepository.save(quoteEntity);
    const savedQuote = this.entityToQuote(savedQuoteEntity);
    console.log(`✅ Quote accepted: ${quoteId} by needy ${needyId}. Request ${quote.requestId} is now accepted and hidden from other providers.`);
    return savedQuote;
  }

  async rejectQuote(quoteId: string, needyId: string): Promise<Quote> {
    const quoteEntity = await this.quoteRepository.findOne({ where: { id: quoteId } });
    if (!quoteEntity) {
      throw new Error('Quote not found');
    }
    if (quoteEntity.needyId !== needyId) {
      throw new Error('Unauthorized to reject this quote');
    }

    quoteEntity.status = QuoteStatus.REJECTED;
    quoteEntity.updatedAt = new Date();
    const savedEntity = await this.quoteRepository.save(quoteEntity);
    return this.entityToQuote(savedEntity);
  }

  async getQuote(quoteId: string): Promise<Quote | undefined> {
    const entity = await this.quoteRepository.findOne({ where: { id: quoteId } });
    return entity ? this.entityToQuote(entity) : undefined;
  }
}

