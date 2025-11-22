import { Controller, Post, Body, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiBody } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { CheckNameDto } from './dto/check-name.dto';
import { RegisterDto } from './dto/register.dto';

@ApiTags('users')
@Controller('api/users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  /**
   * Check if a name is available and get suggestions
   */
  @Post('check-name')
  @ApiOperation({ summary: 'Check if a username is available' })
  @ApiResponse({ status: 200, description: 'Name availability check result' })
  @ApiBody({ type: CheckNameDto })
  async checkName(@Body() checkNameDto: CheckNameDto) {
    const name = checkNameDto.name.trim();
    const isAvailable = await this.usersService.isNameAvailable(name);
    const suggestedName = await this.usersService.suggestName(name);

    return {
      requestedName: name,
      isAvailable,
      suggestedName,
      message: isAvailable
        ? `Name "${name}" is available!`
        : `Name "${name}" is taken. Suggested: "${suggestedName}"`,
    };
  }

  /**
   * Register a new user or login existing user
   */
  @Post('register')
  @ApiOperation({ summary: 'Register a new user or login existing user' })
  @ApiResponse({ status: 201, description: 'User registered/logged in successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiBody({ type: RegisterDto })
  async register(@Body() registerDto: RegisterDto) {
    const { name, role } = registerDto;
    const result = await this.usersService.registerOrLogin(name, role);

    return {
      success: true,
      user: {
        id: result.user.id,
        name: result.user.name,
        role: result.user.role,
      },
      isNewUser: result.isNewUser,
      message: result.isNewUser
        ? `Welcome! Your name is "${result.user.name}"`
        : `Welcome back, ${result.user.name}!`,
    };
  }

  /**
   * Get user by ID
   */
  @Get(':userId')
  @ApiOperation({ summary: 'Get user by ID' })
  @ApiParam({ name: 'userId', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'User found' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getUser(@Param('userId') userId: string) {
    const user = await this.usersService.getUserById(userId);
    
    if (!user) {
      return {
        error: 'User not found',
        message: `No user found with ID: ${userId}`,
      };
    }

    return {
      success: true,
      user: {
        id: user.id,
        name: user.name,
        role: user.role,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
      },
    };
  }

  /**
   * Get all users (for debugging)
   */
  @Get('debug/all')
  @ApiOperation({ summary: 'Get all users (debug endpoint)' })
  @ApiResponse({ status: 200, description: 'List of all users' })
  async getAllUsers() {
    const users = await this.usersService.getAllUsers();
    return {
      success: true,
      count: users.length,
      users: users.map((u) => ({
        id: u.id,
        name: u.name,
        role: u.role,
        createdAt: u.createdAt,
        lastLoginAt: u.lastLoginAt,
      })),
    };
  }
}

