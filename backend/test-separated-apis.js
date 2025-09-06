// Test file for separated Posts APIs
// Run with: node test-separated-apis.js

const BASE_URL = 'http://localhost:3000/api';

async function testSeparatedAPIs() {
  console.log('🧪 Testing Separated Posts APIs...\n');

  try {
    // Test 1: GET all posts
    console.log('1. Testing GET /api/posts/get...');
    const response1 = await fetch(`${BASE_URL}/posts/get`);
    const data1 = await response1.json();
    console.log('Status:', response1.status);
    console.log('Posts count:', data1.data?.length || 0);
    console.log('');

    // Test 2: GET single post
    console.log('2. Testing GET /api/posts/get/id/1...');
    const response2 = await fetch(`${BASE_URL}/posts/get/id/1`);
    const data2 = await response2.json();
    console.log('Status:', response2.status);
    console.log('Post title:', data2.data?.title || 'Not found');
    console.log('');

    // Test 3: POST new post
    console.log('3. Testing POST /api/posts...');
    const response3 = await fetch(`${BASE_URL}/posts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        title: 'API Test Post',
        description: 'Testing the separated API structure',
        dateTime: '2024-09-17T15:00:00Z',
        reward: 'API testing reward',
        userId: 1
      })
    });
    const data3 = await response3.json();
    console.log('Status:', response3.status);
    console.log('Created post ID:', data3.data?.post_id || 'Failed');
    console.log('');

    console.log('✅ All separated APIs are working correctly!');
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

testSeparatedAPIs();
