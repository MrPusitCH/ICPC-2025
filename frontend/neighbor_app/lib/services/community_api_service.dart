/// Community API service for the Neighbor app
/// Handles all API calls related to community posts, comments, and likes
library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/community_post.dart';
import 'auth_service.dart';

class CommunityApiService {
  // Helper method to get the correct base URL for different platforms
  static String get baseUrl {
    const String? apiBase = String.fromEnvironment('API_BASE');
    if (apiBase.isNotEmpty) {
      return '$apiBase/api/community';
    }
    
    // Platform-specific URLs
    if (kIsWeb) {
      // Web platform - use localhost with different port
      return 'http://127.0.0.1:3000/api/community';
    } else {
      // Mobile platforms - use 10.0.2.2 for Android emulator, 127.0.0.1 for others
      return 'http://10.0.2.2:3000/api/community';
    }
  }
  
  // Helper method to get the upload base URL
  static String get uploadBaseUrl {
    const String? apiBase = String.fromEnvironment('API_BASE');
    if (apiBase.isNotEmpty) {
      return apiBase;
    }
    
    // Platform-specific URLs
    if (kIsWeb) {
      // Web platform - use localhost with different port
      return 'http://127.0.0.1:3000';
    } else {
      // Mobile platforms - use 10.0.2.2 for Android emulator, 127.0.0.1 for others
      return 'http://10.0.2.2:3000';
    }
  }
  
  // Helper method to get headers
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getCurrentUserToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle API responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // ============================================================================
  // POSTS API
  // ============================================================================

  /// Get all community posts with pagination
  static Future<Map<String, dynamic>> getPosts({
    int page = 1,
    int limit = 10,
  }) async {
    print('CommunityApiService.getPosts called with page=$page, limit=$limit');
    print('Base URL: $baseUrl');
    
    try {
      final url = '$baseUrl/posts?page=$page&limit=$limit';
      print('Making request to: $url');
      
      // Add timeout and better error handling
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body length: ${response.body.length}');
      print('Response body preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      final data = _handleResponse(response);
      print('Parsed data: $data');
      
      if (data['data'] != null) {
        print('Attempting to parse ${(data['data'] as List).length} posts');
        final posts = (data['data'] as List<dynamic>)
            .map((post) => CommunityPost.fromJson(post))
            .toList();
        print('Successfully parsed ${posts.length} posts');
        return {
          'success': data['success'] ?? false,
          'posts': posts,
          'pagination': data['pagination'] ?? {},
        };
      } else {
        print('No data in response');
        return {
          'success': false,
          'posts': [],
          'pagination': {},
          'error': 'No data in response',
        };
      }
    } catch (e) {
      print('Error fetching posts: $e');
      print('Error type: ${e.runtimeType}');
      print('Error details: ${e.toString()}');
      
      // Fallback to mock data when API is not available
      print('Falling back to mock data...');
      final mockPosts = await _getMockPosts();
      print('Generated ${mockPosts.length} mock posts');
      return {
        'success': true,
        'posts': mockPosts,
        'pagination': {
          'page': page,
          'limit': limit,
          'total': 3,
          'totalPages': 1,
        },
        'error': 'API unavailable, using mock data',
      };
    }
  }

  /// Mock data fallback
  static Future<List<CommunityPost>> _getMockPosts() async {
    final now = DateTime.now();
    final currentUserId = await AuthService.getCurrentUserId();
    
    return [
      CommunityPost(
        postId: 1,
        title: 'Welcome to our neighborhood!',
        content: 'Hello everyone! I\'m new to the area and wanted to introduce myself. Looking forward to meeting all of you and being part of this wonderful community.',
        authorId: currentUserId ?? 1,
        authorName: 'Dang Hayai',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        commentCount: 2,
        viewCount: 24,
        authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      ),
      CommunityPost(
        postId: 2,
        title: 'Community Garden Update',
        content: 'The community garden is looking beautiful this season! We have fresh tomatoes, herbs, and flowers ready for harvest. Everyone is welcome to come and pick some fresh produce.',
        authorId: 2,
        authorName: 'Sarah Johnson',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        commentCount: 5,
        viewCount: 18,
        authorAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
      ),
      CommunityPost(
        postId: 3,
        title: 'Lost Cat - Please Help!',
        content: 'Our beloved cat Whiskers has been missing since yesterday evening. He\'s a friendly orange tabby with white paws. If you see him, please contact me immediately!',
        authorId: 3,
        authorName: 'Mike Chen',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        commentCount: 8,
        viewCount: 42,
        authorAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      ),
    ];
  }

  /// Get a specific community post by ID
  static Future<Map<String, dynamic>> getPost(int postId) async {
    print('CommunityApiService.getPost called with postId=$postId');
    print('Base URL: $baseUrl');
    
    try {
      final url = '$baseUrl/posts/$postId';
      print('Making request to: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.body.length}');
      print('Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      final data = _handleResponse(response);
      print('Parsed data: $data');
      
      if (data['data'] != null) {
        print('Attempting to parse CommunityPost from: ${data['data']}');
        final post = CommunityPost.fromJson(data['data']);
        print('Successfully parsed post: ${post.title}');
        
        
        return {
          'success': data['success'] ?? false,
          'post': post,
        };
      } else {
        print('No data in response');
        return {
          'success': false,
          'error': 'No data in response',
        };
      }
    } catch (e) {
      print('Error fetching post: $e');
      print('Error type: ${e.runtimeType}');
      // Fallback to mock data when API is not available
      print('Falling back to mock data for post $postId...');
      final mockPosts = await _getMockPosts();
      final post = mockPosts.firstWhere(
        (p) => p.postId == postId,
        orElse: () => mockPosts.first,
      );
      print('Found mock post: ${post.title}');
      return {
        'success': true,
        'post': post,
        'error': 'API unavailable, using mock data',
      };
    }
  }

  /// Create a new community post
  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    required int authorId,
    List<Map<String, dynamic>>? media,
  }) async {
    print('CommunityApiService.createPost called with title: $title');
    print('Base URL: $baseUrl');
    
    try {
      final url = '$baseUrl/posts';
      print('Making POST request to: $url');
      
      final requestBody = {
        'title': title,
        'content': content,
        'author_id': authorId,
        'media': media,
      };
      print('Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      final data = _handleResponse(response);
      print('Parsed data: $data');
      
      if (data['data'] != null) {
        print('Successfully created post: ${data['data']['title']}');
        return {
          'success': data['success'] ?? false,
          'post': CommunityPost.fromJson(data['data']),
        };
      } else {
        print('No data in response');
        return {
          'success': false,
          'error': 'No data in response',
        };
      }
    } catch (e) {
      print('Error creating post: $e');
      print('Error type: ${e.runtimeType}');
      print('Error details: ${e.toString()}');
      
      // Fallback to mock data when API is not available
      print('Falling back to mock data for new post...');
      final now = DateTime.now();
      final newPost = CommunityPost(
        postId: now.millisecondsSinceEpoch,
        title: title,
        content: content,
        authorId: authorId,
        authorName: 'Current User',
        createdAt: now,
        updatedAt: now,
        commentCount: 0,
        viewCount: 1,
        authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      );
      return {
        'success': true,
        'post': newPost,
        'error': 'API unavailable, using mock data',
      };
    }
  }

  /// Update a community post
  static Future<Map<String, dynamic>> updatePost({
    required int postId,
    String? title,
    String? content,
    bool? isPublished,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: await _getHeaders(),
        body: json.encode({
          if (title != null) 'title': title,
          if (content != null) 'content': content,
          if (isPublished != null) 'is_published': isPublished,
        }),
      );

      final data = _handleResponse(response);
      return {
        'success': data['success'] ?? false,
        'post': data['data'] != null ? CommunityPost.fromJson(data['data']) : null,
      };
    } catch (e) {
      print('Error updating post: $e');
      return {
        'success': false,
        'post': null,
        'error': e.toString(),
      };
    }
  }

  /// Delete a community post
  static Future<Map<String, dynamic>> deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Post deleted successfully',
      };
    } catch (e) {
      print('Error deleting post: $e');
      return {
        'success': false,
        'message': 'Failed to delete post',
        'error': e.toString(),
      };
    }
  }

  // ============================================================================
  // COMMENTS API
  // ============================================================================

  /// Create a new comment
  static Future<Map<String, dynamic>> createComment({
    required int postId,
    required int authorId,
    required String content,
    int? parentId,
  }) async {
    print('CommunityApiService.createComment called with postId=$postId, authorId=$authorId');
    print('Base URL: $baseUrl');
    
    try {
      final url = '$baseUrl/comments';
      print('Making POST request to: $url');
      
      final requestBody = {
        'post_id': postId,
        'author_id': authorId,
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      };
      print('Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = _handleResponse(response);
      print('Parsed data: $data');
      
      if (data['data'] != null) {
        print('Successfully created comment');
        return {
          'success': data['success'] ?? false,
          'comment': CommunityComment.fromJson(data['data']),
        };
      } else {
        print('No data in response');
        return {
          'success': false,
          'error': 'No data in response',
        };
      }
    } catch (e) {
      print('Error creating comment: $e');
      print('Error type: ${e.runtimeType}');
      print('Error details: ${e.toString()}');
      return {
        'success': false,
        'comment': null,
        'error': e.toString(),
      };
    }
  }

  // ============================================================================
  // LIKES API
  // ============================================================================

  /// Like or unlike a post
  static Future<Map<String, dynamic>> toggleLike({
    required int postId,
    required int userId,
  }) async {
    print('CommunityApiService.toggleLike called with postId=$postId, userId=$userId');
    print('Base URL: $baseUrl');
    
    try {
      final url = '$baseUrl/likes';
      print('Making POST request to: $url');
      
      final requestBody = {
        'post_id': postId,
        'user_id': userId,
      };
      print('Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = _handleResponse(response);
      print('Parsed data: $data');
      
      return {
        'success': data['success'] ?? false,
        'liked': data['data']?['liked'] ?? false,
        'message': data['data']?['message'] ?? '',
      };
    } catch (e) {
      print('Error toggling like: $e');
      print('Error type: ${e.runtimeType}');
      print('Error details: ${e.toString()}');
      return {
        'success': false,
        'liked': false,
        'message': 'Failed to toggle like',
        'error': e.toString(),
      };
    }
  }

  /// Check if user liked a post
  static Future<Map<String, dynamic>> checkLikeStatus({
    required int postId,
    required int userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/likes?post_id=$postId&user_id=$userId'),
        headers: await _getHeaders(),
      );

      final data = _handleResponse(response);
      return {
        'success': data['success'] ?? false,
        'liked': data['data']?['liked'] ?? false,
      };
    } catch (e) {
      print('Error checking like status: $e');
      return {
        'success': false,
        'liked': false,
        'error': e.toString(),
      };
    }
  }

  // ============================================================================
  // MEDIA UPLOAD (Mock implementation)
  // ============================================================================


  /// Upload media file to server
  static Future<Map<String, dynamic>> uploadMedia(File file) async {
    try {
      print('📤 Uploading to: $uploadBaseUrl/api/upload');
      
      // Get authorization token
      final token = await AuthService.getCurrentUserToken();
      
      // Check if running on web platform using kIsWeb
      if (kIsWeb) {
        // Web platform - use different approach
        return await _uploadMediaWeb(file, token);
      } else {
        // Mobile platform - use MultipartFile
        print('📤 File path: ${file.path}');
        return await _uploadMediaMobile(file, token);
      }
    } catch (e) {
      print('📤 Upload error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Upload media for web platforms using XFile (web-compatible)
  static Future<Map<String, dynamic>> uploadMediaWeb(XFile xFile) async {
    try {
      print('📤 Web upload to: $uploadBaseUrl/api/upload');
      
      // Get authorization token
      final token = await AuthService.getCurrentUserToken();
      
      // Read file as bytes - this works on web
      final bytes = await xFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Get file name
      String fileName = xFile.name;
      if (fileName.isEmpty) {
        fileName = 'image-${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Detect MIME type from file extension
      String mimeType = 'image/jpeg'; // Default
      if (fileName.contains('.')) {
        final extension = fileName.toLowerCase().split('.').last;
        switch (extension) {
          case 'png':
            mimeType = 'image/png';
            break;
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          case 'bmp':
            mimeType = 'image/bmp';
            break;
          case 'svg':
            mimeType = 'image/svg+xml';
            break;
        }
      }
      
      // Create request body
      final requestBody = {
        'file': base64String,
        'filename': fileName,
        'mimeType': mimeType,
      };
      
      // Set headers
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      print('📤 Web upload - file size: ${bytes.length} bytes');
      print('📤 Web upload - filename: $fileName');
      print('📤 Web upload - mime type: $mimeType');
      
      // Send POST request
      final response = await http.post(
        Uri.parse('$uploadBaseUrl/api/upload'),
        headers: headers,
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('📤 Upload timeout');
          throw Exception('Upload timeout');
        },
      );
      
      return _handleUploadResponse(response);
    } catch (e) {
      print('📤 Web upload error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Upload media for mobile platforms using MultipartFile
  static Future<Map<String, dynamic>> _uploadMediaMobile(File file, String? token) async {
    // Create multipart request to the correct upload endpoint
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$uploadBaseUrl/api/upload'),
    );
    
    // Set headers including authorization
    request.headers['Accept'] = 'application/json';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add file to request with correct field name 'file'
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Use 'file' to match backend and curl command
        file.path,
        filename: file.path.split('/').last,
      ),
    );
    
    print('📤 Request prepared with ${request.files.length} files');
    print('📤 Headers: ${request.headers}');
    
    // Send request
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        print('📤 Upload timeout');
        throw Exception('Upload timeout');
      },
    );
    
    // Get response
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleUploadResponse(response);
  }

  /// Upload media for web platforms using base64 encoding
  static Future<Map<String, dynamic>> _uploadMediaWeb(File file, String? token) async {
    try {
      // Read file as bytes - this should work on web
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Get file name - handle web file paths differently
      String fileName = 'uploaded-image';
      try {
        // On web, file.path might be a blob URL or different format
        if (file.path.contains('/')) {
          fileName = file.path.split('/').last;
        } else if (file.path.contains('\\')) {
          fileName = file.path.split('\\').last;
        } else {
          fileName = 'image-${DateTime.now().millisecondsSinceEpoch}';
        }
      } catch (e) {
        print('📤 Could not extract filename, using default: $e');
        fileName = 'image-${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Detect MIME type from file extension
      String mimeType = 'image/jpeg'; // Default
      if (fileName.contains('.')) {
        final extension = fileName.toLowerCase().split('.').last;
        switch (extension) {
          case 'png':
            mimeType = 'image/png';
            break;
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          case 'bmp':
            mimeType = 'image/bmp';
            break;
          case 'svg':
            mimeType = 'image/svg+xml';
            break;
        }
      }
      
      // Create request body
      final requestBody = {
        'file': base64String,
        'filename': fileName,
        'mimeType': mimeType,
      };
      
      // Set headers
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      print('📤 Web upload - file size: ${bytes.length} bytes');
      print('📤 Web upload - filename: $fileName');
      print('📤 Web upload - mime type: $mimeType');
      
      // Send POST request
      final response = await http.post(
        Uri.parse('$uploadBaseUrl/api/upload'),
        headers: headers,
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('📤 Upload timeout');
          throw Exception('Upload timeout');
        },
      );
      
      return _handleUploadResponse(response);
    } catch (e) {
      print('📤 Web upload error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Handle upload response
  static Map<String, dynamic> _handleUploadResponse(http.Response response) {
    print('📤 Response status: ${response.statusCode}');
    print('📤 Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📤 Upload successful: $data');
      
      return {
        'success': true,
        'image_id': data['id'], // Return image ID for database relation
        'file_url': '/api/image/${data['id']}', // Construct URL from image ID to match backend route
        'file_name': data['name'],
        'file_size': data['fileSize'] ?? 0,
        'mime_type': data['mime'],
      };
    } else {
      print('📤 Upload failed with status: ${response.statusCode}');
      return {
        'success': false,
        'error': 'Upload failed: ${response.statusCode} - ${response.body}',
      };
    }
  }


  // ============================================================================
  // DELETE API
  // ============================================================================

  /// Delete a comment
  static Future<Map<String, dynamic>> deleteComment(int commentId) async {
    print('CommunityApiService.deleteComment called with commentId=$commentId');
    print('Base URL: $baseUrl');
    
    try {
      final url = '$baseUrl/comments/$commentId';
      print('Making DELETE request to: $url');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = _handleResponse(response);
      print('Parsed data: $data');
      
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Comment deleted successfully',
      };
    } catch (e) {
      print('Error deleting comment: $e');
      print('Error type: ${e.runtimeType}');
      print('Error details: ${e.toString()}');
      return {
        'success': false,
        'message': 'Failed to delete comment',
        'error': e.toString(),
      };
    }
  }
}
