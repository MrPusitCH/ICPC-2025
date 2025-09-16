import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_item.dart';
import 'auth_service.dart';

class ActivityApiService {
  static const String baseUrl = 'http://localhost:3000/api/activity';

  static Future<List<ActivityItem>> getActivities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_all'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> activityList = data['data'];
          return activityList.map((json) => ActivityItem.fromJson(json)).toList();
        } else {
          throw Exception('Failed to fetch activities: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch activities: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<ActivityItem> getActivityById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_by_id/$id'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ActivityItem.fromJson(data['data']);
        } else {
          throw Exception('Failed to fetch activity: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch activity: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<ActivityItem> createActivity({
    required String title,
    required String description,
    required String date,
    required String time,
    required String place,
    required int capacity,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? imageName,
    String? endTime,
    String? category,
  }) async {
    try {
      final userId = await AuthService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final token = await AuthService.getCurrentUserToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        'title': title,
        'description': description,
        'date': date,
        'time': time,
        'place': place,
        'capacity': capacity,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
        'image_name': imageName,
        'author_id': userId,
        'end_time': endTime,
        'category': category,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ActivityItem.fromJson(data['data']);
        } else {
          throw Exception('Failed to create activity: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to create activity: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> updateActivity(int id, {
    String? title,
    String? description,
    String? date,
    String? time,
    String? place,
    int? capacity,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? imageName,
    String? endTime,
    String? category,
    bool? isActive,
  }) async {
    try {
      final token = await AuthService.getCurrentUserToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final requestBody = <String, dynamic>{};
      if (title != null) requestBody['title'] = title;
      if (description != null) requestBody['description'] = description;
      if (date != null) requestBody['date'] = date;
      if (time != null) requestBody['time'] = time;
      if (place != null) requestBody['place'] = place;
      if (capacity != null) requestBody['capacity'] = capacity;
      if (location != null) requestBody['location'] = location;
      if (latitude != null) requestBody['latitude'] = latitude;
      if (longitude != null) requestBody['longitude'] = longitude;
      if (imageUrl != null) requestBody['image_url'] = imageUrl;
      if (imageName != null) requestBody['image_name'] = imageName;
      if (endTime != null) requestBody['end_time'] = endTime;
      if (category != null) requestBody['category'] = category;
      if (isActive != null) requestBody['is_active'] = isActive;

      final response = await http.put(
        Uri.parse('$baseUrl/update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to update activity: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> deleteActivity(int id) async {
    try {
      final token = await AuthService.getCurrentUserToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to delete activity: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> joinActivity(int activityId) async {
    try {
      final userId = await AuthService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final token = await AuthService.getCurrentUserToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/join/$activityId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to join activity: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> leaveActivity(int activityId) async {
    try {
      final userId = await AuthService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final token = await AuthService.getCurrentUserToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/leave/$activityId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to leave activity: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> incrementViewCount(int activityId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/increment_view/$activityId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to increment view count: ${errorData['error'] ?? 'HTTP ${response.statusCode}'}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getActivityParticipants(int activityId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/participants/$activityId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Failed to fetch participants: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch participants: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}




