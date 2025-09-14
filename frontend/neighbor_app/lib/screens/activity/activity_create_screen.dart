/// Activity create screen for the Neighbor app
/// Form for creating new community activities
library;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/app_theme.dart';
import '../../router/app_router.dart';
import '../../widgets/common/location_search_widget.dart';
import '../../widgets/common/location_map_widget.dart';
import '../../services/activity_api_service.dart';

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
  String? _selectedLocation;
  LatLng? _selectedLatLng;
  bool _isSubmitting = false;

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
                            image: NetworkImage(_selectedImagePath!),
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

  void _selectPhoto() {
    // Simulate photo selection
    setState(() {
      _selectedImagePath = 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=200&fit=crop';
      _selectedImageName = 'chess-board-activity.png';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo selected successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deletePhoto() {
    setState(() {
      _selectedImagePath = null;
      _selectedImageName = null;
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
          imageUrl: _selectedImagePath,
          imageName: _selectedImageName,
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

