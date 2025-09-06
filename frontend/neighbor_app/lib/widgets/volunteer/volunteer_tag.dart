import 'package:flutter/material.dart';

class VolunteerTag extends StatelessWidget {
  const VolunteerTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF27AE60), // Green color
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'volunteer',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
