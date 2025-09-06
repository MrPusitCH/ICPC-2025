import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NewsTagChip extends StatelessWidget {
  final String tag;

  const NewsTagChip({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    
    switch (tag.toLowerCase()) {
      case 'important':
        backgroundColor = AppTheme.importantRed;
        break;
      case 'caution':
        backgroundColor = AppTheme.cautionOrange;
        break;
      case 'notice':
        backgroundColor = AppTheme.noticeGreen;
        break;
      default:
        backgroundColor = AppTheme.greyText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Text(
        tag.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
