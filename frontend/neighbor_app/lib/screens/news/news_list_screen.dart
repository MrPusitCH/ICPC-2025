import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  // Mock announcement data
  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'Inspect the electrical equipment',
      'content': 'An electrical equipment inspection will be carried out on Sep. 19, 2025. As a result, electricity will be unavailable on the following dates and times. Please be aware of this in...',
      'label': 'Important',
      'labelColor': Colors.red,
    },
    {
      'title': 'The rent payment date is comming!',
      'content': 'The rent payment date is approaching. Rent varies depending on the room, so please check the details in your contract for details. If you have any problems with payment, please...',
      'label': 'caution',
      'labelColor': Colors.orange,
    },
    {
      'title': 'Other announcement',
      'content': 'This is a announcement from the administrator.',
      'label': 'notice',
      'labelColor': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final announcement = _announcements[index];
          return _buildAnnouncementCard(context, announcement);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRouter.pushNamed(context, AppRouter.newsCreate);
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

  Widget _buildAnnouncementCard(BuildContext context, Map<String, dynamic> announcement) {
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
        onTap: () {
          // Navigate to news detail using AppRouter
          AppRouter.pushNamed(context, AppRouter.newsDetail);
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
                      announcement['title'],
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
                      color: announcement['labelColor'],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      announcement['label'],
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
                announcement['content'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
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
}
