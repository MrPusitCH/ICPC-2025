import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/activity_item.dart';

class ActivityCard extends StatelessWidget {
  final ActivityItem activity;
  final VoidCallback? onTap;
  final VoidCallback? onJoinTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onJoinTap,
  });

  Future<void> _openInGoogleMaps(String query) async {
    // Prefer universal Maps URL which opens the app on Android, and browser/app on iOS
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        // Fallback to geo: scheme (mostly Android)
        final geo = Uri.parse('geo:0,0?q=${Uri.encodeComponent(query)}');
        await launchUrl(geo, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Silently ignore; optionally show a snackbar in a stateful widget context
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
              // Header row: Avatar, name, time + Activity tag
              Row(
                children: [
                  // Left side: Avatar, name, time
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(activity.imageUrl),
                          backgroundColor: Colors.grey.shade200,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                activity.timeAgo,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7A8A9A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side: Activity tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(16),
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
              const SizedBox(height: 16),
              
              // Title
              Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              
              // Description preview
              Text(
                activity.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              
              // Content row: Image + Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Thumbnail image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(activity.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Right: Info rows
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(label: 'Date :', value: activity.date),
                        const SizedBox(height: 4),
                        _InfoRow(label: 'Time :', value: activity.time),
                        const SizedBox(height: 4),
                        _InfoRow(label: 'Place:', value: activity.place),
                        const SizedBox(height: 8),
                        // Tap to open Google Maps
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () => _openInGoogleMaps(activity.place),
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.map, size: 16, color: Color(0xFF1E88E5)),
                                SizedBox(width: 6),
                                Text(
                                  'Open in Maps',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1E88E5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Participant row: Joined count + JOIN button
              Row(
                children: [
                  // Left: Participant info
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 16,
                          color: Color(0xFF1E88E5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${activity.joined}/${activity.capacity}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Small participant avatar
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(
                            Icons.person,
                            size: 14,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Right: JOIN button
                  GestureDetector(
                    onTap: onJoinTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'JOIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Bottom meta row: Views only
              Row(
                children: [
                  // Views
                  const Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Color(0xFF1E88E5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${activity.views} view',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7A8A9A),
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
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
