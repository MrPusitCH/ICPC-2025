/// Community post model for the Neighbor app
/// Contains data structure for community posts and discussions
class CommunityPost {
  final String userName;
  final String timeAgo;
  final String title;
  final String body;
  final int comments;
  final int views;
  final String avatarUrl;

  const CommunityPost({
    required this.userName,
    required this.timeAgo,
    required this.title,
    required this.body,
    required this.comments,
    required this.views,
    required this.avatarUrl,
  });
}

