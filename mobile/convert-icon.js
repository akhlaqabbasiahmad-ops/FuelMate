// Convert SVG icon to PNG using sharp
// Run: npm install --save-dev sharp (if not already installed)
// Then: node convert-icon.js

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const svgPath = path.join(__dirname, 'assets', 'icon.svg');
const pngPath = path.join(__dirname, 'assets', 'icon.png');

if (!fs.existsSync(svgPath)) {
  console.error('❌ icon.svg not found. Run generate-icon.js first.');
  process.exit(1);
}

sharp(svgPath)
  .resize(1024, 1024)
  .png()
  .toFile(pngPath)
  .then(() => {
    console.log('✅ Successfully created icon.png (1024x1024)');
    console.log('   Location: assets/icon.png');
  })
  .catch((err) => {
    console.error('❌ Error converting icon:', err.message);
    console.log('');
    console.log('💡 Alternative: Install sharp first:');
    console.log('   npm install --save-dev sharp');
    process.exit(1);
  });

