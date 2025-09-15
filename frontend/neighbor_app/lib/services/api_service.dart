/// API service for the Neighbor app
/// 
/// This service is deprecated and should not be used.
/// All methods have been moved to specific API services:
/// - NewsApiService for news operations
/// - CommunityApiService for community post operations
/// - ActivityApiService for activity operations
/// - VolunteerApiService for volunteer operations
/// - ProfileService for user profile operations
library;

import '../models/news_item.dart';
import '../models/community_post.dart';
import '../models/activity_item.dart';
import '../models/volunteer_item.dart';
import '../models/user_profile.dart';

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
    // This method is deprecated - use NewsApiService instead
    throw UnimplementedError('Use NewsApiService.getNewsItems() instead');
  }

  /// Fetches all community posts from the API
  /// 
  /// Returns a list of community posts with simulated network delay
  /// In production, this would make an HTTP GET request to /api/community/posts
  static Future<List<CommunityPost>> getCommunityPosts() async {
    // This method is deprecated - use CommunityApiService instead
    throw UnimplementedError('Use CommunityApiService.getCommunityPosts() instead');
  }

  /// Fetches all activity items from the API
  /// 
  /// Returns a list of activity items with simulated network delay
  /// In production, this would make an HTTP GET request to /api/activities
  static Future<List<ActivityItem>> getActivityItems() async {
    // This method is deprecated - use ActivityApiService instead
    throw UnimplementedError('Use ActivityApiService.getActivities() instead');
  }

  /// Fetches all volunteer opportunities from the API
  /// 
  /// Returns a list of volunteer items with simulated network delay
  /// In production, this would make an HTTP GET request to /api/volunteers
  static Future<List<Volunteer>> getVolunteerItems() async {
    // This method is deprecated - use VolunteerApiService instead
    throw UnimplementedError('Use VolunteerApiService.getVolunteerPosts() instead');
  }

  /// Fetches the current user's profile from the API
  /// 
  /// Returns user profile data with simulated network delay
  /// In production, this would make an HTTP GET request to /api/user/profile
  static Future<UserProfile> getUserProfile() async {
    // This method is deprecated - use ProfileService instead
    throw UnimplementedError('Use ProfileService.getUserProfile() instead');
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
    // This method is deprecated - use CommunityApiService instead
    throw UnimplementedError('Use CommunityApiService.createPost() instead');
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
    // This method is deprecated - use ActivityApiService instead
    throw UnimplementedError('Use ActivityApiService.createActivity() instead');
  }

  /// Create a new volunteer request
  static Future<Volunteer> createVolunteerRequest({
    required String title,
    required String description,
    required String dateTime,
    required String reward,
  }) async {
    // This method is deprecated - use VolunteerApiService instead
    throw UnimplementedError('Use VolunteerApiService.createVolunteerPost() instead');
  }
}

