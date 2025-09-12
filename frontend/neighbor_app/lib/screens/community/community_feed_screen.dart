import 'package:flutter/material.dart';
import '../../widgets/community/community_post_card.dart';
import '../../models/community_post.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import 'community_detail_screen.dart';
import '../../services/community_api_service.dart';
import '../../services/auth_service.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  List<CommunityPost> _posts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreData = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserAndPosts();
  }

  Future<void> _loadUserAndPosts() async {
    // Load current user ID first
    _currentUserId = await AuthService.getCurrentUserId();
    print('Current user ID: $_currentUserId');
    
    // Then load the posts
    await _loadPosts();
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) {
      if (mounted) {
        setState(() {
          _currentPage = 1;
          _hasMoreData = true;
          _posts.clear();
        });
      }
    }

    if (!_hasMoreData) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      print('Loading posts...');
      final result = await CommunityApiService.getPosts(
        page: _currentPage,
        limit: 10,
      );

      print('API result: $result');

      if (result['success']) {
        final newPosts = result['posts'] as List<CommunityPost>;
        final pagination = result['pagination'] as Map<String, dynamic>;
        
        print('Successfully loaded ${newPosts.length} posts');
        
        if (mounted) {
          setState(() {
            if (refresh) {
              _posts = newPosts;
            } else {
              _posts.addAll(newPosts);
            }
            _hasMoreData = _currentPage < (pagination['totalPages'] ?? 1);
            _currentPage++;
            _isLoading = false;
          });
        }
      } else {
        print('API returned error: ${result['error']}');
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = result['error'] ?? 'Failed to load posts';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Exception caught: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPosts() async {
    await _loadPosts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final showOwnAppBar = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: showOwnAppBar
          ? AppBar(
              title: const Text(
                'Community',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF20B2AA),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: _buildPostsList(),
      floatingActionButton: FloatingActionButton(
        heroTag: "community_fab",
        onPressed: () async {
          // Navigate to create community post
          await AppRouter.pushNamed(context, AppRouter.communityCreate);
          // Refresh posts when returning from create screen
          if (mounted) {
            _refreshPosts();
          }
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_isLoading && _posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError && _posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load posts',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share something with your neighbors!',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshPosts,
              child: const Text('Load Posts'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _posts.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          print('Building item $index of ${_posts.length + (_hasMoreData ? 1 : 0)}');
          
          if (index == _posts.length) {
            // Loading indicator for pagination
            if (_isLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              // Load more button
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => _loadPosts(),
                    child: const Text('Load More'),
                  ),
                ),
              );
            }
          }

          final post = _posts[index];
          print('Building post card for: ${post.title}');
          return CommunityPostCard(
            post: post,
            onTap: () async {
              // Navigate to community post detail with callback
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityDetailScreen(
                    onPostDeleted: () {
                      // Only refresh if the widget is still mounted
                      if (mounted) {
                        _refreshPosts();
                      }
                    },
                  ),
                  settings: RouteSettings(
                    arguments: {'postId': post.postId},
                  ),
                ),
              );
              // Refresh posts when returning from detail screen
              // Only refresh if we actually have posts to avoid unnecessary API calls
              if (mounted && _posts.isNotEmpty) {
                _refreshPosts();
              }
            },
          );
        },
      ),
    );
  }
}
