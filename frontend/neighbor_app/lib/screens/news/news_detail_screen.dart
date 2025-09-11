import 'package:flutter/material.dart';
import '../../router/app_router.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'News Detail',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and Important label
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Expanded(
                  child: Text(
                    'Inspect the electrical equipment',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Important label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Important',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Main content
            const Text(
              'An electrical equipment inspection will be carried out on Sep. 19, 2025. As a result, electricity will be unavailable on the following dates and times. Please be aware of this information.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Date and time section
            const Text(
              'date and time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Sep. 19, 2025, 13:00 - 20:00',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Disclaimer note
            const Text(
              'could be earlier or later depending on the situation.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
