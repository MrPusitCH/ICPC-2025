import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'fallback_map_widget.dart';

class LocationMapWidget extends StatefulWidget {
  final LatLng? initialPosition;
  final String? initialAddress;
  final bool isSelectable;
  final Function(LatLng position, String address)? onLocationSelected;
  final double height;
  final String? title;

  const LocationMapWidget({
    super.key,
    this.initialPosition,
    this.initialAddress,
    this.isSelectable = true,
    this.onLocationSelected,
    this.height = 200,
    this.title,
  });

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.initialAddress;
  }

  @override
  Widget build(BuildContext context) {
    // For now, always show fallback since Google Maps requires API key
    // TODO: Enable Google Maps when API key is provided
    return FallbackMapWidget(
      height: widget.height,
      title: widget.title,
      address: _selectedAddress ?? widget.initialAddress,
      onTap: widget.isSelectable ? () {
        // Simulate location selection
        if (widget.onLocationSelected != null) {
          widget.onLocationSelected!(
            const LatLng(13.7563, 100.5018), // Bangkok coordinates
            'Selected Location',
          );
        }
      } : null,
    );
  }
}
