import 'package:flutter/material.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_section_card.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Get user ID from authentication service
      print('ProfileScreen: Getting current user ID...');
      final userId = await AuthService.getCurrentUserId();
      print('ProfileScreen: Retrieved user ID: $userId');
      
      if (userId == null) {
        print('ProfileScreen: No user ID found - user not logged in');
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }
      
      print('ProfileScreen: Loading profile for user ID: $userId');
      final profile = await ProfileService.getUserProfile(userId);
      print('ProfileScreen: Profile loaded successfully');
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('ProfileScreen: Error loading profile: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Settings icon
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF1E88E5),
              size: 24,
            ),
            onPressed: () {
              // Navigate to settings screen if it exists
              try {
                Navigator.pushNamed(context, '/settings');
              } catch (e) {
                // Show placeholder message if route doesn't exist
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings screen coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          // Edit icon
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF1E88E5),
              size: 24,
            ),
            onPressed: () {
              // Navigate to profile edit screen if it exists
              try {
                Navigator.pushNamed(context, '/profile/edit');
              } catch (e) {
                // Show placeholder message if route doesn't exist
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile edit screen coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1E88E5),
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
              color: Color(0xFF7A8A9A),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7A8A9A),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_userProfile == null) {
      return const Center(
        child: Text(
          'No profile data available',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7A8A9A),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          ProfileHeader(
            avatar: _userProfile!.avatarUrl,
            name: _userProfile!.name,
            gender: _userProfile!.gender,
            age: _userProfile!.age,
            address: _userProfile!.address,
          ),
          const SizedBox(height: 16),
          
          // Section Header
          const Text(
            'Detailed profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          
          // Disease Section
          ProfileSectionCard(
            title: 'Disease',
            items: _userProfile!.diseases,
          ),
          const SizedBox(height: 12),
          
          // Living Situation Section
          ProfileSectionCard(
            title: 'Living situation',
            items: _userProfile!.livingSituation,
          ),
          const SizedBox(height: 32), // Bottom padding
        ],
      ),
    );
  }
}
