/// Volunteer support service for the Neighbor app
/// Handles API calls for supporting volunteer requests
library;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class VolunteerSupportService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Support a volunteer request
  static Future<bool> supportVolunteerRequest(int postId) async {
    try {
      final token = await AuthService.getCurrentUserToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/volunteer/support'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'postId': postId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to support volunteer request');
      }
    } catch (e) {
      throw Exception('Error supporting volunteer request: $e');
    }
  }

  /// Unsupport a volunteer request
  static Future<bool> unsupportVolunteerRequest(int postId) async {
    try {
      final token = await AuthService.getCurrentUserToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/volunteer/support'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'postId': postId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to unsupport volunteer request');
      }
    } catch (e) {
      throw Exception('Error unsupporting volunteer request: $e');
    }
  }

  /// Check if user has supported a volunteer request
  static Future<bool> hasSupportedVolunteerRequest(int postId) async {
    try {
      final token = await AuthService.getCurrentUserToken();
      if (token == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/volunteer/support?postId=$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['supported'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get support count for a volunteer request
  static Future<int> getSupportCount(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/post_volunteer/post/$postId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['support_count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }
}
