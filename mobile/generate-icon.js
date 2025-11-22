// Simple script to generate app icon
// This creates a basic PNG icon for FuelMate app

const fs = require('fs');
const path = require('path');

// Create assets directory if it doesn't exist
const assetsDir = path.join(__dirname, 'assets');
if (!fs.existsSync(assetsDir)) {
  fs.mkdirSync(assetsDir, { recursive: true });
}

// For now, create a simple SVG icon that can be converted to PNG
// Note: Expo prefers PNG, but SVG can work as a starting point
const svgIcon = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="1024" height="1024" rx="200" fill="#FF6B35"/>
  
  <!-- Fuel Pump Icon -->
  <g transform="translate(512, 512)">
    <!-- Pump Base -->
    <rect x="-120" y="200" width="240" height="300" rx="20" fill="#FFFFFF" opacity="0.9"/>
    
    <!-- Pump Nozzle -->
    <rect x="-40" y="100" width="80" height="120" rx="10" fill="#FFFFFF" opacity="0.9"/>
    
    <!-- Pump Handle -->
    <rect x="-20" y="50" width="40" height="60" rx="5" fill="#FFFFFF" opacity="0.9"/>
    
    <!-- Fuel Drop -->
    <ellipse cx="0" cy="-100" rx="60" ry="80" fill="#FFFFFF" opacity="0.9"/>
    <ellipse cx="0" cy="-80" rx="40" ry="60" fill="#FF6B35"/>
    
    <!-- Text "FM" -->
    <text x="0" y="350" font-family="Arial, sans-serif" font-size="120" font-weight="bold" fill="#FFFFFF" text-anchor="middle">FM</text>
  </g>
</svg>`;

// Write SVG file
const svgPath = path.join(assetsDir, 'icon.svg');
fs.writeFileSync(svgPath, svgIcon);

console.log('✅ Created icon.svg in assets folder');
console.log('');
console.log('📝 Note: Expo prefers PNG format for app icons.');
console.log('   You can convert this SVG to PNG using:');
console.log('   - Online tools: https://cloudconvert.com/svg-to-png');
console.log('   - Or install sharp: npm install --save-dev sharp');
console.log('   - Then run: node convert-icon.js');
console.log('');
console.log('   For now, you can also manually create a 1024x1024 PNG icon');
console.log('   and save it as assets/icon.png');

