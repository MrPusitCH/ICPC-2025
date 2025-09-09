/// Community API service for the Neighbor app
/// Handles all API calls related to community posts, comments, and likes
library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/community_post.dart';

class CommunityApiService {
  // TODO: Replace with your actual backend URL
  static const String baseUrl = 'http://localhost:3000/api/community';
  
  // Helper method to get headers
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      // TODO: Add authentication token when available
      // 'Authorization': 'Bearer $token',
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
        headers: _getHeaders(),
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
      final mockPosts = _getMockPosts();
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
  static List<CommunityPost> _getMockPosts() {
    final now = DateTime.now();
    return [
      CommunityPost(
        postId: 1,
        title: 'Welcome to our neighborhood!',
        content: 'Hello everyone! I\'m new to the area and wanted to introduce myself. Looking forward to meeting all of you and being part of this wonderful community.',
        authorId: 1,
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
        headers: _getHeaders(),
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
      final mockPosts = _getMockPosts();
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
        headers: _getHeaders(),
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
        headers: _getHeaders(),
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
        headers: _getHeaders(),
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
        headers: _getHeaders(),
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
        headers: _getHeaders(),
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
        headers: _getHeaders(),
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

  /// Upload media file (mock implementation)
  /// In a real app, this would upload to a file storage service
  static Future<Map<String, dynamic>> uploadMedia(File file) async {
    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock response - in real app, this would return actual file URL
      return {
        'success': true,
        'file_url': 'https://example.com/uploads/${file.path.split('/').last}',
        'file_name': file.path.split('/').last,
        'file_size': await file.length(),
        'mime_type': 'image/jpeg', // You could detect this from file extension
      };
    } catch (e) {
      print('Error uploading media: $e');
      return {
        'success': false,
        'error': e.toString(),
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
        headers: _getHeaders(),
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
