import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_item.dart';
import 'auth_service.dart';

class NewsApiService {
  // Always use localhost as requested
  static const String baseUrl = 'http://localhost:3000/api';
  
  /// Get all news/announcements from API
  static Future<List<NewsItem>> getNews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news/get_all'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> news = data['data'];
          return news.map((item) => NewsItem.fromJson(item)).toList();
        } else {
          throw Exception('Failed to fetch news: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch news: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get a single news item by ID
  static Future<NewsItem> getNewsById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news/get_by_id/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return NewsItem.fromJson(data['data']);
        } else {
          throw Exception('Failed to fetch news: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch news: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Create a new news/announcement
  static Future<NewsItem> createNews({
    required String title,
    required String content,
    required String priority,
    String? imageUrl,
    String? imageName,
    String? dateTime,
    String? disclaimer,
  }) async {
    try {
      // Get current user ID from auth service
      final userId = await AuthService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final requestBody = {
        'title': title,
        'content': content,
        'priority': priority,
        'image_url': imageUrl,
        'image_name': imageName,
        'date_time': dateTime,
        'disclaimer': disclaimer,
        'author_id': userId,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/news/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return NewsItem.fromJson(data['data']);
        } else {
          throw Exception('Failed to create news: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to create news: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Update a news item
  static Future<NewsItem> updateNews({
    required String id,
    required String title,
    required String content,
    required String priority,
    String? imageUrl,
    String? imageName,
    String? dateTime,
    String? disclaimer,
  }) async {
    try {
      // Get current user token for authorization
      final token = await AuthService.getCurrentUserToken();
      
      final requestBody = {
        'title': title,
        'content': content,
        'priority': priority,
        'image_url': imageUrl,
        'image_name': imageName,
        'date_time': dateTime,
        'disclaimer': disclaimer,
      };
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.put(
        Uri.parse('$baseUrl/news/update/$id'),
        headers: headers,
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return NewsItem.fromJson(data['data']);
        } else {
          throw Exception('Failed to update news: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to update news: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Delete a news item
  static Future<bool> deleteNews(String id) async {
    try {
      print('NewsApiService: Deleting news with ID: $id');
      
      // Get current user token for authorization
      final token = await AuthService.getCurrentUserToken();
      print('NewsApiService: Token: ${token != null ? "Present" : "Null"}');
      
      final url = '$baseUrl/news/delete/$id';
      print('NewsApiService: URL: $url');
      
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
      
      print('NewsApiService: Response status: ${response.statusCode}');
      print('NewsApiService: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final success = data['success'] == true;
        print('NewsApiService: Delete success: $success');
        return success;
      } else if (response.statusCode == 401) {
        print('NewsApiService: Unauthorized - user not logged in');
        throw Exception('You must be logged in to delete news');
      } else if (response.statusCode == 403) {
        print('NewsApiService: Forbidden - user cannot delete this news');
        throw Exception('You can only delete your own news');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('NewsApiService: Delete error: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
        throw Exception('Failed to delete news: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      print('NewsApiService: Delete exception: $e');
      rethrow;
    }
  }
  
  /// Increment view count for a news item
  static Future<void> incrementViewCount(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/news/increment_view/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        print('Failed to increment view count for news $id');
      }
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }
}
