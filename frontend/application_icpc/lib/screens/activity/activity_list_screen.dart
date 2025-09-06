import 'package:flutter/material.dart';
import '../../widgets/activity/activity_card.dart';
import '../../models/activity_item.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../services/mock_data_service.dart';

class ActivityListScreen extends StatelessWidget {
  const ActivityListScreen({super.key});

  // Get mock data from service
  List<ActivityItem> get _mockActivities => MockDataService.getActivityItems();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Activity',
          style: AppTheme.titleMedium,
        ),
      ),
      body: Column(
        children: [
          // Optional search field (disabled placeholder)
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Search activities...',
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
          
          // Activity list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: _mockActivities.length,
              itemBuilder: (context, index) {
                final activity = _mockActivities[index];
                return ActivityCard(
                  activity: activity,
                  onTap: () {
                    // Navigate to activity detail
                    AppRouter.pushNamed(context, AppRouter.activityDetail);
                  },
                  onJoinTap: () {
                    // Show mock join confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Joined ${activity.title}'),
                        backgroundColor: const Color(0xFF27AE60),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create activity
          AppRouter.pushNamed(context, AppRouter.activityCreate);
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
