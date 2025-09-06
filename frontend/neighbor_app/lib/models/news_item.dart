/// News item model for the Neighbor app
/// Contains data structure for news announcements
class NewsItem {
  final String title;
  final String summary;
  final String tag;
  final String timeAgo;

  const NewsItem({
    required this.title,
    required this.summary,
    required this.tag,
    required this.timeAgo,
  });
}

