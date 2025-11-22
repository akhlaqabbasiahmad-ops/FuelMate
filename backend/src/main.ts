import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import * as os from 'os';
import * as fs from 'fs';
import * as path from 'path';

/**
 * Get all network IP addresses (excluding loopback and link-local)
 */
function getNetworkIPs(): string[] {
  const interfaces = os.networkInterfaces();
  const ips: string[] = [];
  
  for (const name of Object.keys(interfaces)) {
    const nets = interfaces[name];
    if (nets) {
      for (const net of nets) {
        // Skip internal (loopback) and non-IPv4 addresses
        if (net.family === 'IPv4' && !net.internal) {
          // Skip link-local addresses (169.254.x.x)
          if (!net.address.startsWith('169.254.')) {
            ips.push(net.address);
          }
        }
      }
    }
  }
  
  return ips;
}

async function bootstrap() {
  // Log database configuration (without password)
  console.log('\n📊 Database Configuration:');
  console.log(`   Host: ${process.env.DB_HOST || 'localhost'}`);
  console.log(`   Port: ${process.env.DB_PORT || '5432'}`);
  console.log(`   Username: ${process.env.DB_USERNAME || 'admin'}`);
  console.log(`   Database: ${process.env.DB_NAME || 'fuelmate'}`);
  console.log(`   Password: ${process.env.DB_PASSWORD ? '***set***' : '***not set (using default: 123456)***'}`);
  const envPath = path.resolve(process.cwd(), '.env');
  console.log(`   .env file exists: ${fs.existsSync(envPath) ? 'YES ✅' : 'NO ❌'}`);
  if (fs.existsSync(envPath)) {
    console.log(`   .env file path: ${envPath}`);
  } else {
    console.log(`   ⚠️  Create .env file at: ${envPath}`);
    console.log(`   Use env.template as reference or run SETUP_POSTGRES.ps1`);
  }
  console.log('');
  
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS for mobile app
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  });
  
  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    transform: true,
  }));

  // Swagger configuration
  const config = new DocumentBuilder()
    .setTitle('FuelMate API')
    .setDescription('FuelMate Backend API - Location-based fuel request and delivery platform')
    .setVersion('1.0')
    .addTag('users', 'User management endpoints')
    .addTag('requests', 'Fuel request management endpoints')
    .addTag('chat', 'Chat and messaging endpoints')
    .addTag('health', 'Health check endpoints')
    .addTag('location', 'Location tracking endpoints')
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    customSiteTitle: 'FuelMate API Documentation',
    customCss: '.swagger-ui .topbar { display: none }',
  });

  const port = process.env.PORT || 3000;
  // Listen on all network interfaces (0.0.0.0) so mobile app can connect
  await app.listen(port, '0.0.0.0');
  
  // Get network IPs
  const networkIPs = getNetworkIPs();
  
  console.log('');
  console.log('========================================');
  console.log('  FuelMate API is running!');
  console.log('========================================');
  console.log('');
  console.log('Server accessible on:');
  console.log(`  - http://localhost:${port}`);
  console.log(`  - http://127.0.0.1:${port}`);
  console.log('');
  console.log('API Documentation (Swagger):');
  console.log(`  - http://localhost:${port}/api/docs`);
  console.log('');
  
  if (networkIPs.length > 0) {
    console.log('Network IP addresses (for mobile app):');
    networkIPs.forEach(ip => {
      console.log(`  - http://${ip}:${port}`);
    });
    console.log('');
    console.log('⚠️  IMPORTANT: Make sure Windows Firewall allows connections on port', port);
    console.log('⚠️  If connection fails, check firewall settings or run as administrator');
    console.log('');
  } else {
    console.log('⚠️  No network IP addresses found. Check your network connection.');
    console.log('');
  }
  
  console.log('Mobile app configuration:');
  console.log(`  Update mobile/src/config/api.config.ts with: API_HOST_IP = '${networkIPs[0] || 'YOUR_IP_HERE'}'`);
  console.log('');
  console.log('========================================');
  console.log('');
}

bootstrap();

