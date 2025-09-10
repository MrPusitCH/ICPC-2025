/// Community detail screen for the Neighbor app
/// Shows detailed information about a specific community post
library;
import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../models/community_post.dart';
import '../../services/community_api_service.dart';
import '../../services/auth_service.dart';

class CommunityDetailScreen extends StatefulWidget {
  final VoidCallback? onPostDeleted;
  
  const CommunityDetailScreen({
    super.key,
    this.onPostDeleted,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  CommunityPost? _post;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int? _postId;
  
  // Comment input
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  
  // Current user info
  int? _currentUserId;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    // Load user info and post
    _loadUserAndPost();
  }

  Future<void> _loadUserAndPost() async {
    // Load current user info
    _currentUserId = await AuthService.getCurrentUserId();
    _isAdmin = await AuthService.isCurrentUserAdmin();
    
    // Load the post
    _loadPost();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    // Get post ID from arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _postId = args?['postId'];

    print('Loading post with ID: $_postId');

    if (_postId == null) {
      print('Error: Post ID not provided');
      setState(() {
        _hasError = true;
        _errorMessage = 'Post ID not provided';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      print('Calling CommunityApiService.getPost($_postId)');
      final result = await CommunityApiService.getPost(_postId!);
      print('API result: $result');

      if (result['success'] && result['post'] != null) {
        print('Successfully loaded post: ${(result['post'] as CommunityPost).title}');
        if (mounted) {
          setState(() {
            _post = result['post'] as CommunityPost;
            _isLoading = false;
          });
        }
      } else {
        print('API returned error: ${result['error']}');
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = result['error'] ?? 'Failed to load post';
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

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty || _post == null) return;

    final commentText = _commentController.text.trim();
    _commentController.clear();

    // Get current user's name and avatar first
    final currentUserName = await AuthService.getCurrentUserName();
    final currentUserAvatar = await AuthService.getCurrentUserAvatar();
    
    // Optimistically update UI immediately (like Facebook)
    setState(() {
      _isSubmittingComment = true;
      // Add comment to UI immediately
      final newComment = CommunityComment(
        commentId: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        postId: _post!.postId,
        authorId: _currentUserId ?? 1,
        authorName: currentUserName,
        authorAvatar: currentUserAvatar,
        content: commentText,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentId: null,
      );
      _post = CommunityPost(
        postId: _post!.postId,
        title: _post!.title,
        content: _post!.content,
        authorId: _post!.authorId,
        authorName: _post!.authorName,
        authorAvatar: _post!.authorAvatar,
        createdAt: _post!.createdAt,
        updatedAt: _post!.updatedAt,
        isPublished: _post!.isPublished,
        viewCount: _post!.viewCount,
        likeCount: _post!.likeCount,
        commentCount: _post!.commentCount + 1, // Increment count
        media: _post!.media,
        comments: [..._post!.comments, newComment], // Add new comment
        isLiked: _post!.isLiked,
      );
    });

    try {
      final result = await CommunityApiService.createComment(
        postId: _post!.postId,
        authorId: _currentUserId ?? 1,
        content: commentText,
      );

      if (result['success']) {
        // Update with real comment data from server
        final realComment = result['comment'] as CommunityComment?;
        if (realComment != null) {
          setState(() {
            _post = CommunityPost(
              postId: _post!.postId,
              title: _post!.title,
              content: _post!.content,
              authorId: _post!.authorId,
              authorName: _post!.authorName,
              authorAvatar: _post!.authorAvatar,
              createdAt: _post!.createdAt,
              updatedAt: _post!.updatedAt,
              isPublished: _post!.isPublished,
              viewCount: _post!.viewCount,
              likeCount: _post!.likeCount,
              commentCount: _post!.commentCount,
              media: _post!.media,
              comments: _post!.comments.map((c) => 
                c.commentId == realComment.commentId ? realComment : c
              ).toList(),
              isLiked: _post!.isLiked,
            );
          });
        }
      } else {
        // Revert optimistic update on failure
        setState(() {
          _post = CommunityPost(
            postId: _post!.postId,
            title: _post!.title,
            content: _post!.content,
            authorId: _post!.authorId,
            authorName: _post!.authorName,
            authorAvatar: _post!.authorAvatar,
            createdAt: _post!.createdAt,
            updatedAt: _post!.updatedAt,
            isPublished: _post!.isPublished,
            viewCount: _post!.viewCount,
            likeCount: _post!.likeCount,
            commentCount: _post!.commentCount - 1, // Revert count
            media: _post!.media,
            comments: _post!.comments.where((c) => c.commentId != DateTime.now().millisecondsSinceEpoch).toList(),
            isLiked: _post!.isLiked,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to add comment')),
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        _post = CommunityPost(
          postId: _post!.postId,
          title: _post!.title,
          content: _post!.content,
          authorId: _post!.authorId,
          authorName: _post!.authorName,
          authorAvatar: _post!.authorAvatar,
          createdAt: _post!.createdAt,
          updatedAt: _post!.updatedAt,
          isPublished: _post!.isPublished,
          viewCount: _post!.viewCount,
          likeCount: _post!.likeCount,
          commentCount: _post!.commentCount - 1, // Revert count
          media: _post!.media,
          comments: _post!.comments.where((c) => c.commentId != DateTime.now().millisecondsSinceEpoch).toList(),
          isLiked: _post!.isLiked,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSubmittingComment = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;

    // Optimistically update UI immediately (like Facebook)
    final currentLiked = _post!.isLiked;
    final currentLikeCount = _post!.likeCount;
    
    setState(() {
      _post = CommunityPost(
        postId: _post!.postId,
        title: _post!.title,
        content: _post!.content,
        authorId: _post!.authorId,
        authorName: _post!.authorName,
        authorAvatar: _post!.authorAvatar,
        createdAt: _post!.createdAt,
        updatedAt: _post!.updatedAt,
        isPublished: _post!.isPublished,
        viewCount: _post!.viewCount,
        likeCount: currentLiked ? currentLikeCount - 1 : currentLikeCount + 1, // Update count immediately
        commentCount: _post!.commentCount,
        media: _post!.media,
        comments: _post!.comments,
        isLiked: !currentLiked, // Toggle like immediately
      );
    });

    try {
      final result = await CommunityApiService.toggleLike(
        postId: _post!.postId,
        userId: _currentUserId ?? 1,
      );

      if (result['success']) {
        // Update with real data from server
        final liked = result['data']?['liked'] ?? !currentLiked;
        final likeCount = result['data']?['likeCount'] ?? (liked ? currentLikeCount + 1 : currentLikeCount - 1);
        
        setState(() {
          _post = CommunityPost(
            postId: _post!.postId,
            title: _post!.title,
            content: _post!.content,
            authorId: _post!.authorId,
            authorName: _post!.authorName,
            authorAvatar: _post!.authorAvatar,
            createdAt: _post!.createdAt,
            updatedAt: _post!.updatedAt,
            isPublished: _post!.isPublished,
            viewCount: _post!.viewCount,
            likeCount: likeCount,
            commentCount: _post!.commentCount,
            media: _post!.media,
            comments: _post!.comments,
            isLiked: liked,
          );
        });
      } else {
        // Revert optimistic update on failure
        setState(() {
          _post = CommunityPost(
            postId: _post!.postId,
            title: _post!.title,
            content: _post!.content,
            authorId: _post!.authorId,
            authorName: _post!.authorName,
            authorAvatar: _post!.authorAvatar,
            createdAt: _post!.createdAt,
            updatedAt: _post!.updatedAt,
            isPublished: _post!.isPublished,
            viewCount: _post!.viewCount,
            likeCount: currentLikeCount, // Revert count
            commentCount: _post!.commentCount,
            media: _post!.media,
            comments: _post!.comments,
            isLiked: currentLiked, // Revert like status
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to update like')),
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        _post = CommunityPost(
          postId: _post!.postId,
          title: _post!.title,
          content: _post!.content,
          authorId: _post!.authorId,
          authorName: _post!.authorName,
          authorAvatar: _post!.authorAvatar,
          createdAt: _post!.createdAt,
          updatedAt: _post!.updatedAt,
          isPublished: _post!.isPublished,
          viewCount: _post!.viewCount,
          likeCount: currentLikeCount, // Revert count
          commentCount: _post!.commentCount,
          media: _post!.media,
          comments: _post!.comments,
          isLiked: currentLiked, // Revert like status
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteComment(int commentId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Optimistically remove comment from UI
    setState(() {
      _post = CommunityPost(
        postId: _post!.postId,
        title: _post!.title,
        content: _post!.content,
        authorId: _post!.authorId,
        authorName: _post!.authorName,
        authorAvatar: _post!.authorAvatar,
        createdAt: _post!.createdAt,
        updatedAt: _post!.updatedAt,
        isPublished: _post!.isPublished,
        viewCount: _post!.viewCount,
        likeCount: _post!.likeCount,
        commentCount: _post!.commentCount - 1, // Decrement count
        media: _post!.media,
        comments: _post!.comments.where((c) => c.commentId != commentId).toList(), // Remove comment
        isLiked: _post!.isLiked,
      );
    });

    try {
      final result = await CommunityApiService.deleteComment(commentId);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully!')),
        );
      } else {
        // Revert optimistic update on failure
        setState(() {
          _post = CommunityPost(
            postId: _post!.postId,
            title: _post!.title,
            content: _post!.content,
            authorId: _post!.authorId,
            authorName: _post!.authorName,
            authorAvatar: _post!.authorAvatar,
            createdAt: _post!.createdAt,
            updatedAt: _post!.updatedAt,
            isPublished: _post!.isPublished,
            viewCount: _post!.viewCount,
            likeCount: _post!.likeCount,
            commentCount: _post!.commentCount + 1, // Revert count
            media: _post!.media,
            comments: [..._post!.comments, _post!.comments.firstWhere((c) => c.commentId == commentId)], // Restore comment
            isLiked: _post!.isLiked,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to delete comment')),
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        _post = CommunityPost(
          postId: _post!.postId,
          title: _post!.title,
          content: _post!.content,
          authorId: _post!.authorId,
          authorName: _post!.authorName,
          authorAvatar: _post!.authorAvatar,
          createdAt: _post!.createdAt,
          updatedAt: _post!.updatedAt,
          isPublished: _post!.isPublished,
          viewCount: _post!.viewCount,
          likeCount: _post!.likeCount,
          commentCount: _post!.commentCount + 1, // Revert count
          media: _post!.media,
          comments: [..._post!.comments, _post!.comments.firstWhere((c) => c.commentId == commentId)], // Restore comment
          isLiked: _post!.isLiked,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deletePost() async {
    if (_post == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await CommunityApiService.deletePost(_post!.postId);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully!')),
        );
        // Call callback to refresh parent page
        widget.onPostDeleted?.call();
        // Navigate back to feed
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to delete post')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

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
        actions: [
          // Show delete button if current user is the post author OR if user is admin
          if (_post != null && (_post!.authorId == _currentUserId || _isAdmin))
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deletePost,
              tooltip: _isAdmin ? 'Delete Post (Admin)' : 'Delete Post',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          if (_post != null) _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
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
              'Failed to load post',
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
              onPressed: _loadPost,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_post == null) {
      return const Center(
        child: Text('Post not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _post!.authorAvatar != null
                    ? NetworkImage(_post!.authorAvatar!)
                    : null,
                child: _post!.authorAvatar == null
                    ? Text(_post!.authorName.isNotEmpty ? _post!.authorName[0].toUpperCase() : '?')
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post!.authorName,
                      style: AppTheme.titleSmall,
                    ),
                    Text(
                      _post!.timeAgo,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Post title
          Text(
            _post!.title,
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          // Post content
          Text(
            _post!.content,
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Media attachments
          if (_post!.media.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildMediaDisplay(_post!.media),
          ],

          // Stats
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${_post!.viewCount} views',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: _toggleLike,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _post!.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: _post!.isLiked ? Colors.red : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_post!.likeCount} likes',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.comment,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${_post!.commentCount} comments',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Comments section
          Text(
            'Comments',
            style: AppTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          if (_post!.commentsList.isEmpty)
            Text(
              'No comments yet. Be the first to comment!',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            )
          else
            ...(_post!.commentsList.map((comment) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: comment.authorAvatar != null
                            ? NetworkImage(comment.authorAvatar!)
                            : null,
                        child: comment.authorAvatar == null
                            ? Text(comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?')
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          comment.authorName,
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _getTimeAgo(comment.createdAt),
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      // Show delete button if current user is the comment author OR if user is admin
                      if (comment.authorId == _currentUserId || _isAdmin) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _deleteComment(comment.commentId),
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment.content,
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ))),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _isSubmittingComment ? null : _submitComment,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isSubmittingComment 
                    ? Colors.grey.shade300 
                    : AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: _isSubmittingComment
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 16,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Widget _buildMediaDisplay(List<PostMedia> media) {
    if (media.isEmpty) return const SizedBox.shrink();
    
    // Use the actual media URL from the database
    String imageUrl = media.first.fileUrl;
    
    // Check if it's a local file path or server/network URL
    bool isLocalFile = (imageUrl.startsWith('/') && !imageUrl.startsWith('http')) || imageUrl.contains('\\');
    bool isBlobUrl = imageUrl.startsWith('blob:');
    
    // For web platform, always use Image.network for blob URLs
    if (isBlobUrl) {
      isLocalFile = false;
    }
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isLocalFile 
          ? Image.file(
              File(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Detail screen local image load error for $imageUrl: $error');
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 48,
                  ),
                );
              },
            )
          : Image.network(
              isBlobUrl 
                ? imageUrl  // Blob URL (for web)
                : imageUrl.startsWith('/') 
                  ? 'http://localhost:3000$imageUrl'  // Server URL
                  : imageUrl,  // External URL
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Detail screen network image load error for $imageUrl: $error');
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 48,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
      ),
    );
  }
}

