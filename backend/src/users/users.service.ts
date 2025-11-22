import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /**
   * Check if a name is available
   */
  async isNameAvailable(name: string): Promise<boolean> {
    const normalizedName = this.normalizeName(name);
    const existing = await this.userRepository.findOne({
      where: { name: normalizedName },
    });
    return !existing;
  }

  /**
   * Suggest alternative names if the requested name is taken
   */
  async suggestName(baseName: string): Promise<string> {
    const normalizedBase = this.normalizeName(baseName);
    
    const existing = await this.userRepository.findOne({
      where: { name: normalizedBase },
    });
    
    if (!existing) {
      return normalizedBase; // Name is available
    }

    // Name is taken, suggest alternatives
    let counter = 2;
    let suggestedName = `${normalizedBase} ${counter}`;
    
    while (true) {
      const exists = await this.userRepository.findOne({
        where: { name: suggestedName },
      });
      if (!exists) {
        break;
      }
      counter++;
      suggestedName = `${normalizedBase} ${counter}`;
    }
    
    return suggestedName;
  }

  /**
   * Register a new user or login existing user
   */
  async registerOrLogin(name: string, role: 'needy' | 'provider'): Promise<{ user: User; isNewUser: boolean }> {
    const normalizedName = this.normalizeName(name);
    
    // Check if user with this name already exists
    const existingUser = await this.userRepository.findOne({
      where: { name: normalizedName },
    });
    
    if (existingUser) {
      // User exists - login (update lastLoginAt)
      existingUser.lastLoginAt = new Date();
      await this.userRepository.save(existingUser);
      console.log(`✅ User logged in: ${existingUser.name} (${existingUser.id})`);
      return { user: existingUser, isNewUser: false };
    }

    // New user - create with suggested name
    const suggestedName = await this.suggestName(normalizedName);
    const userId = this.generateUserId(role);
    
    const newUser = this.userRepository.create({
      id: userId,
      name: suggestedName,
      role,
      createdAt: new Date(),
      lastLoginAt: new Date(),
    });

    const savedUser = await this.userRepository.save(newUser);
    console.log(`✅ New user registered: ${savedUser.name} (${savedUser.id})`);
    return { user: savedUser, isNewUser: true };
  }

  /**
   * Get user by ID
   */
  async getUserById(userId: string): Promise<User | null> {
    return await this.userRepository.findOne({
      where: { id: userId },
    });
  }

  /**
   * Get user by name
   */
  async getUserByName(name: string): Promise<User | null> {
    const normalizedName = this.normalizeName(name);
    return await this.userRepository.findOne({
      where: { name: normalizedName },
    });
  }

  /**
   * Get all users (for debugging)
   */
  async getAllUsers(): Promise<User[]> {
    return await this.userRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Normalize name (lowercase, trim)
   */
  private normalizeName(name: string): string {
    return name.trim().toLowerCase();
  }

  /**
   * Generate unique user ID
   */
  private generateUserId(role: 'needy' | 'provider'): string {
    return `${role}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}
