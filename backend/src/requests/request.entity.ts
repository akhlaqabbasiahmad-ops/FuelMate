import { Entity, Column, PrimaryColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('petrol_requests')
export class PetrolRequestEntity {
  @PrimaryColumn()
  id: string;

  @Column()
  needyId: string; // Can be needy or provider ID

  @Column({ nullable: true })
  needyName?: string; // User's name (needy or provider)

  @Column({ type: 'text' })
  role: 'needy' | 'provider'; // Who created the request

  @Column('decimal', { precision: 10, scale: 7 })
  latitude: number;

  @Column('decimal', { precision: 10, scale: 7 })
  longitude: number;

  @Column('text')
  message: string;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  quantityLiters?: number;

  @Column({ type: 'text', default: 'normal' })
  urgency: 'normal' | 'urgent';

  @Column({ type: 'text', default: 'pending' })
  status: 'pending' | 'accepted' | 'in_progress' | 'completed' | 'cancelled';

  @Column({ nullable: true })
  acceptedBy?: string; // Provider ID who accepted (if needy request) or Needy ID (if provider request)

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

// Keep the interface for type checking
export interface PetrolRequest {
  id: string;
  needyId: string;
  needyName?: string;
  role: 'needy' | 'provider';
  latitude: number;
  longitude: number;
  message: string;
  quantityLiters?: number;
  urgency: 'normal' | 'urgent';
  status: 'pending' | 'accepted' | 'in_progress' | 'completed' | 'cancelled';
  acceptedBy?: string;
  createdAt: Date;
  updatedAt: Date;
}
