import { Entity, Column, PrimaryColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryColumn()
  id: string;

  @Column({ unique: true })
  name: string; // Unique name (e.g., "akhlaq", "akhlaq 2", "akhlaq 3")

  @Column({ type: 'varchar', length: 10 })
  role: 'needy' | 'provider';

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  lastLoginAt: Date;
}
