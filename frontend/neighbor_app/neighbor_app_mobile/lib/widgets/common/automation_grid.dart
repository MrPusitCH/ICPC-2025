import 'package:flutter/material.dart';

class AutomationGrid extends StatelessWidget {
  const AutomationGrid({super.key});

  // Mock automation data
  final List<Map<String, dynamic>> automationRooms = const [
    {
      'title': 'Master bedroom',
      'icon': Icons.bed,
    },
    {
      'title': 'Bedroom 2',
      'icon': Icons.bed,
    },
    {
      'title': 'Living room',
      'icon': Icons.living,
    },
    {
      'title': 'Kitchen',
      'icon': Icons.kitchen,
    },
    {
      'title': 'Bathroom',
      'icon': Icons.bathroom,
    },
    {
      'title': 'Master bathroom',
      'icon': Icons.bathroom,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0, // Square cards (90x90)
      ),
      itemCount: automationRooms.length,
      itemBuilder: (context, index) {
        final room = automationRooms[index];
        return _buildAutomationCard(
          context: context,
          title: room['title'],
          icon: room['icon'],
        );
      },
    );
  }

  Widget _buildAutomationCard({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () {
          debugPrint('Automation room tapped: $title');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title tapped'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: const Color(0xFF1E88E5),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
