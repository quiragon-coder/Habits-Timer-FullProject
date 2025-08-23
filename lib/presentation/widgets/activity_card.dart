import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String? emoji;
  final Widget child;

  const ActivityCard({
    super.key,
    required this.title,
    this.emoji,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji ?? '⏱️', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
