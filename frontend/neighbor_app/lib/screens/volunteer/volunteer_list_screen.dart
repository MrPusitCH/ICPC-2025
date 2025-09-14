import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/app_theme.dart';
import '../../models/volunteer_item.dart';
import '../../widgets/common/location_map_widget.dart';
import 'volunteer_create_screen.dart';
import '../../services/posts_api_service.dart';
import '../../services/volunteer_support_service.dart';
import 'volunteer_detail_screen.dart';

class VolunteerListScreen extends StatefulWidget {
  const VolunteerListScreen({super.key});

  @override
  State<VolunteerListScreen> createState() => _VolunteerListScreenState();
}

class _VolunteerListScreenState extends State<VolunteerListScreen> {
  List<Volunteer> _volunteerPosts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<int, bool> _supportStatus = {}; // Track support status for each post
  Map<int, int> _supportCounts = {}; // Track support counts for each post

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
  }

  Future<void> _loadVolunteers() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final volunteers = await PostsApiService.getPosts();
      
      print('Found ${volunteers.length} volunteer posts');
      
      if (mounted) {
        setState(() {
          _volunteerPosts = volunteers;
          _isLoading = false;
        });
        
        // Load support status for each volunteer post
        _loadSupportStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSupportStatus() async {
    for (final volunteer in _volunteerPosts) {
      try {
        final postId = int.tryParse(volunteer.id);
        if (postId == null) continue;
        
        final hasSupported = await VolunteerSupportService.hasSupportedVolunteerRequest(postId);
        final supportCount = await VolunteerSupportService.getSupportCount(postId);
        
        if (mounted) {
          setState(() {
            _supportStatus[postId] = hasSupported;
            _supportCounts[postId] = supportCount;
          });
        }
      } catch (e) {
        print('Error loading support status for post ${volunteer.id}: $e');
      }
    }
  }

  Future<void> _handleSupport(Volunteer volunteer) async {
    try {
      final postId = int.tryParse(volunteer.id);
      if (postId == null) {
        throw Exception('Invalid post ID');
      }
      
      final isCurrentlySupported = _supportStatus[postId] ?? false;
      
      if (isCurrentlySupported) {
        // Unsupport
        await VolunteerSupportService.unsupportVolunteerRequest(postId);
        if (mounted) {
          setState(() {
            _supportStatus[postId] = false;
            _supportCounts[postId] = (_supportCounts[postId] ?? 0) - 1;
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
            _supportStatus[postId] = true;
            _supportCounts[postId] = (_supportCounts[postId] ?? 0) + 1;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to volunteer create screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VolunteerCreateScreen(),
            ),
          );
          // Refresh the list if a new volunteer was created
          if (result == true && mounted) {
            _loadVolunteers();
          }
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading volunteers',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVolunteers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_volunteerPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No volunteer requests yet',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to request volunteer help!',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VolunteerCreateScreen(),
                  ),
                );
                if (result == true && mounted) {
                  _loadVolunteers();
                }
              },
              child: const Text('Create Request'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVolunteers,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _volunteerPosts.length,
        itemBuilder: (context, index) {
          final post = _volunteerPosts[index];
          return _buildVolunteerCard(post, index);
        },
      ),
    );
  }

  Widget _buildVolunteerCard(Volunteer volunteer, int index) {
    return Card(
      key: ValueKey('volunteer_${volunteer.id}_$index'),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to volunteer detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VolunteerDetailScreen(
                volunteer: volunteer,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                    backgroundImage: volunteer.avatarUrl.isNotEmpty
                        ? NetworkImage(volunteer.avatarUrl)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                    child: volunteer.avatarUrl.isEmpty
                        ? Text(
                            volunteer.requesterName.isNotEmpty
                                ? volunteer.requesterName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  
                  // Name and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          volunteer.requesterName,
                          style: AppTheme.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          volunteer.timeAgo,
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
                volunteer.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacing8),
              
              // Description with ellipsis
              Text(
                volunteer.description.length > 100
                    ? '${volunteer.description.substring(0, 100)}...'
                    : volunteer.description,
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
                        _buildDetailRow('Date', volunteer.dateTime),
                        const SizedBox(height: AppTheme.spacing8),
                        _buildDetailRow('Time', volunteer.dateTime),
                        const SizedBox(height: AppTheme.spacing8),
                        _buildDetailRow('Rewards', volunteer.reward),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacing16),
              
              // Support button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleSupport(volunteer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_supportStatus[int.tryParse(volunteer.id)] ?? false) 
                        ? Colors.green 
                        : const Color(0xFF4FC3F7), // Light blue
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        (_supportStatus[int.tryParse(volunteer.id)] ?? false) 
                            ? Icons.check_circle 
                            : Icons.favorite,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (_supportStatus[int.tryParse(volunteer.id)] ?? false) 
                            ? 'Supported' 
                            : 'Support',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_supportCounts[int.tryParse(volunteer.id)] != null && _supportCounts[int.tryParse(volunteer.id)]! > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_supportCounts[int.tryParse(volunteer.id)]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacing16),
            ],
          ),
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

