const fs = require('fs');
const FormData = require('form-data');
const fetch = require('node-fetch');

async function testUpload() {
  try {
    console.log('🧪 Testing image upload endpoint...');
    
    // Create a simple test image (1x1 pixel PNG)
    const testImageBuffer = Buffer.from([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
      0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0x0F, 0x00, 0x00,
      0x01, 0x00, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xB4, 0x00, 0x00, 0x00, 0x00,
      0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ]);
    
    // Create form data
    const form = new FormData();
    form.append('image', testImageBuffer, {
      filename: 'test-image.png',
      contentType: 'image/png'
    });
    
    // Test upload
    const response = await fetch('http://localhost:3000/api/upload', {
      method: 'POST',
      body: form,
      headers: form.getHeaders()
    });
    
    console.log('📤 Upload response status:', response.status);
    console.log('📤 Upload response headers:', Object.fromEntries(response.headers.entries()));
    
    const result = await response.text();
    console.log('📤 Upload response body:', result);
    
    if (response.ok) {
      console.log('✅ Upload test successful!');
    } else {
      console.log('❌ Upload test failed!');
    }
    
  } catch (error) {
    console.error('❌ Upload test error:', error);
  }
}

// Test health endpoint first
async function testHealth() {
  try {
    console.log('🏥 Testing health endpoint...');
    const response = await fetch('http://localhost:3000/api/health');
    console.log('🏥 Health response status:', response.status);
    const result = await response.text();
    console.log('🏥 Health response body:', result);
  } catch (error) {
    console.error('❌ Health test error:', error);
  }
}

async function runTests() {
  await testHealth();
  console.log('\n' + '='.repeat(50) + '\n');
  await testUpload();
}

runTests();


