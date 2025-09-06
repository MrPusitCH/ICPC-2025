import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/volunteer_item.dart';
import 'auth_service.dart';

class PostsApiService {
  // Always use localhost as requested
  static const String baseUrl = 'http://localhost:3000/api';
  
  /// Get all posts (volunteer requests) from API
  static Future<List<Volunteer>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/post_volunteer/get_post_all'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> posts = data['data'];
          return posts.map((post) => _mapPostToVolunteer(post)).toList();
        } else {
          throw Exception('Failed to fetch posts: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch posts: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get a single post by ID
  static Future<Volunteer> getPostById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/post_volunteer/get_post_byid/id/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return _mapPostToVolunteer(data['data']);
        } else {
          throw Exception('Failed to fetch post: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch post: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Create a new post (volunteer request)
  static Future<Volunteer> createPost({
    required String title,
    required String description,
    required String dateTime,
    String? reward,
  }) async {
    try {
      // Get current user ID from auth service
      final userId = await AuthService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final requestBody = {
        'title': title,
        'description': description,
        'dateTime': dateTime,
        'reward': reward,
        'userId': userId,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/post_volunteer/post'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return _mapPostToVolunteer(data['data']);
        } else {
          throw Exception('Failed to create post: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to create post: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Delete a post (volunteer request)
  static Future<bool> deletePost(String id) async {
    try {
      print('PostsApiService: Deleting post with ID: $id');
      
      // Get current user token for authorization
      final token = await AuthService.getCurrentUserToken();
      print('PostsApiService: Token: ${token != null ? "Present" : "Null"}');
      
      final url = '$baseUrl/post_volunteer/delete_post/$id';
      print('PostsApiService: URL: $url');
      
      // Prepare headers
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      // Add authorization header if token exists
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      
      print('PostsApiService: Response status: ${response.statusCode}');
      print('PostsApiService: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final success = data['success'] == true;
        print('PostsApiService: Delete success: $success');
        return success;
      } else if (response.statusCode == 401) {
        print('PostsApiService: Unauthorized - user not logged in');
        throw Exception('You must be logged in to delete posts');
      } else if (response.statusCode == 403) {
        print('PostsApiService: Forbidden - user cannot delete this post');
        throw Exception('You can only delete your own posts');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('PostsApiService: Delete error: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
        throw Exception('Failed to delete post: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      print('PostsApiService: Delete exception: $e');
      rethrow;
    }
  }
  
  /// Map API post data to Volunteer model
  static Volunteer _mapPostToVolunteer(Map<String, dynamic> post) {
    final user = post['user'] ?? {};
    final profile = user['profile'] ?? {};
    
    return Volunteer(
      id: post['post_id'].toString(),
      userId: post['user_id'] ?? 0,
      requesterName: profile['full_name'] ?? user['email'] ?? 'Unknown User',
      title: post['title'] ?? '',
      description: post['description'] ?? '',
      timeAgo: _formatTimeAgo(DateTime.parse(post['created_at'])),
      dateTime: _formatDateTime(DateTime.parse(post['dateTime'])),
      reward: post['reward'] ?? 'No reward',
      avatarUrl: profile['profile_image_url'] ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      comments: 0, // TODO: Add comments count when available
      views: 0, // TODO: Add views count when available
    );
  }
  
  /// Format DateTime to time ago string
  static String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'just now';
    }
  }
  
  /// Format DateTime to readable string
  static String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[dateTime.month - 1]}. ${dateTime.day}, ${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
