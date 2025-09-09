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
          // Make Post button/composer area
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: InkWell(
              onTap: () {
                // Navigate to create community post
                AppRouter.pushNamed(context, AppRouter.communityCreate);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                  vertical: AppTheme.spacing12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Text(
                        'Share something to your neighbors…',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ],
                ),
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
