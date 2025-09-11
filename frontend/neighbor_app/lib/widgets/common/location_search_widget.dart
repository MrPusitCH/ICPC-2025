import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../../theme/app_theme.dart';

class LocationSearchWidget extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final Function(String address, double? lat, double? lng)? onLocationSelected;
  final bool enabled;

  const LocationSearchWidget({
    super.key,
    this.initialValue,
    this.hintText = 'Search for a location...',
    this.onLocationSelected,
    this.enabled = true,
  });

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Placemark> _searchResults = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Simulate search results for demo purposes
      // In production, this would use Google Places API
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Create mock search results
      List<Placemark> mockResults = [
        Placemark(
          street: '123 Main Street',
          locality: 'Bangkok',
          administrativeArea: 'Bangkok',
          country: 'Thailand',
          postalCode: '10110',
        ),
        Placemark(
          street: '456 Sukhumvit Road',
          locality: 'Bangkok',
          administrativeArea: 'Bangkok',
          country: 'Thailand',
          postalCode: '10110',
        ),
        Placemark(
          street: '789 Silom Road',
          locality: 'Bangkok',
          administrativeArea: 'Bangkok',
          country: 'Thailand',
          postalCode: '10500',
        ),
      ];
      
      setState(() {
        _searchResults = mockResults;
        _showResults = true;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _showResults = true;
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectLocation(Placemark placemark) async {
    String address = '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
    
    // Use mock coordinates for demo purposes
    // In production, this would get real coordinates from Google Geocoding API
    double lat = 13.7563; // Bangkok latitude
    double lng = 100.5018; // Bangkok longitude
    
    setState(() {
      _controller.text = address;
      _showResults = false;
    });

    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(address, lat, lng);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryBlue),
            ),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
          ),
          onChanged: _searchLocation,
          onTap: () {
            if (_searchResults.isNotEmpty) {
              setState(() {
                _showResults = true;
              });
            }
          },
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              _searchLocation(value);
            }
          },
        ),
        
        if (_showResults && _searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final placemark = _searchResults[index];
                String address = '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
                
                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  title: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _selectLocation(placemark),
                );
              },
            ),
          ),
        
        if (_showResults && _searchResults.isEmpty && !_isSearching)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'No locations found. Try a different search term.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
