import 'package:flutter/material.dart';
import '../../router/app_router.dart';
import '../../services/news_api_service.dart';

class NewsCreateScreen extends StatefulWidget {
  const NewsCreateScreen({super.key});

  @override
  State<NewsCreateScreen> createState() => _NewsCreateScreenState();
}

class _NewsCreateScreenState extends State<NewsCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _disclaimerController = TextEditingController();
  
  String? _selectedImagePath;
  String? _selectedImageName;
  String _selectedPriority = 'notice'; // Default to notice
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _dateTimeController.dispose();
    _disclaimerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create new anouncement',
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input
              _buildTextField(
                controller: _titleController,
                hintText: 'Title *',
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Message input
              _buildTextField(
                controller: _messageController,
                hintText: 'Message *',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Date and time input (optional)
              _buildDateTimeField(),
              
              const SizedBox(height: 20),
              
              // Disclaimer input (optional)
              _buildTextField(
                controller: _disclaimerController,
                hintText: 'Disclaimer note (optional)',
                maxLines: 2,
              ),
              
              const SizedBox(height: 20),
              
              // Photo upload section
              _buildPhotoSection(),
              
              const SizedBox(height: 30),
              
              // Priority selection
              const Text(
                'Select important level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              
              const SizedBox(height: 12),
              
              _buildPrioritySelection(),
              
              const SizedBox(height: 40),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7), // Light blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
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
                          'Send your post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    required String hintText,
    required int maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDateTimeField() {
    return InkWell(
      onTap: _selectDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _dateTimeController.text.isNotEmpty 
                  ? const Color(0xFF4FC3F7) 
                  : const Color(0xFF9E9E9E),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dateTimeController.text.isNotEmpty 
                    ? _dateTimeController.text
                    : 'Date and time (optional)',
                style: TextStyle(
                  color: _dateTimeController.text.isNotEmpty 
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF9E9E9E),
                  fontSize: 16,
                ),
              ),
            ),
            if (_dateTimeController.text.isNotEmpty)
              IconButton(
                onPressed: _clearDateTime,
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF9E9E9E),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Photos button
            ElevatedButton.icon(
              onPressed: _selectPhoto,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: const Text('photos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5F5F5),
                foregroundColor: const Color(0xFF9E9E9E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Photo preview
            if (_selectedImagePath != null) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.image,
                          color: Color(0xFF9E9E9E),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Filename and delete button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedImageName ?? '...574-9F6B-E47AD907077F.png',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    TextButton(
                      onPressed: _deletePhoto,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'delete photo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPrioritySelection() {
    final priorities = [
      {'key': 'important', 'label': 'important', 'color': Colors.red},
      {'key': 'caution', 'label': 'caution', 'color': Colors.orange},
      {'key': 'notice', 'label': 'notice', 'color': const Color(0xFF4FC3F7)},
    ];

    return Row(
      children: priorities.map((priority) {
        final isSelected = _selectedPriority == priority['key'];
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedPriority = priority['key'] as String;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected 
                    ? priority['color'] as Color
                    : const Color(0xFFF5F5F5),
                foregroundColor: isSelected 
                    ? Colors.white
                    : const Color(0xFF9E9E9E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                priority['label'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _selectPhoto() {
    // Simulate photo selection
    setState(() {
      _selectedImagePath = 'mock_image_path';
      _selectedImageName = '...574-9F6B-E47AD907077F.png';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo selected (simulated)'),
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

  Future<void> _selectDateTime() async {
    // First select date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4FC3F7),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Then select time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4FC3F7),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF1A1A1A),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        // Combine date and time
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format the date and time
        final String formattedDateTime = _formatDateTime(selectedDateTime);
        
        setState(() {
          _dateTimeController.text = formattedDateTime;
        });
      }
    }
  }

  void _clearDateTime() {
    setState(() {
      _dateTimeController.clear();
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$month. $day, $year $hour:$minute';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await NewsApiService.createNews(
          title: _titleController.text.trim(),
          content: _messageController.text.trim(),
          priority: _selectedPriority,
          imageUrl: _selectedImagePath,
          imageName: _selectedImageName,
          dateTime: _dateTimeController.text.trim().isNotEmpty 
              ? _dateTimeController.text.trim() 
              : null,
          disclaimer: _disclaimerController.text.trim().isNotEmpty 
              ? _disclaimerController.text.trim() 
              : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Announcement posted successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Navigate back to news list with success result
          AppRouter.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to post announcement: ${e.toString()}'),
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
