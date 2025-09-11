/// Activity detail screen for the Neighbor app
/// Shows detailed information about a specific activity
library;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../widgets/common/fallback_map_widget.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Check details of Join activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3F7), // Light blue
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => AppRouter.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            _buildInfoSection(
              'Title',
              'Would you like to play chess with me?',
            ),
            
            const SizedBox(height: AppTheme.spacing20),
            
            // Description section
            _buildInfoSection(
              'Description',
              'I recently bought a chess set, but I haven\'t decided who to play with. I\'m looking for someone to play with me. Free feel to join us!',
            ),
            
            const SizedBox(height: AppTheme.spacing20),
            
            // Date and Time section
            _buildInfoSection(
              'Date and Time',
              'Sep. 10, 2025, 14:00 - 18:00',
            ),
            
            const SizedBox(height: AppTheme.spacing20),
            
            // Place section
            _buildInfoSection(
              'Place',
              '39 หมู่ที่ 1 Rangsit - Nakhon Nayok Rd, Khlong Hok, Khlong Luang District, Pathum Thani 12110',
            ),
            
            const SizedBox(height: AppTheme.spacing20),
            
            // Map section
            _buildMapSection(),
            
            const SizedBox(height: AppTheme.spacing20),
            
            // Other members section
            _buildOtherMembersSection(),
            
            const SizedBox(height: AppTheme.spacing20),
            
            // Posted by section
            _buildPostedBySection(),
            
            const SizedBox(height: AppTheme.spacing32),
            
            // Confirm and Support button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Activity joined successfully!'),
                      backgroundColor: Color(0xFF4FC3F7),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FC3F7), // Light blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm and Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FallbackMapWidget(
              height: 200,
              title: 'Activity Location',
              address: '39 หมู่ที่ 1 Rangsit - Nakhon Nayok Rd, Khlong Hok, Khlong Luang District, Pathum Thani 12110',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other member',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // John Doe
            _buildMemberAvatar('John Doe', true),
            const SizedBox(width: 12),
            // Dang Hayai
            _buildMemberAvatar('Dang Hayai', false),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '(2 / 4 perticipant)',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberAvatar(String name, bool isPlaceholder) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: isPlaceholder ? Colors.grey.shade300 : null,
          backgroundImage: isPlaceholder 
              ? null 
              : const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face'),
          child: isPlaceholder
              ? const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 20,
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPostedBySection() {
    return Row(
      children: [
        const Text(
          'Posted by :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(
            Icons.person,
            color: Colors.grey,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'John Doe',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

