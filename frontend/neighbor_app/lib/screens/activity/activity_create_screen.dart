/// Activity create screen for the Neighbor app
/// Form for creating new community activities
library;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';

class ActivityCreateScreen extends StatelessWidget {
  const ActivityCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Create Activity',
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
              Icons.add_circle_outline,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Create Activity',
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

