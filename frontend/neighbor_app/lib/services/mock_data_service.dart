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
    return [
      const NewsItem(
        title: 'Inspect the electrical equipment',
        summary: 'An electrical equipment inspection will be carried out on Sep. 19, 2025. As a result, electricity will be unavailable on the following dates and times. Please be aware of this inconvenience and prepare accordingly.',
        tag: 'important',
        timeAgo: '2 hours ago',
      ),
      const NewsItem(
        title: 'The rent payment date is coming!',
        summary: 'The rent payment date is approaching. Rent varies depending on the room, so please check the details in your contract for details. If you have any problems with payment, please contact the management office immediately.',
        tag: 'caution',
        timeAgo: '1 day ago',
      ),
      const NewsItem(
        title: 'Other announcement',
        summary: 'This is an announcement from the administrator. We would like to inform all residents about upcoming community events and maintenance schedules. Please stay updated with the latest information.',
        tag: 'notice',
        timeAgo: '3 days ago',
      ),
      const NewsItem(
        title: 'Water supply maintenance',
        summary: 'Scheduled water supply maintenance will be conducted on Sep. 25, 2025 from 9:00 AM to 3:00 PM. Please store water in advance and avoid using water-intensive appliances during this period.',
        tag: 'important',
        timeAgo: '1 week ago',
      ),
      const NewsItem(
        title: 'Community meeting reminder',
        summary: 'The monthly community meeting will be held on Sep. 30, 2025 at 7:00 PM in the community hall. All residents are encouraged to attend and participate in discussions about community matters.',
        tag: 'notice',
        timeAgo: '2 weeks ago',
      ),
    ];
  }

  /// Get mock community posts
  static List<CommunityPost> getCommunityPosts() {
    return [
      const CommunityPost(
        userName: 'Dang Hayai',
        timeAgo: '2 hours ago',
        title: 'Thank you for your support!',
        body: 'I wanted to express my heartfelt gratitude to all my wonderful neighbors who helped me during my recent recovery. Your kindness and support mean the world to me. The meals you brought, the visits you made, and the warm wishes you shared have made this difficult time so much easier to bear.',
        comments: 2,
        views: 24,
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      ),
      const CommunityPost(
        userName: 'Sarah Johnson',
        timeAgo: '5 hours ago',
        title: 'Community Garden Update',
        body: 'The community garden is looking beautiful this season! We have fresh tomatoes, herbs, and flowers ready for harvest. Everyone is welcome to come and pick some fresh produce. Please remember to bring your own containers and be mindful of the plants.',
        comments: 5,
        views: 18,
        avatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
      ),
      const CommunityPost(
        userName: 'Mike Chen',
        timeAgo: '1 day ago',
        title: 'Lost Cat - Please Help!',
        body: 'Our beloved cat Whiskers has been missing since yesterday evening. He\'s a friendly orange tabby with white paws. If you see him or have any information, please contact me immediately. We\'re very worried and miss him dearly.',
        comments: 8,
        views: 42,
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      ),
    ];
  }

  /// Get mock activity items
  static List<ActivityItem> getActivityItems() {
    return [
      const ActivityItem(
        userName: 'John Doe',
        timeAgo: 'yesterday',
        title: 'Would you like to play chess with me?',
        description: 'I recently bought a chess set, but I haven\'t decided who to play with. I\'m looking for someone to play with and have a good time. All skill levels welcome!',
        date: 'Sep. 10, 2025',
        time: '14:00 - 18:00',
        place: 'Park',
        joined: 2,
        capacity: 4,
        comments: 2,
        views: 24,
        imageUrl: 'https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=400&h=300&fit=crop',
      ),
      const ActivityItem(
        userName: 'Sarah Wilson',
        timeAgo: '2 hours ago',
        title: 'Morning walking group',
        description: 'Join us for a peaceful morning walk around the neighborhood. We meet every Tuesday and Thursday at 8 AM. Great way to stay active and socialize!',
        date: 'Sep. 12, 2025',
        time: '08:00 - 09:00',
        place: 'Community Center',
        joined: 5,
        capacity: 8,
        comments: 1,
        views: 18,
        imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=300&fit=crop',
      ),
      const ActivityItem(
        userName: 'Mike Chen',
        timeAgo: '1 day ago',
        title: 'Book reading club',
        description: 'We\'re starting a new book club for mystery novels. Our first book is "The Silent Patient". Join us for weekly discussions and tea!',
        date: 'Sep. 15, 2025',
        time: '15:00 - 16:30',
        place: 'Library',
        joined: 3,
        capacity: 6,
        comments: 4,
        views: 31,
        imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=300&fit=crop',
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
      age: '50',
      address: '203',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      diseases: const [
        ProfileItem(
          text: 'Type 2 diabetes',
          icon: 'bloodtype',
        ),
        ProfileItem(
          text: 'Osteoporosis',
          icon: 'health_and_safety',
        ),
        ProfileItem(
          text: 'High blood pressure',
          icon: 'favorite',
        ),
      ],
      livingSituation: const [
        ProfileItem(
          text: 'Living alone',
          icon: 'person',
        ),
      ],
    );
  }
}
