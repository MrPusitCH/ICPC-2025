/// Settings screen for the Neighbor app
/// App settings and configuration options
library;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
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
              Icons.settings_outlined,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Settings',
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

