/// Activity create screen for the Neighbor app
/// Form for creating new community activities
library;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../widgets/common/location_search_widget.dart';
import '../../widgets/common/location_map_widget.dart';
import '../../services/activity_api_service.dart';
import '../../services/community_api_service.dart';

class ActivityCreateScreen extends StatefulWidget {
  const ActivityCreateScreen({super.key});

  @override
  State<ActivityCreateScreen> createState() => _ActivityCreateScreenState();
}

class _ActivityCreateScreenState extends State<ActivityCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _placeController = TextEditingController();
  final _participationLimitController = TextEditingController();

  String? _selectedImagePath;
  String? _selectedImageName;
  File? _selectedImage;
  XFile? _selectedXFile; // For web compatibility
  String? _selectedLocation;
  LatLng? _selectedLatLng;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _placeController.dispose();
    _participationLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Gather friends for Activity',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              _buildTextField(
                controller: _titleController,
                label: 'Title *',
                hintText: 'Enter activity title',
                maxLines: 1,
              ),
              
              const SizedBox(height: AppTheme.spacing16),
              
              // Message field
              _buildTextField(
                controller: _messageController,
                label: 'Message *',
                hintText: 'Describe your activity...',
                maxLines: 4,
              ),
              
              const SizedBox(height: AppTheme.spacing16),
              
              // Date and Time row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _dateController,
                      label: 'Date *',
                      hintText: 'Select date',
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: _buildTextField(
                      controller: _timeController,
                      label: 'Time *',
                      hintText: 'Select time',
                      readOnly: true,
                      onTap: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacing16),
              
              // Place and Participation limit row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Place *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        LocationSearchWidget(
                          initialValue: _selectedLocation,
                          hintText: 'Search location',
                          onLocationSelected: _onLocationSelected,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: _buildTextField(
                      controller: _participationLimitController,
                      label: 'Participation limit *',
                      hintText: 'Max people',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacing24),
              
              // Photos section
              _buildPhotosSection(),
              
              const SizedBox(height: AppTheme.spacing24),
              
              // Map preview section
              if (_selectedLocation != null) _buildMapSection(),
              
              const SizedBox(height: AppTheme.spacing32),
              
              // Send invite button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7), // Light blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Send your invite',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
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
              borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (label.contains('*') && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photos button
        Row(
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 20,
              color: Color(0xFF4FC3F7),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _selectPhoto,
              child: const Text(
                'photos',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4FC3F7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacing12),
        
        // Photo display
        if (_selectedImagePath != null)
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                // Image preview
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    image: _selectedImagePath != null
                        ? DecorationImage(
                            image: kIsWeb 
                              ? NetworkImage(_selectedXFile?.path ?? _selectedImagePath!)
                              : FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImagePath == null
                      ? const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 24,
                        )
                      : null,
                ),
                
                const SizedBox(width: AppTheme.spacing12),
                
                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedImageName ?? 'image.png',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _deletePhoto,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                        ),
                        child: const Text(
                          'delete photo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectPhoto() async {
    try {
      print('🖼️ Starting image picker for activity...');
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
          _selectedImagePath = image.path;
          _selectedImageName = image.name;
        });
        
        print('🖼️ _selectedXFile set to: ${_selectedXFile?.path}');
        if (!kIsWeb) {
          print('🖼️ _selectedImage set to: ${_selectedImage?.path}');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected successfully'),
            duration: Duration(seconds: 2),
          ),
        );
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

  void _deletePhoto() {
    setState(() {
      _selectedImagePath = null;
      _selectedImageName = null;
      _selectedImage = null;
      _selectedXFile = null;
    });
  }

  void _onLocationSelected(String address, double? lat, double? lng) {
    setState(() {
      _selectedLocation = address;
      if (lat != null && lng != null) {
        _selectedLatLng = LatLng(lat, lng);
      }
    });
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location Preview',
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
            child: LocationMapWidget(
              initialPosition: _selectedLatLng,
              initialAddress: _selectedLocation,
              height: 200,
              title: 'Activity Location',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Additional validation for required fields not covered by form validation
      if (_selectedLocation == null || _selectedLocation!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a location for the activity'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Handle image upload if image is selected
        String? uploadedImageUrl;
        String? uploadedImageName;
        
        if ((kIsWeb && _selectedXFile != null) || (!kIsWeb && _selectedImage != null)) {
          try {
            print('🖼️ Starting image upload for activity...');
            Map<String, dynamic> uploadResult;
            
            // Use web-compatible upload if on web platform
            if (kIsWeb) {
              uploadResult = await CommunityApiService.uploadMediaWeb(_selectedXFile!);
            } else {
              uploadResult = await CommunityApiService.uploadMedia(_selectedImage!);
            }
            
            print('🖼️ Upload result: $uploadResult');
            
            if (uploadResult['success'] == true) {
              uploadedImageUrl = uploadResult['file_url'];
              uploadedImageName = uploadResult['file_name'];
              print('🖼️ Image uploaded successfully: $uploadedImageUrl');
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
        }

        await ActivityApiService.createActivity(
          title: _titleController.text.trim(),
          description: _messageController.text.trim(),
          date: _dateController.text.trim(),
          time: _timeController.text.trim(),
          place: _selectedLocation ?? _placeController.text.trim(),
          capacity: int.tryParse(_participationLimitController.text.trim()) ?? 1,
          location: _selectedLocation,
          latitude: _selectedLatLng?.latitude,
          longitude: _selectedLatLng?.longitude,
          imageUrl: uploadedImageUrl ?? _selectedImagePath,
          imageName: uploadedImageName ?? _selectedImageName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activity created successfully!'),
              backgroundColor: Color(0xFF4FC3F7),
              duration: Duration(seconds: 2),
            ),
          );
          
          // Navigate back with success result
          AppRouter.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create activity: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}

