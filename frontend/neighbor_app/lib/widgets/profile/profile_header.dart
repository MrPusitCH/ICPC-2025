import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileHeader extends StatefulWidget {
  final String avatar;
  final String name;
  final String gender;
  final String age;
  final String address;
  final Function(String)? onAvatarChanged;

  const ProfileHeader({
    super.key,
    required this.avatar,
    required this.name,
    required this.gender,
    required this.age,
    required this.address,
    this.onAvatarChanged,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final ImagePicker _picker = ImagePicker();
  String? _currentAvatar;
  File? _selectedImage;
  XFile? _selectedXFile;

  @override
  void initState() {
    super.initState();
    _currentAvatar = widget.avatar;
  }

  @override
  void didUpdateWidget(ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.avatar != oldWidget.avatar) {
      _currentAvatar = widget.avatar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: _selectPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 36, // 72px diameter
                    backgroundImage: _buildAvatarImage(),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4FC3F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Name and info grid
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Aligned info grid (Label : Value)
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FixedColumnWidth(80), // label width
                      1: FixedColumnWidth(12), // colon spacer
                      2: IntrinsicColumnWidth(),
                    },
                    children: [
                      TableRow(children: [
                        const _InfoText('Gender'),
                        const _InfoText(':'),
                        _InfoValue(widget.gender),
                      ]),
                      TableRow(children: [
                        const _InfoText('Age'),
                        const _InfoText(':'),
                        _InfoValue(widget.age),
                      ]),
                      TableRow(children: [
                        const _InfoText('Address'),
                        const _InfoText(':'),
                        _InfoValue(widget.address),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 90,
      );
      
      if (image != null) {
        setState(() {
          if (kIsWeb) {
            _selectedXFile = image;
            _currentAvatar = image.path;
          } else {
            _selectedImage = File(image.path);
            _currentAvatar = image.path;
          }
        });
        
        // Upload the image and get the URL
        await _uploadProfilePhoto();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting photo: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _uploadProfilePhoto() async {
    try {
      // Import the community API service for uploading
      // Note: You might want to create a dedicated profile service for this
      String? uploadedUrl;
      
      if (kIsWeb && _selectedXFile != null) {
        // For web, we'll use a placeholder for now
        // You can implement actual upload logic here
        uploadedUrl = _selectedXFile!.path;
      } else if (!kIsWeb && _selectedImage != null) {
        // For mobile, we'll use a placeholder for now
        // You can implement actual upload logic here
        uploadedUrl = _selectedImage!.path;
      }
      
      if (uploadedUrl != null && widget.onAvatarChanged != null) {
        widget.onAvatarChanged!(uploadedUrl);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  ImageProvider? _buildAvatarImage() {
    if (_currentAvatar == null) return null;
    
    // Check if it's a local file path or server/network URL
    bool isLocalFile = (_currentAvatar!.startsWith('/') && !_currentAvatar!.startsWith('http')) || 
                      _currentAvatar!.contains('\\');
    bool isBlobUrl = _currentAvatar!.startsWith('blob:');
    bool isApiUrl = _currentAvatar!.startsWith('/api/');
    
    // For web platform, always use Image.network for blob URLs
    if (isBlobUrl) {
      isLocalFile = false;
    }
    
    if (isLocalFile && !kIsWeb && _selectedImage != null) {
      return FileImage(_selectedImage!);
    } else {
      String imageUrl = isBlobUrl ? _currentAvatar! :
                       isApiUrl ? 'http://127.0.0.1:3000$_currentAvatar' : 
                       _currentAvatar!;
      return NetworkImage(imageUrl);
    }
  }
}

class _InfoText extends StatelessWidget {
  final String text;
  const _InfoText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF7A8A9A),
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _InfoValue extends StatelessWidget {
  final String text;
  const _InfoValue(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.w500,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}