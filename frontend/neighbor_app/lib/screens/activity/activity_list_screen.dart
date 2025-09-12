import 'package:flutter/material.dart';
import '../../models/activity_item.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../services/mock_data_service.dart';
import '../../services/auth_service.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  late final List<ActivityItem> _activities;
  final Map<int, List<String>> _joinedBy = {};
  final Set<int> _joined = {};

  @override
  void initState() {
    super.initState();
    _activities = MockDataService.getActivityItems();
    _seedJoined();
  }

  void _seedJoined() {
    const seedNames = [
      'John', 'Sarah', 'Mike', 'Emily', 'Alex', 'Kate', 'Tom', 'Lily'
    ];
    for (var i = 0; i < _activities.length; i++) {
      final count = _activities[i].joined;
      _joinedBy[i] = List.generate(
        count.clamp(0, seedNames.length),
        (idx) => seedNames[idx],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return _buildActivityCard(context, activity, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "activity_fab",
        onPressed: () {
          // Navigate to create activity
          AppRouter.pushNamed(context, AppRouter.activityCreate);
        },
        backgroundColor: const Color(0xFF4FC3F7), // Light blue
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityItem activity, int index) {
    return InkWell(
      onTap: () {
        // Navigate to activity detail screen
        AppRouter.pushNamed(context, AppRouter.activityDetail);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile and activity badge
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                // Profile picture
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    activity.userName.isNotEmpty ? activity.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                
                // Name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity.timeAgo,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Activity badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7), // Light blue
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Title and description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
              ],
            ),
          ),
          
          // Image and details row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Row(
              children: [
                // Activity image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    image: activity.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(activity.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: activity.imageUrl.isEmpty
                      ? const Icon(
                          Icons.sports_esports,
                          size: 40,
                          color: Colors.grey,
                        )
                      : null,
                ),
                
                const SizedBox(width: AppTheme.spacing16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Date', activity.date),
                      const SizedBox(height: AppTheme.spacing8),
                      _buildDetailRow('Time', activity.time),
                      const SizedBox(height: AppTheme.spacing8),
                      _buildDetailRow('Place', activity.place),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Participants section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  '${activity.joined}/${activity.capacity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing4),
                const Text(
                  'Participants',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                
                const Spacer(),
                
                // Participant avatars
                Row(
                  children: [
                    for (int i = 0; i < activity.joined && i < 3; i++)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey.shade300,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Join button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: SizedBox(
              width: double.infinity,
              child: _joined.contains(index)
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacing12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Joined',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        final name = await AuthService.getCurrentUserName();
                        if (mounted) {
                          setState(() {
                            _joined.add(index);
                            final list = _joinedBy[index] ?? <String>[];
                            if (!list.contains(name)) list.add(name);
                            _joinedBy[index] = list;
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You joined ${activity.title}'),
                            backgroundColor: const Color(0xFF4FC3F7),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3F7), // Light blue
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'JOIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Joined members list
          if ((_joinedBy[index] ?? const []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Joined by',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final name in _joinedBy[index]!) _JoinedChip(name: name),
                    ],
                  ),
                ],
              ),
            ),
          
          // Comments section removed per request
        ],
      ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            '$label :',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}

class _JoinedChip extends StatelessWidget {
  final String name;
  const _JoinedChip({required this.name});

  @override
  Widget build(BuildContext context) {
    String initials = name.isNotEmpty
        ? name.trim().split(RegExp(r"\s+")).map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFF4FC3F7),
            child: Text(
              initials,
              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }
}
