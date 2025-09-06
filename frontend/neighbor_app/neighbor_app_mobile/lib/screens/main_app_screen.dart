import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'volunteer/volunteer_list_screen.dart';
import 'activity/activity_list_screen.dart';
import 'community/community_feed_screen.dart';
import 'news/news_list_screen.dart';
import 'profile/profile_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 3; // Default to News tab (now index 3 after removing notifications)

  final List<Widget> _screens = [
    const VolunteerListScreen(),
    const ActivityListScreen(),
    const CommunityFeedScreen(),
    const NewsListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.greyText,
        selectedLabelStyle: AppTheme.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.labelSmall,
        backgroundColor: AppTheme.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined, size: 24),
            activeIcon: Icon(Icons.volunteer_activism, size: 24),
            label: 'Volunteer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined, size: 24),
            activeIcon: Icon(Icons.event, size: 24),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 24),
            activeIcon: Icon(Icons.people, size: 24),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined, size: 24),
            activeIcon: Icon(Icons.newspaper, size: 24),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            activeIcon: Icon(Icons.person, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTheme.titleMedium,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppTheme.greyText,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              '$title Screen',
              style: AppTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Coming Soon',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
