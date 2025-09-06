import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Mock user data for testing
  static const Map<String, String> mockUsers = {
    'elder.john@example.com': 'password123',
    'volunteer.sarah@example.com': 'password123',
    'organizer.mike@example.com': 'password123',
    'user.emma@example.com': 'password123',
    'admin@icpc.com': 'password123',
  };

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

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static String _getUserRole(String email) {
    if (email.contains('elder')) return 'ELDER';
    if (email.contains('volunteer')) return 'VOLUNTEER';
    if (email.contains('organizer')) return 'ORGANIZER';
    if (email.contains('admin')) return 'ADMIN';
    return 'USER';
  }

  static String _getUserName(String email) {
    if (email.contains('elder')) return 'John Smith';
    if (email.contains('volunteer')) return 'Sarah Johnson';
    if (email.contains('organizer')) return 'Mike Chen';
    if (email.contains('admin')) return 'Admin User';
    return 'Emma Wilson';
  }
}
