import { Entity, Column, PrimaryColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum QuoteStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  REJECTED = 'rejected',
  EXPIRED = 'expired',
}

@Entity('quotes')
export class QuoteEntity {
  @PrimaryColumn()
  id: string;

  @Column()
  requestId: string;

  @Column()
  providerId: string;

  @Column()
  needyId: string;

  @Column('decimal', { precision: 10, scale: 2 })
  price: number; // Price in local currency

  @Column({ default: 'PKR' })
  currency: string; // Currency code (e.g., 'PKR', 'USD')

  @Column('int')
  estimatedDeliveryTime: number; // Estimated time in minutes

  @Column('text', { nullable: true })
  message?: string; // Optional message from provider

  @Column({ type: 'text', default: 'pending' })
  status: QuoteStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column()
  expiresAt: Date; // Quote expires after certain time
}

// Keep the class for type checking
export class Quote {
  id: string;
  requestId: string;
  providerId: string;
  needyId: string;
  price: number;
  currency: string;
  estimatedDeliveryTime: number;
  message?: string;
  status: QuoteStatus;
  createdAt: Date;
  updatedAt: Date;
  expiresAt: Date;
}
