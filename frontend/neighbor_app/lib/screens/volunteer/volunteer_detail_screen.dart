import 'package:flutter/material.dart';
import '../../models/volunteer_item.dart';
import '../../widgets/volunteer/avatar_name_row.dart';
import '../../widgets/volunteer/volunteer_tag.dart';
import '../../widgets/common/info_row.dart';
import '../../widgets/common/primary_button.dart';
import '../../services/posts_api_service.dart';
import '../../services/auth_service.dart';

class VolunteerDetailScreen extends StatefulWidget {
  final Volunteer volunteer;
  final ValueChanged<String>? onDeleted;

  const VolunteerDetailScreen({
    super.key,
    required this.volunteer,
    this.onDeleted,
  });

  @override
  State<VolunteerDetailScreen> createState() => _VolunteerDetailScreenState();
}

class _VolunteerDetailScreenState extends State<VolunteerDetailScreen> {
  int? _currentUserId;
  bool _isOwnPost = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    final userId = await AuthService.getCurrentUserId();
    setState(() {
      _currentUserId = userId;
      _isOwnPost = userId != null && userId == widget.volunteer.userId;
    });
  }

  void _showDeleteConfirmation(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Confirmation content
            const Icon(
              Icons.delete_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Delete Volunteer Request',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Are you sure you want to delete this volunteer request? This action cannot be undone.',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF7A8A9A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            PrimaryButton(
              text: 'Delete Request',
              onPressed: () async {
                Navigator.pop(context); // Close the modal
                // Use a small delay to ensure modal is closed
                await Future.delayed(const Duration(milliseconds: 100));
                await _deleteVolunteerRequest(parentContext);
              },
              backgroundColor: Colors.red,
            ),
            const SizedBox(height: 12),
            
            PrimaryButton(
              text: 'Cancel',
              isSecondary: true,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteVolunteerRequest(BuildContext context) async {
    // Check if already deleting
    if (_isDeleting) return;
    
    // Check if user is logged in
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to delete requests'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user owns this post
    if (!_isOwnPost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only delete your own requests'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set deleting state
    setState(() {
      _isDeleting = true;
    });

    try {
      // Delete the volunteer request with timeout
      print('Deleting post with ID: ${widget.volunteer.id}');
      final success = await PostsApiService.deletePost(widget.volunteer.id)
          .timeout(const Duration(seconds: 10));
      print('Delete result: $success');

      if (success) {
        // Immediately inform parent list to update optimistically
        try {
          widget.onDeleted?.call(widget.volunteer.id);
        } catch (_) {}
        print('Delete successful, popping back immediately...');
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate deletion
        }
      } else {
        print('Delete failed - success was false');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete volunteer request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete volunteer request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Always reset deleting state
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showAcceptConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Confirmation content
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Color(0xFF27AE60),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Accept Help Request',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Are you sure you want to accept this volunteer request from ${widget.volunteer.requesterName}?',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF7A8A9A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            PrimaryButton(
              text: 'Confirm Accept',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help request accepted!'),
                    backgroundColor: Color(0xFF27AE60),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            
            PrimaryButton(
              text: 'Cancel',
              isSecondary: true,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text(
          'Volunteer Request',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with avatar, name, time, and tag
                    Row(
                      children: [
                        Expanded(
                          child: AvatarNameRow(
                            avatarUrl: widget.volunteer.avatarUrl,
                            name: widget.volunteer.requesterName,
                            timeAgo: widget.volunteer.timeAgo,
                          ),
                        ),
                        const VolunteerTag(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      widget.volunteer.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      widget.volunteer.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Details card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    InfoRow(
                      label: 'Date and Time:',
                      value: widget.volunteer.dateTime,
                    ),
                    
                    InfoRow(
                      label: 'Reward:',
                      value: widget.volunteer.reward,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons - different for own posts vs others' posts
            if (_isOwnPost) ...[
              // Own post - show Edit and Delete buttons
              PrimaryButton(
                text: 'Edit Request',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit functionality coming soon!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              
              PrimaryButton(
                text: _isDeleting ? 'Deleting...' : 'Delete Request',
                isSecondary: true,
                onPressed: _isDeleting ? null : () => _showDeleteConfirmation(context),
                backgroundColor: Colors.red,
              ),
            ] else ...[
              // Others' post - show Accept and Chat buttons
              PrimaryButton(
                text: 'Accept help',
                onPressed: () => _showAcceptConfirmation(context),
              ),
              const SizedBox(height: 12),
              
              PrimaryButton(
                text: 'Chat',
                isSecondary: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening chat...'),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
          // Loading overlay
          if (_isDeleting)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Deleting post...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
