import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/app_theme.dart';
import '../../models/volunteer_item.dart';
import '../../widgets/common/location_map_widget.dart';
import 'volunteer_create_screen.dart';
import '../../services/auth_service.dart';
import 'volunteer_detail_screen.dart';

class VolunteerListScreen extends StatefulWidget {
  const VolunteerListScreen({super.key});

  @override
  State<VolunteerListScreen> createState() => _VolunteerListScreenState();
}

class _VolunteerListScreenState extends State<VolunteerListScreen> {
  bool _supported = false;
  String? _supporterName;
  // Mock volunteer data
  final Volunteer _mockVolunteer = Volunteer(
    id: '1',
    title: 'Could you help me take me to the hospital?',
    description: 'I have weak legs and cannot drive, so it is difficult for me to go to the hospital by myself. Please take me to the hospital and accompany with me while I\'m meeting the doctor.',
    requesterName: 'Dang Hayai',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    timeAgo: '1 hours ago',
    dateTime: 'Sep. 19, 2025, 12:00 - undecided',
    reward: '500 points',
    userId: 1,
    comments: 1,
    views: 10,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: InkWell(
          onTap: () {
            // Navigate to volunteer detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VolunteerDetailScreen(
                  volunteer: _mockVolunteer,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info row with avatar, name, time, and volunteer badge
                  Row(
                    children: [
                      // Profile picture
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: const NetworkImage(
                          'https://i.pravatar.cc/150?img=1',
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      
                      // Name and time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dang Hayai',
                              style: AppTheme.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '1 hours ago',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Volunteer badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing8,
                          vertical: AppTheme.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.volunteerGreen,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          'volunteer',
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacing16),
                  
                  // Title
                  Text(
                    'Could you help me take me to the hospital?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacing8),
                  
                  // Description with ellipsis
                  Text(
                    'I have weak legs and cannot drive, so it is difficult for me to go to the hospital by myself. Please take me to the hospital and accom...',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacing20),
                  
                  // Map and details row
                  Row(
                    children: [
                      // Map preview
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: LocationMapWidget(
                          height: 120,
                          isSelectable: false,
                          initialPosition: const LatLng(13.7563, 100.5018), // Bangkok coordinates as default
                          initialAddress: '39 หมู่ที่ 1 Rangsit - Nakhon Nayok Rd, Khlong Hok, Khlong Luang District, Pathum Thani 12110',
                        ),
                      ),
                      
                      const SizedBox(width: AppTheme.spacing16),
                      
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Date', 'Sep. 19, 2025'),
                            const SizedBox(height: AppTheme.spacing8),
                            _buildDetailRow('Time', '12:00 - undecided'),
                            const SizedBox(height: AppTheme.spacing8),
                            _buildDetailRow('Rewards', '500 points'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacing16),
                  
                  // Support area
                  if (!_supported)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = await AuthService.getCurrentUserName();
                          if (mounted) {
                            setState(() {
                              _supported = true;
                              _supporterName = name;
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Supported by $name'),
                              backgroundColor: AppTheme.primaryBlue,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FC3F7), // Light blue
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacing12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                        child: const Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacing12,
                        horizontal: AppTheme.spacing12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Supported by ${_supporterName ?? 'You'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: AppTheme.spacing16),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to volunteer create screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VolunteerCreateScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4FC3F7), // Light blue
        child: const Icon(
          Icons.add,
          color: AppTheme.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label :',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.darkText,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

