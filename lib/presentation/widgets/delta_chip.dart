import 'package:flutter/material.dart';

class DeltaChip extends StatelessWidget {
  final double currentHours;
  final double previousHours;
  final String label;

  const DeltaChip({super.key, required this.currentHours, required this.previousHours, required this.label});

  @override
  Widget build(BuildContext context) {
    final delta = currentHours - previousHours;
    final pct = previousHours <= 0 ? null : (delta / previousHours) * 100.0;
    final isUp = delta >= 0;
    final icon = isUp ? Icons.trending_up : Icons.trending_down;
    final color = isUp ? Colors.green : Colors.red;

    final text = pct == null
        ? '${delta.toStringAsFixed(1)} h'
        : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} h  (${pct >= 0 ? '+' : ''}${pct!.toStringAsFixed(0)}%)';

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text('$label: $text'),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}
