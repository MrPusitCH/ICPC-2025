import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/posts_api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/location_map_widget.dart';
import '../../widgets/common/location_search_widget.dart';

class VolunteerCreateScreen extends StatefulWidget {
  const VolunteerCreateScreen({super.key});

  @override
  State<VolunteerCreateScreen> createState() => _VolunteerCreateScreenState();
}

class _VolunteerCreateScreenState extends State<VolunteerCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _rewardController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedImagePath;
  String? _selectedLocation;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      _timeController.text = picked.format(context);
    }
  }

  void _selectPhoto() {
    // Simulate photo selection
    setState(() {
      _selectedImagePath = 'sample_image.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo selected (simulated)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _deletePhoto() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  void _onLocationSelected(LatLng position, String address) {
    setState(() {
      _selectedLocation = address;
      _selectedLatitude = position.latitude;
      _selectedLongitude = position.longitude;
      _locationController.text = address;
    });
  }

  void _onSearchLocationSelected(String address, double? lat, double? lng) {
    if (lat != null && lng != null) {
      _onLocationSelected(LatLng(lat, lng), address);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Parse date and time
        final dateParts = _dateController.text.split('/');
        
        if (dateParts.length == 3) {
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);
          
          // Parse time with AM/PM
          final timeText = _timeController.text;
          final isPM = timeText.toUpperCase().contains('PM');
          final timeWithoutAMPM = timeText.replaceAll(RegExp(r'[AP]M', caseSensitive: false), '').trim();
          final timeParts = timeWithoutAMPM.split(':');
          
          if (timeParts.length == 2) {
            int hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            
            // Convert to 24-hour format
            if (isPM && hour != 12) {
              hour += 12;
            } else if (!isPM && hour == 12) {
              hour = 0;
            }
            
            final dateTime = DateTime(year, month, day, hour, minute);
            final isoDateTime = dateTime.toIso8601String();
            
            // Create the volunteer request
            await PostsApiService.createPost(
              title: _titleController.text,
              description: _descriptionController.text,
              dateTime: isoDateTime,
              reward: _rewardController.text.isNotEmpty ? _rewardController.text : null,
            );
            
            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Volunteer request created successfully!'),
                backgroundColor: Color(0xFF27AE60),
              ),
            );

            Navigator.pop(context, true); // Return true to indicate success
          } else {
            throw Exception('Invalid time format. Please select a valid time.');
          }
        } else {
          throw Exception('Invalid date format. Please select a valid date.');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create volunteer request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Request Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter your request title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Message field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message *',
                  hintText: 'Describe your request in detail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Date and Time row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date *',
                        hintText: 'Select date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                        ),
                      ),
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Time *',
                        hintText: 'Select time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                        ),
                      ),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Reward field
              TextFormField(
                controller: _rewardController,
                decoration: InputDecoration(
                  labelText: 'Reward Point',
                  hintText: 'Enter reward points',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E88E5)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Photo upload section
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectPhoto,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('photos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (_selectedImagePath != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '...574-9F6B-E47AD907077F.png',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          TextButton(
                            onPressed: _deletePhoto,
                            child: const Text(
                              'delete photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              
              // Location search
              LocationSearchWidget(
                initialValue: _selectedLocation,
                hintText: 'Search for a location...',
                onLocationSelected: _onSearchLocationSelected,
              ),
              const SizedBox(height: 20),
              
              // Map display
              LocationMapWidget(
                height: 200,
                title: 'Selected Location',
                isSelectable: true,
                initialPosition: _selectedLatitude != null && _selectedLongitude != null
                    ? LatLng(_selectedLatitude!, _selectedLongitude!)
                    : null,
                initialAddress: _selectedLocation,
                onLocationSelected: _onLocationSelected,
              ),
              const SizedBox(height: 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isLoading ? 'Creating...' : 'Send your post',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

