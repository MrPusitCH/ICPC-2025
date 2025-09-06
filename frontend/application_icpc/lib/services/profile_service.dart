/// Profile service for the Neighbor app
/// Handles API calls for user profile data
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class ProfileService {
  static const String baseUrl = 'http://localhost:3000/api'; // Use 10.0.2.2 for Android emulator, or your computer's IP for physical device
  
  /// Get user profile from API
  static Future<UserProfile> getUserProfile(int userId) async {
    try {
      final url = '$baseUrl/profile?userId=$userId';
      print('ProfileService: Making request to $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('ProfileService: Response status: ${response.statusCode}');
      print('ProfileService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('ProfileService: Error occurred: $e');
      throw Exception('Error fetching profile: $e');
    }
  }

  /// Update user profile via API
  static Future<bool> updateUserProfile(int userId, UserProfile profile) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'name': profile.name,
          'nickname': profile.nickname,
          'gender': profile.gender,
          'address': profile.address,
          'avatarUrl': profile.avatarUrl,
          'diseases': profile.diseases.map((d) => {
            'text': d.text,
            'icon': d.icon.toString(),
          }).toList(),
          'livingSituation': profile.livingSituation.map((l) => {
            'text': l.text,
            'icon': l.icon.toString(),
          }).toList(),
          'interests': profile.interests?.map((i) => {
            'text': i.text,
            'icon': i.icon.toString(),
          }).toList() ?? [],
          'emergencyContacts': profile.emergencyContacts?.map((e) => {
            'name': e.name,
            'phone': e.phone,
            'relationship': e.relationship,
          }).toList() ?? [],
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
