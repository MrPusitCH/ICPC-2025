/// Profile service for the Neighbor app
/// Handles API calls for user profile data
library;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class ProfileService {
  static const String baseUrl = 'http://localhost:3000/api'; // Use 10.0.2.2 for Android emulator, or your computer's IP for physical device
  
  /// Get user profile from API
  static Future<UserProfile> getUserProfile(int userId) async {
    try {
      final url = '$baseUrl/profile/$userId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        // Handle both direct object response and wrapped response
        Map<String, dynamic> data;
        if (responseData is Map<String, dynamic>) {
          // Check if it's wrapped in success/data structure
          if (responseData.containsKey('success') && responseData.containsKey('data')) {
            data = responseData['data'] as Map<String, dynamic>;
          } else {
            // Direct object response
            data = responseData;
          }
        } else {
          throw Exception('Invalid response format: expected Map but got ${responseData.runtimeType}');
        }
        
        final profile = UserProfile.fromJson(data);
        return profile;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  /// Update user profile via API
  static Future<bool> updateUserProfile(int userId, UserProfile profile) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'full_name': profile.name,
          'nickname': profile.nickname,
          'gender': profile.gender,
          'address': profile.address,
          'profile_image_url': profile.avatarUrl,
          'health_conditions': profile.diseases.map((d) => d.text).toList(),
          'emergency_contacts': profile.emergencyContacts?.map((e) => {
            'name': e.name,
            'phone': e.phone,
            'relationship': e.relationship,
          }).toList() ?? [],
          'interests': profile.interests?.map((i) => i.text).toList() ?? [],
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
