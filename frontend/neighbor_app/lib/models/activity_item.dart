/// Activity item model for the Neighbor app
/// Contains data structure for community activities and events
class ActivityItem {
  final String userName;
  final String timeAgo;
  final String title;
  final String description;
  final String date;
  final String time;
  final String place;
  final int joined;
  final int capacity;
  final int comments;
  final int views;
  final String imageUrl;

  const ActivityItem({
    required this.userName,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.place,
    required this.joined,
    required this.capacity,
    required this.comments,
    required this.views,
    required this.imageUrl,
  });
}

