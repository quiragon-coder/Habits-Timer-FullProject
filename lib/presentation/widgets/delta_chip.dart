import 'package:flutter/material.dart';
import '../../application/services/formatting.dart';

class DeltaChip extends StatelessWidget {
  final String label;
  final double currentHours;
  final double previousHours;

  const DeltaChip({
    super.key,
    required this.label,
    required this.currentHours,
    required this.previousHours,
  });

  @override
  Widget build(BuildContext context) {
    final delta = currentHours - previousHours;
    final isUp = delta >= 0;
    final base = Theme.of(context).colorScheme;
    final bg = isUp ? base.secondaryContainer : base.errorContainer;
    final fg = isUp ? base.onSecondaryContainer : base.onErrorContainer;
    final icon = isUp ? Icons.trending_up : Icons.trending_down;

    final String valueText;
    if (previousHours > 0) {
      final pct = (delta / previousHours * 100).toStringAsFixed(0);
      valueText = '${formatSignedHours(delta)}  (${isUp ? '+' : '−'}$pct%)';
    } else {
      valueText = formatSignedHours(delta);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fg.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Flexible( // prevent overflow on small screens
              child: Text(
                '$label: $valueText',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
