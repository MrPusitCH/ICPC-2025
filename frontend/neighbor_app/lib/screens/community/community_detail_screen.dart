/// Community detail screen for the Neighbor app
/// Shows detailed information about a specific community post
library;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';

class CommunityDetailScreen extends StatelessWidget {
  const CommunityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Post Detail',
          style: AppTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Post Detail',
              style: AppTheme.titleLarge,
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              'Coming Soon',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

