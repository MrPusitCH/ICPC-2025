/// Community create screen for the Neighbor app
/// Form for creating new community posts
library;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../router/app_router.dart';
import '../../services/community_api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class CommunityCreateScreen extends StatefulWidget {
  const CommunityCreateScreen({super.key});

  @override
  State<CommunityCreateScreen> createState() => _CommunityCreateScreenState();
}

class _CommunityCreateScreenState extends State<CommunityCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  File? _selectedImage;
  XFile? _selectedXFile; // For web compatibility
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      print('🖼️ Starting image picker...');
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      print('🖼️ Image picker result: ${image?.path}');
      
      if (image != null) {
        print('🖼️ Image selected: ${image.path}');
        print('🖼️ Image name: ${image.name}');
        print('🖼️ Image size: ${await image.length()} bytes');
        
        setState(() {
          _selectedXFile = image;
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
        });
        
        print('🖼️ _selectedXFile set to: ${_selectedXFile?.path}');
        if (!kIsWeb) {
          print('🖼️ _selectedImage set to: ${_selectedImage?.path}');
        }
      } else {
        print('🖼️ No image selected');
      }
    } catch (e) {
      print('❌ Image picker error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedXFile = null;
    });
  }

  Future<void> _sendPost() async {
    if (_titleController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Prepare media data
      List<Map<String, dynamic>>? mediaData;
      if ((kIsWeb && _selectedXFile != null) || (!kIsWeb && _selectedImage != null)) {
        try {
          print('🖼️ Starting image upload...');
          Map<String, dynamic> uploadResult;
          
          // Use web-compatible upload if on web platform
          if (kIsWeb) {
            uploadResult = await CommunityApiService.uploadMediaWeb(_selectedXFile!);
          } else {
            uploadResult = await CommunityApiService.uploadMedia(_selectedImage!);
          }
          
          print('🖼️ Upload result: $uploadResult');
          
          if (uploadResult['success'] == true) {
            mediaData = [{
              'image_id': uploadResult['image_id'],
              'file_url': uploadResult['file_url'],
              'file_type': 'image',
              'file_name': uploadResult['file_name'],
              'file_size': uploadResult['file_size'],
              'mime_type': uploadResult['mime_type'],
            }];
            print('🖼️ Media data prepared: $mediaData');
          } else {
            print('🖼️ Upload failed: ${uploadResult['error']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: ${uploadResult['error']}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (uploadError) {
          print('🖼️ Upload error: $uploadError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading image: $uploadError'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('🖼️ No image selected');
      }

      // Get current user ID
      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) {
        Navigator.of(context).pop(); // Hide loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to create a post')),
        );
        return;
      }

      // Create post
      final result = await CommunityApiService.createPost(
        title: _titleController.text.trim(),
        content: _messageController.text.trim(),
        authorId: currentUserId,
        media: mediaData,
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        AppRouter.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: ${result['error']}')),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue, // Using theme color for consistency
        elevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => AppRouter.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              // TODO: Implement menu functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create Post label
            const Text(
              'Create Post',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title input field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title *',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            // Message input field
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Message *',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            
            // Photo selection row
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined, size: 20),
                  label: const Text('photos'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                if ((kIsWeb && _selectedXFile != null) || (!kIsWeb && _selectedImage != null)) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: kIsWeb 
                          ? NetworkImage(_selectedXFile!.path)
                          : FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kIsWeb 
                        ? _selectedXFile!.name
                        : _selectedImage!.path.split('/').last,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'delete photo',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            const Spacer(),
            
            // Send post button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _sendPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Send your post',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

