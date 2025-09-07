import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'News',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Mock data count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                // Navigate to news detail using AppRouter
                AppRouter.pushNamed(context, AppRouter.newsDetail);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // News title
                    Text(
                      'News Title ${index + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // News preview
                    Text(
                      'This is a preview of the news content. It contains important information about community events and updates...',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A8A9A),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Date and read more
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2 hours ago',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Read more',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
