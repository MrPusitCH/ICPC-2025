import 'package:flutter/material.dart';

class AvatarNameRow extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String timeAgo;

  const AvatarNameRow({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A8A9A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
