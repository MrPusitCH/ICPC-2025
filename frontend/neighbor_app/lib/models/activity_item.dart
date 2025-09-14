import 'package:flutter/material.dart';

/// Activity item model for the Neighbor app
/// Contains data structure for community activities and events
class ActivityItem {
  final int activityId;
  final String title;
  final String description;
  final String date;
  final String time;
  final String place;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int capacity;
  final int joined;
  final int comments;
  final int views;
  final String? imageUrl;
  final String? imageName;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? endTime;
  final String? category;

  const ActivityItem({
    required this.activityId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.place,
    this.location,
    this.latitude,
    this.longitude,
    required this.capacity,
    required this.joined,
    required this.comments,
    required this.views,
    this.imageUrl,
    this.imageName,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.endTime,
    this.category,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      activityId: json['activity_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      place: json['place'] ?? '',
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      capacity: json['capacity'] ?? 0,
      joined: json['joined'] ?? 0,
      comments: json['comments'] ?? 0,
      views: json['views'] ?? 0,
      imageUrl: json['image_url'],
      imageName: json['image_name'],
      authorId: json['author_id'] ?? 0,
      authorName: json['author_name'] ?? '',
      authorAvatar: json['author_avatar'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? true,
      endTime: json['end_time'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'place': place,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'joined': joined,
      'comments': comments,
      'views': views,
      'image_url': imageUrl,
      'image_name': imageName,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'end_time': endTime,
      'category': category,
    };
  }

  // Helper getters for UI
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get userName => authorName;

  Color get statusColor {
    if (!isActive) return Colors.grey;
    if (joined >= capacity) return Colors.red;
    if (joined >= capacity * 0.8) return Colors.orange;
    return Colors.green;
  }

  String get statusText {
    if (!isActive) return 'Inactive';
    if (joined >= capacity) return 'Full';
    if (joined >= capacity * 0.8) return 'Almost Full';
    return 'Available';
  }

  String get participantText => '$joined/$capacity participants';
}

