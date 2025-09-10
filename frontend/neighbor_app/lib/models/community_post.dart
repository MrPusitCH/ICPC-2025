/// Community post model for the Neighbor app
/// Contains data structure for community posts and discussions
class CommunityPost {
  final int postId;
  final String title;
  final String content;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final List<PostMedia> media;
  final List<CommunityComment> comments;
  final bool isLiked;

  const CommunityPost({
    required this.postId,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = true,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.media = const [],
    this.comments = const [],
    this.isLiked = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      postId: json['post_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorId: json['author_id'] ?? 0,
      authorName: json['author']?['profile']?['full_name'] ?? 
                 json['author']?['email'] ?? 'Unknown User',
      authorAvatar: json['author']?['profile']?['profile_image_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isPublished: json['is_published'] ?? true,
      viewCount: json['view_count'] ?? 0,
      likeCount: json['_count']?['likes'] ?? json['like_count'] ?? 0,
      commentCount: json['_count']?['comments'] ?? json['comment_count'] ?? 0,
      media: (json['media'] as List<dynamic>?)
          ?.map((m) => PostMedia.fromJson(m))
          .toList() ?? [],
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => CommunityComment.fromJson(c))
          .toList() ?? [],
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'title': title,
      'content': content,
      'author_id': authorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_published': isPublished,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'media': media.map((m) => m.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  // Helper getters for backward compatibility
  String get userName => authorName;
  String get timeAgo => _getTimeAgo(createdAt);
  String get body => content;
  int get commentsCount => commentCount;
  int get views => viewCount;
  String get avatarUrl => authorAvatar ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face';
  
  // Getter for comments list (not count)
  List<CommunityComment> get commentsList => comments;

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
}

/// Post media model for attachments
class PostMedia {
  final int mediaId;
  final int postId;
  final String fileUrl;
  final String fileType;
  final String fileName;
  final int? fileSize;
  final String? mimeType;
  final DateTime createdAt;

  const PostMedia({
    required this.mediaId,
    required this.postId,
    required this.fileUrl,
    required this.fileType,
    required this.fileName,
    this.fileSize,
    this.mimeType,
    required this.createdAt,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      mediaId: json['media_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      fileUrl: json['file_url'] ?? '',
      fileType: json['file_type'] ?? 'image',
      fileName: json['file_name'] ?? '',
      fileSize: json['file_size'],
      mimeType: json['mime_type'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaId,
      'post_id': postId,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Community comment model
class CommunityComment {
  final int commentId;
  final int postId;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final int? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final List<CommunityComment> replies;

  const CommunityComment({
    required this.commentId,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.replies = const [],
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      commentId: json['comment_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      authorId: json['author_id'] ?? 0,
      authorName: json['author']?['profile']?['full_name'] ?? 
                 json['author']?['email'] ?? 'Unknown User',
      authorAvatar: json['author']?['profile']?['profile_image_url'],
      content: json['content'] ?? '',
      parentId: json['parent_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isDeleted: json['is_deleted'] ?? false,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((r) => CommunityComment.fromJson(r))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'post_id': postId,
      'author_id': authorId,
      'content': content,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }
}

