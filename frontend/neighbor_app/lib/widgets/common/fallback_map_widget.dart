import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FallbackMapWidget extends StatelessWidget {
  final double height;
  final String? title;
  final String? address;
  final VoidCallback? onTap;

  const FallbackMapWidget({
    super.key,
    required this.height,
    this.title,
    this.address,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Stack(
          children: [
            // Map placeholder background
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFE8F5E8), // Light green background
              child: CustomPaint(
                painter: MapPlaceholderPainter(),
              ),
            ),
            
            // Title overlay
            if (title != null)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            
            // Address overlay
            if (address != null)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Tap overlay
            if (onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Container(),
                  ),
                ),
              ),
            
            // Center message
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Map Preview',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'OpenStreetMap',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw map placeholder
class MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2196F3) // Blue route color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw route path
    final path = Path();
    path.moveTo(20, size.height - 30);
    path.lineTo(40, size.height - 50);
    path.lineTo(60, size.height - 40);
    path.lineTo(80, size.height - 60);
    path.lineTo(100, size.height - 20);
    
    canvas.drawPath(path, paint);

    // Draw some map features
    final featurePaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    // Draw some small circles for landmarks
    canvas.drawCircle(Offset(30, size.height - 20), 3, featurePaint);
    canvas.drawCircle(Offset(70, size.height - 30), 3, featurePaint);
    canvas.drawCircle(Offset(90, size.height - 40), 3, featurePaint);

    // Draw bus stop icon
    final busStopPaint = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(50, size.height - 25, 8, 12),
      busStopPaint,
    );

    // Draw red pin at destination
    final pinPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width - 20, size.height - 20), 8, pinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
