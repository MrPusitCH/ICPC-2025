import 'package:flutter/material.dart';

/// News item model for the Neighbor app
/// Contains data structure for news announcements
class NewsItem {
  final int newsId;
  final String title;
  final String content;
  final String priority; // 'important', 'caution', 'notice'
  final String? imageUrl;
  final String? imageName;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int viewCount;
  final String? dateTime; // For scheduled announcements
  final String? disclaimer; // Additional notes

  const NewsItem({
    required this.newsId,
    required this.title,
    required this.content,
    required this.priority,
    this.imageUrl,
    this.imageName,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = true,
    this.viewCount = 0,
    this.dateTime,
    this.disclaimer,
  });

  /// Create NewsItem from JSON
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      newsId: json['news_id'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? json['description'] ?? '',
      priority: json['priority'] ?? 'notice',
      imageUrl: json['image_url'],
      imageName: json['image_name'],
      authorId: json['author_id'] ?? 0,
      authorName: json['author']?['profile']?['full_name'] ?? 
                 json['author']?['email'] ?? 
                 json['author_name'] ?? 'Unknown User',
      authorAvatar: json['author']?['profile']?['profile_image_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isPublished: json['is_published'] ?? true,
      viewCount: json['view_count'] ?? 0,
      dateTime: json['date_time'],
      disclaimer: json['disclaimer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'news_id': newsId,
      'title': title,
      'content': content,
      'priority': priority,
      'image_url': imageUrl,
      'image_name': imageName,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_published': isPublished,
      'view_count': viewCount,
      'date_time': dateTime,
      'disclaimer': disclaimer,
    };
  }

  // Helper getters
  String get timeAgo => _getTimeAgo(createdAt);
  String get summary => content.length > 100 ? '${content.substring(0, 100)}...' : content;
  String get label => priority;
  Color get labelColor => _getPriorityColor(priority);

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'important':
        return Colors.red;
      case 'caution':
        return Colors.orange;
      case 'notice':
        return const Color(0xFF4FC3F7);
      default:
        return Colors.grey;
    }
  }
}

