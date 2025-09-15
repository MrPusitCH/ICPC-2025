import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/volunteer_item.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/location_map_widget.dart';
import '../../services/volunteer_support_service.dart';

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
  int _supportCount = 0;
  bool _isLoadingSupport = false;

  @override
  void initState() {
    super.initState();
    _loadSupportStatus();
  }

  Future<void> _loadSupportStatus() async {
    try {
      final postId = int.tryParse(widget.volunteer.id);
      if (postId == null) return;
      
      final hasSupported = await VolunteerSupportService.hasSupportedVolunteerRequest(postId);
      final supportCount = await VolunteerSupportService.getSupportCount(postId);
      
      if (mounted) {
        setState(() {
          _supported = hasSupported;
          _supportCount = supportCount;
        });
      }
    } catch (e) {
      print('Error loading support status: $e');
    }
  }

  Future<void> _handleSupport() async {
    if (_isLoadingSupport) return;
    
    setState(() {
      _isLoadingSupport = true;
    });

    try {
      final postId = int.tryParse(widget.volunteer.id);
      if (postId == null) {
        throw Exception('Invalid post ID');
      }
      
      if (_supported) {
        // Unsupport
        await VolunteerSupportService.unsupportVolunteerRequest(postId);
        if (mounted) {
          setState(() {
            _supported = false;
            _supportCount = (_supportCount - 1).clamp(0, double.infinity).toInt();
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support removed'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Support
        await VolunteerSupportService.supportVolunteerRequest(postId);
        if (mounted) {
          setState(() {
            _supported = true;
            _supportCount = _supportCount + 1;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully supported this request!'),
            backgroundColor: AppTheme.primaryBlue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Error supporting volunteer request';
      if (e.toString().contains('already supported')) {
        errorMessage = 'You have already supported this request';
        // Update UI to reflect that it's already supported
        if (mounted) {
          setState(() {
            _supported = true;
          });
        }
      } else if (e.toString().contains('not supported')) {
        errorMessage = 'You have not supported this request yet';
        // Update UI to reflect that it's not supported
        if (mounted) {
          setState(() {
            _supported = false;
          });
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSupport = false;
        });
      }
    }
  }

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
            
            // Support count display
            if (_supportCount > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacing12),
                margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite, color: AppTheme.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$_supportCount people supported this request',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

            // Confirm and Support area
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingSupport ? null : _handleSupport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _supported 
                      ? Colors.green 
                      : const Color(0xFF4FC3F7), // Light blue
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoadingSupport
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _supported ? Icons.check_circle : Icons.favorite,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _supported ? 'Supported' : 'Confirm and Support',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
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


