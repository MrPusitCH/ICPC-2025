import 'package:flutter/material.dart';
import '../../widgets/profile/profile_header.dart';
import '../../services/profile_service.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_profile.dart';
import '../../router/app_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
      final userId = await AuthService.getCurrentUserId();
      if (userId == null) {
        // For testing: use mock API service
        final profile = await ApiService.getUserProfile();
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
        return;
      }
      
      var profile = await ProfileService.getUserProfile(userId);

      // Fallback: if API has no health/living data, use mock to populate UI
      if ((profile.diseases.isEmpty) && (profile.livingSituation.isEmpty)) {
        final mock = await ApiService.getUserProfile();
        profile = UserProfile(
          userId: profile.userId,
          name: profile.name.isNotEmpty ? profile.name : mock.name,
          nickname: profile.nickname ?? mock.nickname,
          gender: profile.gender.isNotEmpty ? profile.gender : mock.gender,
          age: profile.age.isNotEmpty ? profile.age : mock.age,
          address: profile.address.isNotEmpty ? profile.address : mock.address,
          avatarUrl: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : mock.avatarUrl,
          diseases: mock.diseases,
          livingSituation: mock.livingSituation,
          interests: profile.interests ?? mock.interests,
          emergencyContacts: profile.emergencyContacts ?? mock.emergencyContacts,
        );
      }

      // Force age to 60 as requested
      profile = UserProfile(
        userId: profile.userId,
        name: profile.name,
        nickname: profile.nickname,
        gender: profile.gender,
        age: '60',
        address: profile.address,
        avatarUrl: profile.avatarUrl,
        diseases: profile.diseases,
        livingSituation: profile.livingSituation,
        interests: profile.interests,
        emergencyContacts: profile.emergencyContacts,
      );

      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showOwnAppBar = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: showOwnAppBar
          ? AppBar(
              backgroundColor: const Color(0xFF4FC3F7),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => AppRouter.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menu pressed'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            )
          : null,
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'profile_edit_fab',
        onPressed: () async {
          await AppRouter.pushNamed(context, AppRouter.profileEdit);
          if (mounted) {
            _loadUserProfile();
          }
        },
        backgroundColor: const Color(0xFF4FC3F7),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
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

          // Disease bordered section
          _BorderedSection(
            title: 'Disease',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in _userProfile!.diseases)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16, color: Color(0xFF1A1A1A))),
                        Expanded(
                          child: Text(
                            item.text,
                            style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A1A), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Living situation bordered section
          _BorderedSection(
            title: 'Living Situation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userProfile!.livingSituation.isNotEmpty
                      ? _userProfile!.livingSituation.first.text
                      : '-',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A1A), height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Family list header
          const Text(
            'Family List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          // Family avatars with labels
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _FamilyAvatar(
                  imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=120&h=120&fit=crop&crop=face',
                  label: 'First child (42)',
                ),
                SizedBox(width: 16),
                _FamilyAvatar(
                  imageUrl: 'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=120&h=120&fit=crop&crop=face',
                  label: 'Second child (40)',
                ),
                SizedBox(width: 16),
                _FamilyAvatar(
                  imageUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=120&h=120&fit=crop&crop=face',
                  label: 'Third child (38)',
                ),
                SizedBox(width: 16),
                _FamilyAvatar(
                  imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=120&h=120&fit=crop&crop=face',
                  label: 'Fourth child (20)',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Emergency Call
          const Text(
            'Emergency Call',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _EmergencyButton(
                icon: Icons.medical_services,
                label: 'hospital',
                onTap: () => _showEmergencySheet(context, '1669', 'hospital'),
              ),
              const SizedBox(width: 16),
              _EmergencyButton(
                icon: Icons.local_police,
                label: 'police',
                filled: true,
                onTap: () => _showEmergencySheet(context, '191', 'police'),
              ),
              const SizedBox(width: 16),
              _EmergencyButton(
                icon: Icons.local_fire_department,
                label: 'fire department',
                onTap: () => _showEmergencySheet(context, '199', 'fire department'),
              ),
            ],
          ),

          const SizedBox(height: 32), // Bottom padding
        ],
      ),
    );
  }
}

/// Simple bordered section with a bold title like the mock
class _BorderedSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _BorderedSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _FamilyAvatar extends StatelessWidget {
  final String imageUrl;
  final String label;
  const _FamilyAvatar({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
        ),
      ],
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  const _EmergencyButton({required this.icon, required this.label, this.filled = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: filled ? const Color(0xFF7B1FA2).withValues(alpha: 0.12) : Colors.transparent,
                border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 28, color: filled ? const Color(0xFF7B1FA2) : const Color(0xFF1A1A1A)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
        ),
      ],
    );
  }
}

Future<void> _showEmergencySheet(BuildContext context, String number, String label) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'emergency call',
                    style: TextStyle(fontSize: 14, color: Color(0xFF7A8A9A)),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF7A8A9A)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Big number
              Text(
                number,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              // Call button styled like dial action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri(scheme: 'tel', path: number);
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                    if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.phone, color: Colors.white),
                  label: const Text(
                    'Call this number',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047), // green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.black.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
