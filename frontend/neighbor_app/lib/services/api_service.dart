/// API service for the Neighbor app
/// Placeholder for future backend integration
library;
import '../models/news_item.dart';
import '../models/community_post.dart';
import '../models/activity_item.dart';
import '../models/volunteer_item.dart';
import '../models/user_profile.dart';
import 'mock_data_service.dart';

class ApiService {
  // TODO: Replace with actual API calls when backend is ready
  
  /// Get news items from API
  static Future<List<NewsItem>> getNewsItems() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getNewsItems();
  }

  /// Get community posts from API
  static Future<List<CommunityPost>> getCommunityPosts() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getCommunityPosts();
  }

  /// Get activity items from API
  static Future<List<ActivityItem>> getActivityItems() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getActivityItems();
  }

  /// Get volunteer items from API
  static Future<List<Volunteer>> getVolunteerItems() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getVolunteerItems();
  }

  /// Get user profile from API
  static Future<UserProfile> getUserProfile() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getUserProfile();
  }

  /// Create a new community post
  static Future<CommunityPost> createCommunityPost({
    required String title,
    required String body,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Return mock created post
    return const CommunityPost(
      userName: 'Current User',
      timeAgo: 'just now',
      title: 'New Post',
      body: 'This is a new post created by the user.',
      comments: 0,
      views: 1,
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
    );
  }

  /// Create a new activity
  static Future<ActivityItem> createActivity({
    required String title,
    required String description,
    required String date,
    required String time,
    required String place,
    required int capacity,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Return mock created activity
    return const ActivityItem(
      userName: 'Current User',
      timeAgo: 'just now',
      title: 'New Activity',
      description: 'This is a new activity created by the user.',
      date: 'Sep. 25, 2025',
      time: '10:00 - 12:00',
      place: 'Community Center',
      joined: 1,
      capacity: 10,
      comments: 0,
      views: 1,
      imageUrl: 'https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=400&h=300&fit=crop',
    );
  }

  /// Create a new volunteer request
  static Future<Volunteer> createVolunteerRequest({
    required String title,
    required String description,
    required String dateTime,
    required String reward,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Return mock created volunteer request
    return const Volunteer(
      id: 'new',
      requesterName: 'Current User',
      title: 'New Volunteer Request',
      description: 'This is a new volunteer request created by the user.',
      timeAgo: 'just now',
      dateTime: 'Sep. 25, 2025 10:00 - 12:00',
      reward: '฿500',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      comments: 0,
      views: 1,
    );
  }
}

