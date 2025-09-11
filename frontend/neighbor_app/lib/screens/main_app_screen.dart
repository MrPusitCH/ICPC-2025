import 'package:flutter/material.dart';
import '../widgets/common/custom_bottom_navigation.dart';
import 'volunteer/volunteer_list_screen.dart';
import 'activity/activity_list_screen.dart';
import 'community/community_feed_screen.dart';
import 'news/news_list_screen.dart';
import 'profile/profile_screen.dart';

/// Main application screen that contains the bottom navigation bar
/// and manages the different app sections (Volunteer, Activity, Community, News, Profile)
/// 
/// This screen uses IndexedStack to maintain state across tab switches
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  /// Currently selected tab index (0-4)
  /// 0: Volunteer, 1: Activity, 2: Community, 3: News, 4: Profile
  int _selectedIndex = 0; // Default to Volunteer tab

  /// List of all main app screens in the same order as bottom navigation items
  /// IndexedStack maintains the state of each screen when switching tabs
  final List<Widget> _screens = [
    const VolunteerListScreen(),
    const ActivityListScreen(),
    const CommunityFeedScreen(),
    const NewsListScreen(),
    const ProfileScreen(),
  ];

  /// Get the title for the current tab
  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Volunteer';
      case 1:
        return 'Activity';
      case 2:
        return 'Community';
      case 3:
        return 'News';
      case 4:
        return 'Profile';
      default:
        return 'Volunteer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3F7), // Light blue background
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu pressed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      // Use IndexedStack to maintain state across tab switches
      // Only the selected screen is built and displayed
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // Custom bottom navigation bar for main app sections
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}