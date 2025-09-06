import 'package:flutter/material.dart';
import '../../widgets/news/news_card.dart';
import '../../models/news_item.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../services/mock_data_service.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  // Get mock data from service
  List<NewsItem> get _mockNews => MockDataService.getNewsItems();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'News',
          style: AppTheme.titleMedium,
        ),
      ),
      body: Column(
        children: [
          // Optional search field (read-only placeholder)
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Search news...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          
          // News list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: _mockNews.length,
              itemBuilder: (context, index) {
                final news = _mockNews[index];
                return NewsCard(
                  news: news,
                  onTap: () {
                    // Navigate to news detail
                    AppRouter.pushNamed(context, AppRouter.newsDetail);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
