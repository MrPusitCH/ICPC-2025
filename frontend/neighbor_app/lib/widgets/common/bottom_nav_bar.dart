import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xFF1E88E5), // Blue color
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
      ),
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home, size: 24),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline, size: 24),
          activeIcon: Icon(Icons.people, size: 24),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined, size: 24),
          activeIcon: Icon(Icons.event, size: 24),
          label: 'Activity',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism_outlined, size: 24),
          activeIcon: Icon(Icons.volunteer_activism, size: 24),
          label: 'Volunteer',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'Profile',
        ),
      ],
    );
  }
}