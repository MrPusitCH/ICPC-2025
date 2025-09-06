/// Volunteer item model for the Neighbor app
/// Contains data structure for volunteer requests and opportunities
class Volunteer {
  final String id;
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
}

