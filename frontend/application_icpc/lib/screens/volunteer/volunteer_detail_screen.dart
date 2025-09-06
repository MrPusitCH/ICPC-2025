import 'package:flutter/material.dart';
import '../../models/volunteer_item.dart';
import '../../widgets/volunteer/avatar_name_row.dart';
import '../../widgets/volunteer/volunteer_tag.dart';
import '../../widgets/common/info_row.dart';
import '../../widgets/common/primary_button.dart';
import '../../theme/app_theme.dart';

class VolunteerDetailScreen extends StatelessWidget {
  final Volunteer volunteer;

  const VolunteerDetailScreen({
    super.key,
    required this.volunteer,
  });

  void _showAcceptConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Confirmation content
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Color(0xFF27AE60),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Accept Help Request',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Are you sure you want to accept this volunteer request from ${volunteer.requesterName}?',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF7A8A9A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            PrimaryButton(
              text: 'Confirm Accept',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help request accepted!'),
                    backgroundColor: Color(0xFF27AE60),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            
            PrimaryButton(
              text: 'Cancel',
              isSecondary: true,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text(
          'Volunteer Request',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                                             color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with avatar, name, time, and tag
                    Row(
                      children: [
                        Expanded(
                          child: AvatarNameRow(
                            avatarUrl: volunteer.avatarUrl,
                            name: volunteer.requesterName,
                            timeAgo: volunteer.timeAgo,
                          ),
                        ),
                        const VolunteerTag(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      volunteer.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      volunteer.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Details card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                                             color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    InfoRow(
                      label: 'Date and Time:',
                      value: volunteer.dateTime,
                    ),
                    
                    InfoRow(
                      label: 'Reward:',
                      value: volunteer.reward,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            PrimaryButton(
              text: 'Accept help',
              onPressed: () => _showAcceptConfirmation(context),
            ),
            const SizedBox(height: 12),
            
            PrimaryButton(
              text: 'Chat',
              isSecondary: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening chat...'),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
