import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Custom bottom navigation widget that matches the design specification
/// Features horizontal layout with icons above text labels
class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final int? notificationCount; // For profile notification badge

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.volunteer_activism_outlined,
            activeIcon: Icons.volunteer_activism,
            label: 'Volunteer',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.event_outlined,
            activeIcon: Icons.event,
            label: 'Activity',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Community',
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.newspaper_outlined,
            activeIcon: Icons.newspaper,
            label: 'News',
          ),
          _buildNavItem(
            index: 4,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool showBadge = false,
    String? badgeText,
  }) {
    final isSelected = selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: const Color(0xFFE0E0E0),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with optional badge
              Stack(
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 24,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.greyText,
                  ),
                  if (showBadge)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badgeText ?? 'R',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.greyText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
