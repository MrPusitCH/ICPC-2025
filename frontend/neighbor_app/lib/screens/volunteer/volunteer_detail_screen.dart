import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/volunteer_item.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/location_map_widget.dart';
import '../../services/auth_service.dart';

class VolunteerDetailScreen extends StatefulWidget {
  final Volunteer volunteer;
  final ValueChanged<String>? onDeleted;

  const VolunteerDetailScreen({
    super.key,
    required this.volunteer,
    this.onDeleted,
  });

  @override
  State<VolunteerDetailScreen> createState() => _VolunteerDetailScreenState();
}

class _VolunteerDetailScreenState extends State<VolunteerDetailScreen> {
  bool _supported = false;
  String? _supporterName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Check details of Volunteer support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3F7), // Light blue background
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              widget.volunteer.title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            
            // Description section
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              widget.volunteer.description,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            
            // Details section
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            
            // Date and Time
            _buildDetailRow(
              label: 'Date and Time',
              value: widget.volunteer.dateTime,
            ),
            const SizedBox(height: AppTheme.spacing16),
            
            // Rewards (fix typo from "Rewords" to "Rewards")
            _buildDetailRow(
              label: 'Rewards',
              value: widget.volunteer.reward,
            ),
            const SizedBox(height: AppTheme.spacing16),
            
            // Place
            _buildDetailRow(
              label: 'Place',
              value: '39 หมู่ที่ 1 Rangsit - Nakhon Nayok Rd, Khlong Hok, Khlong Luang District, Pathum Thani 12110',
            ),
            const SizedBox(height: AppTheme.spacing20),
            
            // Map section
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LocationMapWidget(
                  height: 200,
                  title: 'Request Location',
                  isSelectable: false,
                  initialPosition: const LatLng(13.7563, 100.5018), // Bangkok coordinates as default
                  initialAddress: '39 หมู่ที่ 1 Rangsit - Nakhon Nayok Rd, Khlong Hok, Khlong Luang District, Pathum Thani 12110',
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            
            // Posted by section
            Row(
              children: [
                const Text(
                  'Posted by :',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing8),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.volunteer.avatarUrl),
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  widget.volunteer.requesterName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing20),
            
            // Confirm and Support area
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm and Support',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing12,
                      horizontal: AppTheme.spacing12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: AppTheme.spacing8),
                  OutlinedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _supported = false;
                          _supporterName = null;
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Support canceled'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel Support',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppTheme.spacing20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}


