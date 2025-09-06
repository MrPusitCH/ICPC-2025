/// User profile model for the Neighbor app
/// Contains data structure for user profile information
library;
import 'package:flutter/material.dart';

class UserProfile {
  final int userId;
  final String name;
  final String? nickname;
  final String gender;
  final String age;
  final String address;
  final String avatarUrl;
  final List<ProfileItem> diseases;
  final List<ProfileItem> livingSituation;
  final List<ProfileItem>? interests;
  final List<EmergencyContact>? emergencyContacts;

  const UserProfile({
    required this.userId,
    required this.name,
    this.nickname,
    required this.gender,
    required this.age,
    required this.address,
    required this.avatarUrl,
    required this.diseases,
    required this.livingSituation,
    this.interests,
    this.emergencyContacts,
  });

  /// Create UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Calculate age from date_of_birth if available
    String age = '';
    if (json['date_of_birth'] != null) {
      final birthDate = DateTime.parse(json['date_of_birth']);
      final now = DateTime.now();
      age = (now.year - birthDate.year).toString();
    }
    
    return UserProfile(
      userId: json['user_id'] ?? json['userId'] ?? 0,
      name: json['full_name'] ?? json['name'] ?? '',
      nickname: json['nickname'],
      gender: json['gender'] ?? '',
      age: age,
      address: json['address'] ?? '',
      avatarUrl: json['profile_image_url'] ?? json['avatarUrl'] ?? '',
      diseases: (json['health_conditions'] as List<dynamic>?)
          ?.map((item) => ProfileItem(text: item.toString(), icon: 'health_and_safety'))
          .toList() ?? [],
      livingSituation: (json['living_situation'] as List<dynamic>?)
          ?.map((item) => ProfileItem.fromJson(item))
          .toList() ?? [],
      interests: (json['interests'] as List<dynamic>?)
          ?.map((item) => ProfileItem(text: item.toString(), icon: 'favorite'))
          .toList(),
      emergencyContacts: (json['emergency_contacts'] as List<dynamic>?)
          ?.map((item) => EmergencyContact.fromJson(item))
          .toList(),
    );
  }

  /// Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'nickname': nickname,
      'gender': gender,
      'age': age,
      'address': address,
      'avatarUrl': avatarUrl,
      'diseases': diseases.map((item) => item.toJson()).toList(),
      'livingSituation': livingSituation.map((item) => item.toJson()).toList(),
      'interests': interests?.map((item) => item.toJson()).toList(),
      'emergencyContacts': emergencyContacts?.map((item) => item.toJson()).toList(),
    };
  }
}

/// Profile item with icon and text
class ProfileItem {
  final String text;
  final String icon; // Changed to String to match API

  const ProfileItem({
    required this.text,
    required this.icon,
  });

  /// Create ProfileItem from JSON
  factory ProfileItem.fromJson(Map<String, dynamic> json) {
    return ProfileItem(
      text: json['text'] ?? '',
      icon: json['icon'] ?? 'help',
    );
  }

  /// Convert ProfileItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'icon': icon,
    };
  }

  /// Get IconData from string
  IconData get iconData {
    switch (icon) {
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'bloodtype':
        return Icons.bloodtype;
      case 'favorite':
        return Icons.favorite;
      case 'person':
        return Icons.person;
      case 'home':
        return Icons.home;
      default:
        return Icons.help;
    }
  }
}

/// Emergency contact model
class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  /// Create EmergencyContact from JSON
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }

  /// Convert EmergencyContact to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}
