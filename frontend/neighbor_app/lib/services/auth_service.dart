import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String _userIdKey = 'current_user_id';
  static const String _userTokenKey = 'user_token';
  

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['data']?['user'];
        final token = data['data']?['token'];
        
        // Store user ID and token for future use
        if (user != null && user['user_id'] != null) {
          await _storeUserSession(user['user_id'], token);
        }
        
        return {
          'success': data['ok'] == true,
          'user': user,
          'token': token,
          'message': data['message'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>?> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String role = 'USER',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
          'phone': phone,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['ok'] == true,
          'user': data['data']?['user'],
          'token': data['data']?['token'],
          'message': data['message'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  /// Store user session data
  static Future<void> _storeUserSession(int userId, String? token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    if (token != null) {
      await prefs.setString(_userTokenKey, token);
    }
  }

  /// Get current user ID from stored session
  static Future<int?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_userIdKey);
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  /// Get current user token from stored session
  static Future<String?> getCurrentUserToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTokenKey);
    } catch (e) {
      print('Error getting current user token: $e');
      return null;
    }
  }

  /// Clear user session (logout)
  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userTokenKey);
    } catch (e) {
      print('Error clearing user session: $e');
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final userId = await getCurrentUserId();
    return userId != null;
  }

  /// Logout user
  static Future<void> logout() async {
    await clearUserSession();
  }
}
