// Test file to verify API connection
// Run with: dart test_api_connection.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Testing API Connection...\n');
  
  try {
    // Test 1: Get all posts
    print('1. Testing GET /api/posts/get...');
    final response = await HttpClient().getUrl(Uri.parse('http://localhost:3000/api/posts/get'))
        .then((request) => request.close());
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      print('✅ Success: ${data['data']?.length ?? 0} posts found');
    } else {
      print('❌ Failed: HTTP ${response.statusCode}');
    }
    
    // Test 2: Create a test post
    print('\n2. Testing POST /api/posts...');
    final request = await HttpClient().postUrl(Uri.parse('http://localhost:3000/api/posts'));
    request.headers.set('Content-Type', 'application/json');
    request.write(json.encode({
      'title': 'Test Volunteer Request',
      'description': 'This is a test volunteer request from Flutter app',
      'dateTime': DateTime.now().toIso8601String(),
      'reward': 'Test reward',
      'userId': 1
    }));
    
    final createResponse = await request.close();
    if (createResponse.statusCode == 201) {
      print('✅ Success: Post created');
    } else {
      final errorBody = await createResponse.transform(utf8.decoder).join();
      print('❌ Failed: ${json.decode(errorBody)['error']}');
    }
    
    print('\n✅ API connection test completed!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
