import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/community_post.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;

  const CommunityPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

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
              // Header row: Avatar, name, time + Community tag
              Row(
                children: [
                  // Left side: Avatar, name, time
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: post.authorAvatar != null 
                            ? NetworkImage(post.authorAvatar!)
                            : null,
                          backgroundColor: Colors.grey.shade200,
                          child: post.authorAvatar == null 
                            ? Text(
                                post.authorName.isNotEmpty 
                                  ? post.authorName[0].toUpperCase()
                                  : 'U',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.authorName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                post.timeAgo,
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
                  // Right side: Community tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726), // Orange color
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'community',
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
                post.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              
              // Body preview
              Text(
                post.body,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Media display
              if (post.media.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildMediaDisplay(post.media),
              ] else if (post.title.toLowerCase().contains('photo') || post.title.toLowerCase().contains('image')) ...[
                // Debug: Show when we expect media but don't have it
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'DEBUG: Expected media for "${post.title}" but found ${post.media.length} items',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Dotted divider (using thin grey line)
              Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              
              // Bottom meta row: Likes + Comments + Views
              Row(
                children: [
                  // Likes
                  const Icon(
                    Icons.favorite_outline,
                    size: 16,
                    color: Color(0xFFE91E63),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likeCount} likes',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Comments
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: Color(0xFF1E88E5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount} comments',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                    // Views removed per request
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaDisplay(List<PostMedia> media) {
    print('Building media display for ${media.length} media items');
    if (media.isEmpty) return const SizedBox.shrink();
    
    // Use the actual media URL from the database
    String imageUrl = media.first.fileUrl;
    print('Media URL: $imageUrl');
    
    // Check if it's a local file path or server/network URL
    bool isLocalFile = (imageUrl.startsWith('/') && !imageUrl.startsWith('http')) || imageUrl.contains('\\');
    bool isBlobUrl = imageUrl.startsWith('blob:');
    
    // For web platform, always use Image.network for blob URLs
    if (isBlobUrl) {
      isLocalFile = false;
    }
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isLocalFile 
          ? Image.file(
              File(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Post card local image load error for $imageUrl: $error');
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 48,
                  ),
                );
              },
            )
          : Image.network(
              isBlobUrl 
                ? imageUrl  // Blob URL (for web)
                : imageUrl.startsWith('/') 
                  ? 'http://localhost:3000$imageUrl'  // Server URL
                  : imageUrl,  // External URL
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Post card network image load error for $imageUrl: $error');
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 48,
                  ),
                );
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
            ),
      ),
    );
  }
}
