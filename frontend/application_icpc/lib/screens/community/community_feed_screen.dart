import 'package:flutter/material.dart';
import '../../widgets/community/community_post_card.dart';
import '../../models/community_post.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../services/mock_data_service.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  // Get mock data from service
  List<CommunityPost> get _mockPosts => MockDataService.getCommunityPosts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Community',
          style: AppTheme.titleMedium,
        ),
      ),
      body: Column(
        children: [
          // Optional composer placeholder (disabled)
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Share something to your neighbors…',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.edit_outlined,
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
          
          // Community posts list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: _mockPosts.length,
              itemBuilder: (context, index) {
                final post = _mockPosts[index];
                return CommunityPostCard(
                  post: post,
                  onTap: () {
                    // Navigate to community post detail
                    AppRouter.pushNamed(context, AppRouter.communityDetail);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create community post
          AppRouter.pushNamed(context, AppRouter.communityCreate);
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
