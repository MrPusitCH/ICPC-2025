/// Activity detail screen for the Neighbor app
/// Shows detailed information about a specific activity
library;
import 'package:flutter/material.dart';
import '../../models/activity_item.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../widgets/common/fallback_map_widget.dart';
import '../../services/activity_api_service.dart';

class ActivityDetailScreen extends StatefulWidget {
  final ActivityItem? activity;
  
  const ActivityDetailScreen({super.key, this.activity});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  ActivityItem? _activity;
  bool _isLoading = true;
  String? _error;
  bool _isJoined = false;
  List<Map<String, dynamic>> _participants = [];
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Don't call _loadActivity here as it accesses inherited widgets
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _loadActivity here after inherited widgets are available
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadActivity();
    }
  }

  Future<void> _loadActivity() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      ActivityItem? activity = widget.activity;
      
      // If no activity passed, try to get from route arguments
      if (activity == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is ActivityItem) {
          activity = args;
        }
      }

      if (activity != null) {
        // Load fresh data from API
        final freshActivity = await ActivityApiService.getActivityById(activity.activityId);
        final participants = await ActivityApiService.getActivityParticipants(activity.activityId);
        
        setState(() {
          _activity = freshActivity;
          _participants = participants;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No activity data provided';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Activity Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4FC3F7), // Light blue
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => AppRouter.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading activity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_activity == null) {
      return const Center(
        child: Text(
          'Activity not found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          _buildInfoSection(
            'Title',
            _activity!.title,
          ),
          
          const SizedBox(height: AppTheme.spacing20),
          
          // Description section
          _buildInfoSection(
            'Description',
            _activity!.description,
          ),
          
          const SizedBox(height: AppTheme.spacing20),
          
          // Date and Time section
          _buildInfoSection(
            'Date and Time',
            '${_activity!.date} at ${_activity!.time}${_activity!.endTime != null ? ' - ${_activity!.endTime}' : ''}',
          ),
          
          const SizedBox(height: AppTheme.spacing20),
          
          // Place section
          _buildInfoSection(
            'Place',
            _activity!.place,
          ),
          
          const SizedBox(height: AppTheme.spacing20),
          
          // Map section
          if (_activity!.latitude != null && _activity!.longitude != null)
            _buildMapSection(),
          
          const SizedBox(height: AppTheme.spacing20),
          
          // Participants section
          _buildParticipantsSection(),
          
          const SizedBox(height: AppTheme.spacing20),
          
          // Posted by section
          _buildPostedBySection(),
          
          const SizedBox(height: AppTheme.spacing32),
          
          // Join/Leave button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FallbackMapWidget(
              height: 200,
              title: 'Activity Location',
              address: _activity!.place,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participants',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${_activity!.participantText}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 12),
        if (_participants.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _participants.map((participant) {
              return _buildParticipantChip(participant);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildParticipantChip(Map<String, dynamic> participant) {
    final name = participant['name'] ?? 'Unknown';
    final avatar = participant['avatar'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            radius: 12,
            backgroundColor: const Color(0xFF4FC3F7),
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? Text(
                    _getInitials(name),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _buildActionButton() {
    if (_activity!.joined >= _activity!.capacity) {
      return SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Activity is Full',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isJoined ? _leaveActivity : _joinActivity,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isJoined ? Colors.red : const Color(0xFF4FC3F7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _isJoined ? 'Leave Activity' : 'Join Activity',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _joinActivity() async {
    try {
      await ActivityApiService.joinActivity(_activity!.activityId);
      setState(() {
        _isJoined = true;
        _activity = ActivityItem(
          activityId: _activity!.activityId,
          title: _activity!.title,
          description: _activity!.description,
          date: _activity!.date,
          time: _activity!.time,
          place: _activity!.place,
          location: _activity!.location,
          latitude: _activity!.latitude,
          longitude: _activity!.longitude,
          capacity: _activity!.capacity,
          joined: _activity!.joined + 1,
          comments: _activity!.comments,
          views: _activity!.views,
          imageUrl: _activity!.imageUrl,
          imageName: _activity!.imageName,
          authorId: _activity!.authorId,
          authorName: _activity!.authorName,
          authorAvatar: _activity!.authorAvatar,
          createdAt: _activity!.createdAt,
          updatedAt: _activity!.updatedAt,
          isActive: _activity!.isActive,
          endTime: _activity!.endTime,
          category: _activity!.category,
        );
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You joined ${_activity!.title}'),
          backgroundColor: const Color(0xFF4FC3F7),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join activity: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _leaveActivity() async {
    try {
      await ActivityApiService.leaveActivity(_activity!.activityId);
      setState(() {
        _isJoined = false;
        _activity = ActivityItem(
          activityId: _activity!.activityId,
          title: _activity!.title,
          description: _activity!.description,
          date: _activity!.date,
          time: _activity!.time,
          place: _activity!.place,
          location: _activity!.location,
          latitude: _activity!.latitude,
          longitude: _activity!.longitude,
          capacity: _activity!.capacity,
          joined: _activity!.joined - 1,
          comments: _activity!.comments,
          views: _activity!.views,
          imageUrl: _activity!.imageUrl,
          imageName: _activity!.imageName,
          authorId: _activity!.authorId,
          authorName: _activity!.authorName,
          authorAvatar: _activity!.authorAvatar,
          createdAt: _activity!.createdAt,
          updatedAt: _activity!.updatedAt,
          isActive: _activity!.isActive,
          endTime: _activity!.endTime,
          category: _activity!.category,
        );
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You left the activity'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to leave activity: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPostedBySection() {
    return Row(
      children: [
        const Text(
          'Posted by :',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: _activity!.authorAvatar != null 
              ? NetworkImage(_activity!.authorAvatar!)
              : null,
          child: _activity!.authorAvatar == null
              ? const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 16,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          _activity!.authorName,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

