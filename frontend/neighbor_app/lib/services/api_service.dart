/// API service for the Neighbor app
/// 
/// This service handles all communication with the backend API.
/// Currently uses mock data service as a placeholder until backend integration is complete.
/// 
/// All methods simulate network delays to provide realistic user experience.
library;

import '../models/news_item.dart';
import '../models/community_post.dart';
import '../models/activity_item.dart';
import '../models/volunteer_item.dart';
import '../models/user_profile.dart';
import 'mock_data_service.dart';

/// Central API service class for handling all backend communications
/// 
/// This class provides a clean interface for all API operations and
/// can be easily replaced with actual HTTP calls when backend is ready
class ApiService {
  // TODO: Replace with actual API calls when backend is ready
  // Consider using packages like dio or http for network requests
  
  // ============================================================================
  // READ OPERATIONS
  // Methods for fetching data from the API
  // ============================================================================
  
  /// Fetches all news items from the API
  /// 
  /// Returns a list of news items with simulated network delay
  /// In production, this would make an HTTP GET request to /api/news
  static Future<List<NewsItem>> getNewsItems() async {
    // Simulate API delay for realistic user experience
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getNewsItems();
  }

  /// Fetches all community posts from the API
  /// 
  /// Returns a list of community posts with simulated network delay
  /// In production, this would make an HTTP GET request to /api/community/posts
  static Future<List<CommunityPost>> getCommunityPosts() async {
    // Simulate API delay for realistic user experience
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getCommunityPosts();
  }

  /// Fetches all activity items from the API
  /// 
  /// Returns a list of activity items with simulated network delay
  /// In production, this would make an HTTP GET request to /api/activities
  static Future<List<ActivityItem>> getActivityItems() async {
    // Simulate API delay for realistic user experience
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getActivityItems();
  }

  /// Fetches all volunteer opportunities from the API
  /// 
  /// Returns a list of volunteer items with simulated network delay
  /// In production, this would make an HTTP GET request to /api/volunteers
  static Future<List<Volunteer>> getVolunteerItems() async {
    // Simulate API delay for realistic user experience
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getVolunteerItems();
  }

  /// Fetches the current user's profile from the API
  /// 
  /// Returns user profile data with simulated network delay
  /// In production, this would make an HTTP GET request to /api/user/profile
  static Future<UserProfile> getUserProfile() async {
    // Simulate API delay for realistic user experience
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDataService.getUserProfile();
  }

  // ============================================================================
  // WRITE OPERATIONS
  // Methods for creating and updating data via the API
  // ============================================================================
  
  /// Creates a new community post
  /// 
  /// [title] - The title of the post
  /// [body] - The content/body of the post
  /// 
  /// Returns the created post with simulated network delay
  /// In production, this would make an HTTP POST request to /api/community/posts
  static Future<CommunityPost> createCommunityPost({
    required String title,
    required String body,
  }) async {
    // Simulate API delay for realistic user experience
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Return mock created post
    return CommunityPost(
      postId: DateTime.now().millisecondsSinceEpoch,
      title: 'New Post',
      content: 'This is a new post created by the user.',
      authorId: 1,
      authorName: 'Current User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      commentCount: 0,
      viewCount: 1,
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
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
      userId: 1, // Mock user ID
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

