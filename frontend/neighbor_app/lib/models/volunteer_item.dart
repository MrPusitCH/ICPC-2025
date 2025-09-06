/// Volunteer item model for the Neighbor app
/// Contains data structure for volunteer requests and opportunities
class Volunteer {
  final String id;
  final int userId; // Add user_id field for ownership checking
  final String requesterName;
  final String title;
  final String description;
  final String timeAgo;
  final String dateTime;
  final String reward;
  final String avatarUrl;
  final int comments;
  final int views;

  const Volunteer({
    required this.id,
    required this.userId,
    required this.requesterName,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.dateTime,
    required this.reward,
    required this.avatarUrl,
    required this.comments,
    required this.views,
  });

  /// Create Volunteer from JSON
  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['post_id']?.toString() ?? json['id'] ?? '',
      userId: json['user_id'] ?? 0,
      requesterName: json['user']?['profile']?['full_name'] ?? 
                    json['user']?['full_name'] ?? 
                    json['requesterName'] ?? 
                    'Unknown User',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeAgo: _calculateTimeAgo(json['created_at']),
      dateTime: _formatDateTime(json['dateTime']),
      reward: json['reward'] ?? 'No reward',
      avatarUrl: json['user']?['profile']?['profile_image_url'] ?? 
                 json['user']?['profile_image_url'] ?? 
                 json['avatarUrl'] ?? 
                 'https://via.placeholder.com/40',
      comments: 0, // Default value since not in API
      views: 0, // Default value since not in API
    );
  }

  /// Calculate time ago from created_at timestamp
  static String _calculateTimeAgo(dynamic createdAt) {
    if (createdAt == null) return 'Unknown time';
    
    try {
      final created = DateTime.parse(createdAt.toString());
      final now = DateTime.now();
      final difference = now.difference(created);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  /// Format dateTime for display
  static String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'No date set';
    
    try {
      final dt = DateTime.parse(dateTime.toString());
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}

