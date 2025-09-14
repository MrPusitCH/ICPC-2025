/// Mock data service for the Neighbor app
/// Provides mock data for development and testing
library;
import '../models/news_item.dart';
import '../models/community_post.dart';
import '../models/activity_item.dart';
import '../models/volunteer_item.dart';
import '../models/user_profile.dart';

class MockDataService {
  /// Get mock news items
  static List<NewsItem> getNewsItems() {
    final now = DateTime.now();
    return [
      NewsItem(
        newsId: 1,
        title: 'Inspect the electrical equipment',
        content: 'An electrical equipment inspection will be carried out on Sep. 19, 2025. As a result, electricity will be unavailable on the following dates and times. Please be aware of this inconvenience and prepare accordingly.',
        priority: 'important',
        authorId: 1,
        authorName: 'Building Management',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        dateTime: 'Sep. 19, 2025, 13:00 - 20:00',
        disclaimer: 'Could be earlier or later depending on the situation.',
      ),
      NewsItem(
        newsId: 2,
        title: 'The rent payment date is coming!',
        content: 'The rent payment date is approaching. Rent varies depending on the room, so please check the details in your contract for details. If you have any problems with payment, please contact the management office immediately.',
        priority: 'caution',
        authorId: 1,
        authorName: 'Building Management',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      NewsItem(
        newsId: 3,
        title: 'Other announcement',
        content: 'This is an announcement from the administrator. We would like to inform all residents about upcoming community events and maintenance schedules. Please stay updated with the latest information.',
        priority: 'notice',
        authorId: 1,
        authorName: 'Building Management',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      NewsItem(
        newsId: 4,
        title: 'Water supply maintenance',
        content: 'Scheduled water supply maintenance will be conducted on Sep. 25, 2025 from 9:00 AM to 3:00 PM. Please store water in advance and avoid using water-intensive appliances during this period.',
        priority: 'important',
        authorId: 1,
        authorName: 'Building Management',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        dateTime: 'Sep. 25, 2025, 09:00 - 15:00',
      ),
      NewsItem(
        newsId: 5,
        title: 'Community meeting reminder',
        content: 'The monthly community meeting will be held on Sep. 30, 2025 at 7:00 PM in the community hall. All residents are encouraged to attend and participate in discussions about community matters.',
        priority: 'notice',
        authorId: 1,
        authorName: 'Building Management',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 14)),
        dateTime: 'Sep. 30, 2025, 19:00',
      ),
    ];
  }

  /// Get mock community posts
  static List<CommunityPost> getCommunityPosts() {
    final now = DateTime.now();
    return [
      CommunityPost(
        postId: 1,
        title: 'Thank you for your support!',
        content: 'I wanted to express my heartfelt gratitude to all my wonderful neighbors who helped me during my recent recovery. Your kindness and support mean the world to me. The meals you brought, the visits you made, and the warm wishes you shared have made this difficult time so much easier to bear.',
        authorId: 1,
        authorName: 'Dang Hayai',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        commentCount: 2,
        viewCount: 24,
        authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      ),
      CommunityPost(
        postId: 2,
        title: 'Community Garden Update',
        content: 'The community garden is looking beautiful this season! We have fresh tomatoes, herbs, and flowers ready for harvest. Everyone is welcome to come and pick some fresh produce. Please remember to bring your own containers and be mindful of the plants.',
        authorId: 2,
        authorName: 'Sarah Johnson',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        commentCount: 5,
        viewCount: 18,
        authorAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
      ),
      CommunityPost(
        postId: 3,
        title: 'Lost Cat - Please Help!',
        content: 'Our beloved cat Whiskers has been missing since yesterday evening. He\'s a friendly orange tabby with white paws. If you see him or have any information, please contact me immediately. We\'re very worried and miss him dearly.',
        authorId: 3,
        authorName: 'Mike Chen',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        commentCount: 8,
        viewCount: 42,
        authorAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      ),
    ];
  }

  /// Get mock activity items
  static List<ActivityItem> getActivityItems() {
    final now = DateTime.now();
    return [
      ActivityItem(
        activityId: 1,
        title: 'Would you like to play chess with me?',
        description: 'I recently bought a chess set, but I haven\'t decided who to play with. I\'m looking for someone to play with and have a good time. All skill levels welcome!',
        date: 'Sep. 10, 2025',
        time: '14:00 - 18:00',
        place: 'Park',
        location: 'Central Park, Downtown',
        latitude: 13.7563,
        longitude: 100.5018,
        capacity: 4,
        joined: 2,
        comments: 2,
        views: 24,
        imageUrl: 'https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=400&h=300&fit=crop',
        imageName: 'chess-activity.jpg',
        authorId: 1,
        authorName: 'John Doe',
        authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isActive: true,
        endTime: '18:00',
        category: 'Games',
      ),
      ActivityItem(
        activityId: 2,
        title: 'Morning walking group',
        description: 'Join us for a peaceful morning walk around the neighborhood. We meet every Tuesday and Thursday at 8 AM. Great way to stay active and socialize!',
        date: 'Sep. 12, 2025',
        time: '08:00 - 09:00',
        place: 'Community Center',
        location: 'Community Center, Main Hall',
        latitude: 13.7651,
        longitude: 100.5380,
        capacity: 8,
        joined: 5,
        comments: 1,
        views: 18,
        imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=300&fit=crop',
        imageName: 'walking-group.jpg',
        authorId: 2,
        authorName: 'Sarah Wilson',
        authorAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        isActive: true,
        endTime: '09:00',
        category: 'Fitness',
      ),
      ActivityItem(
        activityId: 3,
        title: 'Book reading club',
        description: 'We\'re starting a new book club for mystery novels. Our first book is "The Silent Patient". Join us for weekly discussions and tea!',
        date: 'Sep. 15, 2025',
        time: '15:00 - 16:30',
        place: 'Library',
        location: 'Public Library, Meeting Room A',
        latitude: 13.7307,
        longitude: 100.5231,
        capacity: 6,
        joined: 3,
        comments: 4,
        views: 31,
        imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=300&fit=crop',
        imageName: 'book-club.jpg',
        authorId: 3,
        authorName: 'Mike Chen',
        authorAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isActive: true,
        endTime: '16:30',
        category: 'Education',
      ),
    ];
  }

  /// Get mock volunteer items
  static List<Volunteer> getVolunteerItems() {
    return [
      const Volunteer(
        id: '1',
        userId: 1,
        requesterName: 'Dang Hayai',
        title: 'Could you help me take me to the hospital?',
        description: 'I need someone to help me get to my doctor\'s appointment next week. I have trouble walking long distances and would appreciate any assistance.',
        timeAgo: '1 hour ago',
        dateTime: 'Sep. 19, 2025 12:00 – undecided',
        reward: '฿500',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
        comments: 2,
        views: 24,
      ),
      const Volunteer(
        id: '2',
        userId: 2,
        requesterName: 'Sarah Johnson',
        title: 'Help with grocery shopping',
        description: 'I need help carrying groceries from the store to my apartment. The bags are quite heavy and I have a back condition.',
        timeAgo: '3 hours ago',
        dateTime: 'Sep. 20, 2025 10:00 – 12:00',
        reward: '฿300',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
        comments: 1,
        views: 15,
      ),
      const Volunteer(
        id: '3',
        userId: 3,
        requesterName: 'Mike Chen',
        title: 'Pet sitting needed',
        description: 'I\'m going out of town for the weekend and need someone to take care of my cat. Just feeding and basic care needed.',
        timeAgo: '1 day ago',
        dateTime: 'Sep. 22, 2025 18:00 – Sep. 24, 2025 18:00',
        reward: '฿800',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
        comments: 3,
        views: 31,
      ),
    ];
  }

  /// Get mock user profile
  static UserProfile getUserProfile() {
    return UserProfile(
      userId: 1,
      name: 'Dang Hayai',
      gender: 'Male',
      age: '60',
      address: '203',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      diseases: const [
        ProfileItem(text: 'Diabetes', icon: 'bloodtype'),
        ProfileItem(text: 'High cholesterol', icon: 'health_and_safety'),
        ProfileItem(text: 'High blood pressure', icon: 'favorite'),
      ],
      livingSituation: const [
        ProfileItem(
          text: 'Has 4 children. The first and second work in other provinces. The third lives with Dang and leaves for work in the morning, returning in the evening. The fourth studies at a university far from home.',
          icon: 'person',
        ),
      ],
    );
  }
}
