import 'package:flutter/material.dart';
import '../../router/app_router.dart';
import '../../models/news_item.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem? newsItem;
  
  const NewsDetailScreen({super.key, this.newsItem});

  @override
  Widget build(BuildContext context) {
    // Get news item from arguments if not provided directly
    final news = newsItem ?? ModalRoute.of(context)?.settings.arguments as NewsItem?;
    
    if (news == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'News Detail',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF4FC3F7),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => AppRouter.pop(context),
          ),
        ),
        body: const Center(
          child: Text('News not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'News Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3F7), // Light blue
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => AppRouter.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and priority label
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Expanded(
                  child: Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Priority label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: news.labelColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    news.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Main content
            Text(
              news.content,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
                height: 1.5,
              ),
            ),
            
            if (news.dateTime != null) ...[
              const SizedBox(height: 24),
              
              // Date and time section
              const Text(
                'Date and time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                news.dateTime!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  height: 1.4,
                ),
              ),
            ],
            
            if (news.disclaimer != null) ...[
              const SizedBox(height: 24),
              
              // Disclaimer note
              Text(
                news.disclaimer!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Author and timestamp info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: news.authorAvatar != null
                      ? NetworkImage(news.authorAvatar!)
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  child: news.authorAvatar == null
                      ? Text(
                          news.authorName.isNotEmpty
                              ? news.authorName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
                        news.authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        news.timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (news.viewCount > 0)
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${news.viewCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
