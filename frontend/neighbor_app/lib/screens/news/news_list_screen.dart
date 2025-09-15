import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../models/news_item.dart';
import '../../services/news_api_service.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<NewsItem> _newsItems = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final news = await NewsApiService.getNews();
      
      print('Found ${news.length} news items');
      
      if (mounted) {
        setState(() {
          _newsItems = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to news create screen
          final result = await AppRouter.pushNamed(context, AppRouter.newsCreate);
          // Refresh the list if a new news was created
          if (result == true && mounted) {
            _loadNews();
          }
        },
        backgroundColor: const Color(0xFF4FC3F7), // Light blue
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading news',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNews,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_newsItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No news yet',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to post an announcement!',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await AppRouter.pushNamed(context, AppRouter.newsCreate);
                if (result == true && mounted) {
                  _loadNews();
                }
              },
              child: const Text('Create Announcement'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _newsItems.length,
        itemBuilder: (context, index) {
          final newsItem = _newsItems[index];
          return _buildAnnouncementCard(context, newsItem);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, NewsItem newsItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          // Increment view count
          await NewsApiService.incrementViewCount(newsItem.newsId.toString());
          
          // Navigate to news detail using AppRouter
          await AppRouter.pushNamed(context, AppRouter.newsDetail, arguments: newsItem);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with label
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      newsItem.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: newsItem.labelColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      newsItem.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Content
              Text(
                newsItem.summary,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Image display if available
              if (newsItem.imageUrl != null && newsItem.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildNewsImage(newsItem.imageUrl!),
                const SizedBox(height: 12),
              ],
              
              const SizedBox(height: 16),
              
              // Read more button
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7), // Light blue
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Read more >>',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsImage(String imageUrl) {
    print('Building news image for URL: $imageUrl');
    
    // Check if it's a local file path or server/network URL
    bool isLocalFile = (imageUrl.startsWith('/') && !imageUrl.startsWith('http')) || imageUrl.contains('\\');
    bool isBlobUrl = imageUrl.startsWith('blob:');
    bool isApiUrl = imageUrl.startsWith('/api/');
    
    // For web platform, always use Image.network for blob URLs
    if (isBlobUrl) {
      isLocalFile = false;
    }
    
    // On Flutter Web, always use Image.network
    bool isWeb = kIsWeb;
    
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: (isLocalFile && !isWeb)
            ? Image.file(
                File(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading local image: $error');
                  return const Icon(Icons.error, color: Colors.red);
                },
              )
            : Image.network(
                isBlobUrl ? imageUrl :
                isApiUrl ? 'http://127.0.0.1:3000$imageUrl' : 
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading network image: $error');
                  return const Icon(Icons.error, color: Colors.red);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
