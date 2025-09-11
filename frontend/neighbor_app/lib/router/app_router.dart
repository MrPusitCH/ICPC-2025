/// App router configuration for the Neighbor app
/// Contains named routes and navigation helpers
/// 
/// This class provides a centralized way to manage app navigation
/// and route definitions for better maintainability
library;

import 'package:flutter/material.dart';
import '../screens/activity/activity_detail_screen.dart';
import '../screens/activity/activity_create_screen.dart';
import '../screens/community/community_detail_screen.dart';
import '../screens/community/community_create_screen.dart';
import '../screens/news/news_detail_screen.dart';
import '../screens/news/news_create_screen.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/volunteer/volunteer_detail_screen.dart';
import '../screens/volunteer/volunteer_create_screen.dart';
import '../screens/main_app_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

/// Centralized router class for managing app navigation
/// 
/// This class defines all route constants and provides navigation methods
/// to ensure consistent routing throughout the application
class AppRouter {
  // ============================================================================
  // ROUTE CONSTANTS
  // Define all available routes as constants to prevent typos and ensure consistency
  // ============================================================================
  
  /// Main app routes
  static const String home = '/';
  static const String main = '/main';
  static const String login = '/login';
  static const String register = '/register';
  
  /// Activity-related routes
  static const String activityDetail = '/activity/detail';
  static const String activityCreate = '/activity/create';
  
  /// Community-related routes
  static const String communityDetail = '/community/detail';
  static const String communityCreate = '/community/create';
  
  /// News-related routes
  static const String newsDetail = '/news/detail';
  static const String newsCreate = '/news/create';
  
  /// Profile-related routes
  static const String profileEdit = '/profile/edit';
  
  /// Settings route
  static const String settings = '/settings';
  
  /// Volunteer-related routes
  static const String volunteerDetail = '/volunteer/detail';
  static const String volunteerCreate = '/volunteer/create';

  // ============================================================================
  // ROUTE MAPPING
  // Maps route constants to their corresponding screen widgets
  // ============================================================================
  
  /// Returns a map of all available routes and their corresponding widgets
  /// This is used by MaterialApp to register named routes
  static Map<String, WidgetBuilder> get routes => {
    // Main app routes
    main: (context) => const MainAppScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    
    // Activity routes
    activityDetail: (context) => const ActivityDetailScreen(),
    activityCreate: (context) => const ActivityCreateScreen(),
    
    // Community routes
    communityDetail: (context) => const CommunityDetailScreen(),
    communityCreate: (context) => const CommunityCreateScreen(),
    
    // News routes
    newsDetail: (context) => const NewsDetailScreen(),
    newsCreate: (context) => const NewsCreateScreen(),
    
    // Profile routes
    profileEdit: (context) => const ProfileEditScreen(),
    
    // Settings routes
    settings: (context) => const SettingsScreen(),
    
    // Volunteer routes
    volunteerDetail: (context) {
      // Get volunteer data from arguments
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['volunteer'] != null) {
        return VolunteerDetailScreen(
          volunteer: args['volunteer'],
          onDeleted: args['onDeleted'],
        );
      }
      // Fallback to a default screen if no arguments
      return const Scaffold(
        body: Center(child: Text('Volunteer not found')),
      );
    },
    volunteerCreate: (context) => const VolunteerCreateScreen(),
  };

  // ============================================================================
  // NAVIGATION METHODS
  // Helper methods for common navigation operations
  // ============================================================================
  
  /// Navigate to a named route with optional arguments
  /// 
  /// [context] - The build context
  /// [routeName] - The route to navigate to (use route constants)
  /// [arguments] - Optional data to pass to the destination screen
  /// 
  /// Returns a Future that completes when the route is popped
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigate to a named route and clear the navigation stack
  /// 
  /// This is useful for login/logout scenarios where you want to prevent
  /// users from going back to previous screens
  /// 
  /// [context] - The build context
  /// [routeName] - The route to navigate to
  /// [arguments] - Optional data to pass to the destination screen
  /// [predicate] - Function to determine which routes to remove from stack
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop the current route from the navigation stack
  /// 
  /// [context] - The build context
  /// [result] - Optional data to return to the previous screen
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Check if the current route can be popped
  /// 
  /// Returns true if there are routes in the stack that can be popped
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}
