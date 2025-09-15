import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
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

  Future<void> _openInMaps(String query) async {
    // Use OpenStreetMap Nominatim for geocoding and then open in maps
    final encodedQuery = Uri.encodeComponent(query);
    final osmUri = Uri.parse('https://www.openstreetmap.org/search?query=$encodedQuery');
    
    try {
      final ok = await launchUrl(osmUri, mode: LaunchMode.externalApplication);
      if (!ok) {
        // Fallback to geo: scheme (mostly Android)
        final geo = Uri.parse('geo:0,0?q=$encodedQuery');
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
                          backgroundImage: activity.imageUrl != null 
                              ? NetworkImage(activity.imageUrl!)
                              : null,
                          backgroundColor: Colors.grey.shade200,
                          child: activity.imageUrl == null
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
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
                      color: activity.imageUrl == null 
                          ? Colors.grey.shade200 
                          : null,
                    ),
                    child: activity.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildActivityImage(activity.imageUrl!),
                          )
                        : const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 32,
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
                        // Tap to open Maps
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () => _openInMaps(activity.place),
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

  Widget _buildActivityImage(String imageUrl) {
    print('Building activity image for URL: $imageUrl');
    
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

  Widget _buildActivityImage(String imageUrl) {
    print('Building activity image for URL: $imageUrl');
    
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
              print('Activity card local image load error for $imageUrl: $error');
              return Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 32,
                ),
              );
            },
          )
        : Image.network(
            isBlobUrl 
                ? imageUrl  // Blob URL (for web)
                : isApiUrl
                  ? 'http://127.0.0.1:3000$imageUrl'  // API URL (database image)
                  : imageUrl.startsWith('/') 
                    ? 'http://127.0.0.1:3000$imageUrl'  // Server URL
                    : imageUrl,  // External URL
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Activity card network image load error for $imageUrl: $error');
              return Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 32,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          );
  }
}
