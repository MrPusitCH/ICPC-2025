import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String _userIdKey = 'current_user_id';
  static const String _userTokenKey = 'user_token';
  static const String _userRoleKey = 'current_user_role';
  static const String _userNameKey = 'current_user_name';
  static const String _userAvatarKey = 'current_user_avatar';
  

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
        
        // Store user ID, role, token, name, and avatar for future use
        if (user != null && user['user_id'] != null) {
          await _storeUserSession(
            user['user_id'], 
            token, 
            user['role'],
            user['name'],
            user['profile']?['profile_image_url']
          );
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
  static Future<void> _storeUserSession(int userId, String? token, String? role, String? name, String? avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    if (token != null) {
      await prefs.setString(_userTokenKey, token);
    }
    if (role != null) {
      await prefs.setString(_userRoleKey, role);
    }
    if (name != null) {
      await prefs.setString(_userNameKey, name);
    }
    if (avatar != null) {
      await prefs.setString(_userAvatarKey, avatar);
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

  /// Get current user role from stored session
  static Future<String?> getCurrentUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userRoleKey);
    } catch (e) {
      print('Error getting current user role: $e');
      return null;
    }
  }

  /// Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    final role = await getCurrentUserRole();
    return role == 'ADMIN';
  }

  /// Get current user's display name
  static Future<String> getCurrentUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_user_name') ?? 'User';
    } catch (e) {
      print('Error getting current user name: $e');
      return 'User';
    }
  }

  /// Get current user's avatar URL
  static Future<String?> getCurrentUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_user_avatar');
    } catch (e) {
      print('Error getting current user avatar: $e');
      return null;
    }
  }

  /// Clear user session (logout)
  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userTokenKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userAvatarKey);
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
