import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../models/activity_item.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../services/activity_api_service.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  List<ActivityItem> _activities = [];
  final Map<int, List<String>> _joinedBy = {};
  final Set<int> _joined = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final activities = await ActivityApiService.getActivities();
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        heroTag: "activity_fab",
        onPressed: () async {
          // Navigate to create activity
          final result = await AppRouter.pushNamed(context, AppRouter.activityCreate);
          if (result == true) {
            // Refresh the list if a new activity was created
            _loadActivities();
          }
        },
        backgroundColor: const Color(0xFF4FC3F7), // Light blue
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading activities',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadActivities,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_activities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No activities available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to create an activity!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActivities,
      color: const Color(0xFF4FC3F7),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return _buildActivityCard(context, activity, index);
        },
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityItem activity, int index) {
    return InkWell(
      onTap: () async {
        // Increment view count
        try {
          await ActivityApiService.incrementViewCount(activity.activityId);
        } catch (e) {
          // Silently fail for view count
        }
        
        // Navigate to activity detail screen
        AppRouter.pushNamed(context, AppRouter.activityDetail, arguments: activity);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile and activity badge
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                // Profile picture
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: activity.authorAvatar != null 
                      ? NetworkImage(activity.authorAvatar!)
                      : null,
                  child: activity.authorAvatar == null
                      ? Text(
                          activity.userName.isNotEmpty ? activity.userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
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
                        activity.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity.timeAgo,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Activity badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7), // Light blue
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Title and description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
              ],
            ),
          ),
          
          // Image and details row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Row(
              children: [
                // Activity image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: activity.imageUrl != null && activity.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildActivityImage(activity.imageUrl!),
                        )
                      : const Icon(
                          Icons.sports_esports,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
                
                const SizedBox(width: AppTheme.spacing16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Date', activity.date),
                      const SizedBox(height: AppTheme.spacing8),
                      _buildDetailRow('Time', activity.time),
                      const SizedBox(height: AppTheme.spacing8),
                      _buildDetailRow('Place', activity.place),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Participants section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  activity.participantText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing4),
                const Text(
                  'Participants',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                
                const Spacer(),
                
                // Participant avatars (first 3 by name initials)
                Row(
                  children: [
                    for (final name in (_joinedBy[index] ?? <String>[])
                        .take(3))
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey.shade400,
                          child: Text(
                            _initials(name),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Join button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: SizedBox(
              width: double.infinity,
              child: _joined.contains(index)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacing12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Joined',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () async {
                            try {
                              await ActivityApiService.leaveActivity(activity.activityId);
                              if (mounted) {
                                setState(() {
                                  _joined.remove(index);
                                  _activities[index] = ActivityItem(
                                    activityId: activity.activityId,
                                    title: activity.title,
                                    description: activity.description,
                                    date: activity.date,
                                    time: activity.time,
                                    place: activity.place,
                                    location: activity.location,
                                    latitude: activity.latitude,
                                    longitude: activity.longitude,
                                    capacity: activity.capacity,
                                    joined: activity.joined - 1,
                                    comments: activity.comments,
                                    views: activity.views,
                                    imageUrl: activity.imageUrl,
                                    imageName: activity.imageName,
                                    authorId: activity.authorId,
                                    authorName: activity.authorName,
                                    authorAvatar: activity.authorAvatar,
                                    createdAt: activity.createdAt,
                                    updatedAt: activity.updatedAt,
                                    isActive: activity.isActive,
                                    endTime: activity.endTime,
                                    category: activity.category,
                                  );
                                });
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('You left this activity'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to leave activity: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel Join',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        try {
                          await ActivityApiService.joinActivity(activity.activityId);
                          if (mounted) {
                            setState(() {
                              _joined.add(index);
                              _activities[index] = ActivityItem(
                                activityId: activity.activityId,
                                title: activity.title,
                                description: activity.description,
                                date: activity.date,
                                time: activity.time,
                                place: activity.place,
                                location: activity.location,
                                latitude: activity.latitude,
                                longitude: activity.longitude,
                                capacity: activity.capacity,
                                joined: activity.joined + 1,
                                comments: activity.comments,
                                views: activity.views,
                                imageUrl: activity.imageUrl,
                                imageName: activity.imageName,
                                authorId: activity.authorId,
                                authorName: activity.authorName,
                                authorAvatar: activity.authorAvatar,
                                createdAt: activity.createdAt,
                                updatedAt: activity.updatedAt,
                                isActive: activity.isActive,
                                endTime: activity.endTime,
                                category: activity.category,
                              );
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You joined ${activity.title}'),
                              backgroundColor: const Color(0xFF4FC3F7),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to join activity: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3F7), // Light blue
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'JOIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Joined members list
          if ((_joinedBy[index] ?? const []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Joined by',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final name in _joinedBy[index]!) _JoinedChip(name: name),
                    ],
                  ),
                ],
              ),
            ),
          
          // Comments section removed per request
        ],
      ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            '$label :',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityImage(String imageUrl) {
    print('Building activity list image for URL: $imageUrl');
    
    // Check if it's a local file path or server/network URL
    bool isLocalFile = (imageUrl.startsWith('/') && !imageUrl.startsWith('http')) || imageUrl.contains('\\');
    bool isBlobUrl = imageUrl.startsWith('blob:');
    bool isApiUrl = imageUrl.startsWith('/api/');
    
    // For web platform, always use Image.network for blob URLs
    if (isBlobUrl) {
      isLocalFile = false;
    }
    
    // On Flutter Web, always use Image.network
    bool isWeb = kIsWeb;
    
    return (isLocalFile && !isWeb)
        ? Image.file(
            File(imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading local image: $error');
              return const Icon(Icons.error, color: Colors.red);
            },
          )
        : Image.network(
            isApiUrl ? 'http://127.0.0.1:3000$imageUrl' : imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading network image: $error');
              return const Icon(Icons.error, color: Colors.red);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
  }
}

class _JoinedChip extends StatelessWidget {
  final String name;
  const _JoinedChip({required this.name});

  @override
  Widget build(BuildContext context) {
    String initials = name.isNotEmpty
        ? name.trim().split(RegExp(r"\s+")).map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFF4FC3F7),
            child: Text(
              initials,
              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }

}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
