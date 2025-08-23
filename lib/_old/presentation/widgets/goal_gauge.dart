import 'package:flutter/material.dart';

class GoalGauge extends StatelessWidget {
  final double progress; // 0..1
  final String label;
  const GoalGauge({super.key, required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0, 1) * 100).round();
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 10,
              ),
              Text('$pct%'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
