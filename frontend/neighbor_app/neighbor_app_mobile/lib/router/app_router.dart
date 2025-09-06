/// App router configuration for the Neighbor app
/// Contains named routes and navigation helpers
import 'package:flutter/material.dart';
import '../screens/activity/activity_detail_screen.dart';
import '../screens/activity/activity_create_screen.dart';
import '../screens/community/community_detail_screen.dart';
import '../screens/community/community_create_screen.dart';
import '../screens/news/news_detail_screen.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String activityDetail = '/activity/detail';
  static const String activityCreate = '/activity/create';
  static const String communityDetail = '/community/detail';
  static const String communityCreate = '/community/create';
  static const String newsDetail = '/news/detail';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    activityDetail: (context) => const ActivityDetailScreen(),
    activityCreate: (context) => const ActivityCreateScreen(),
    communityDetail: (context) => const CommunityDetailScreen(),
    communityCreate: (context) => const CommunityCreateScreen(),
    newsDetail: (context) => const NewsDetailScreen(),
    profileEdit: (context) => const ProfileEditScreen(),
    settings: (context) => const SettingsScreen(),
  };

  /// Navigate to a named route
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigate to a named route and clear the stack
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

  /// Pop the current route
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Check if we can pop the current route
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}
