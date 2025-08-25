import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/heatmap_provider.dart';

/// Mini heatmap that always fits the available width (no horizontal scroll).
/// Interactions:
/// - Tap: shows info dialog (date + minutes)
/// - Double tap: open detail page via [onDoubleTap]
/// - Long press: copies a short summary to clipboard + Snackbar
class MiniHeatmap extends ConsumerWidget {
  final List<HeatDay> data;
  final void Function(DateTime day)? onDoubleTap;

  const MiniHeatmap({super.key, required this.data, this.onDoubleTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isEmpty) return const SizedBox.shrink();

    final first = data.first.day.toLocal();
    final last = data.last.day.toLocal();
    final start = first.subtract(Duration(days: (first.weekday % 7))); // start on Monday
    final totalDays = last.difference(start).inDays + 1;
    final weeks = (totalDays / 7).ceil().clamp(1, 53);

    // Colors palette (light -> strong)
    final vals = data.map((d) => d.minutes).toList();
    final maxVal = (vals.isEmpty ? 0 : vals.reduce((a, b) => a > b ? a : b));
    List<Color> palette = const [
      Color(0xFFE5E7EB), // 0
      Color(0xFFDCFCE7),
      Color(0xFFBBF7D0),
      Color(0xFF86EFAC),
      Color(0xFF22C55E),
    ];
    int bucketFor(int m) {
      if (m <= 0) return 0;
      if (maxVal <= 0) return 1;
      final r = m / maxVal;
      if (r < 0.25) return 1;
      if (r < 0.5) return 2;
      if (r < 0.75) return 3;
      return 4;
    }

    final map = {for (final d in data) d.day.toLocal(): d.minutes};

    return LayoutBuilder(
      builder: (context, constraints) {
        // We keep small padding inside card, estimate available width
        const horizontalPadding = 8.0;
        const cellSpacing = 3.0;
        final available = constraints.maxWidth - horizontalPadding * 2;
        // compute cell size to fit exactly the number of columns (weeks)
        final cellSize = ((available - (weeks - 1) * cellSpacing) / weeks).clamp(6.0, 18.0);

        String two(int n) => n.toString().padLeft(2, '0');

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: cellSize * 7 + cellSpacing * 6,
                child: Row(
                  children: [
                    for (int w = 0; w < weeks; w++)
                      Padding(
                        padding: EdgeInsets.only(right: w == weeks - 1 ? 0 : cellSpacing),
                        child: Column(
                          children: [
                            for (int d = 0; d < 7; d++)
                              Padding(
                                padding: EdgeInsets.only(bottom: d == 6 ? 0 : cellSpacing),
                                child: _HeatCell(
                                  size: cellSize,
                                  color: () {
                                    final day = start.add(Duration(days: w * 7 + d));
                                    final m = map[DateTime(day.year, day.month, day.day)] ?? 0;
                                    return palette[bucketFor(m)];
                                  }(),
                                  onTap: () {
                                    final day = start.add(Duration(days: w * 7 + d));
                                    final m = map[DateTime(day.year, day.month, day.day)] ?? 0;
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Détail du jour'),
                                        content: Text(
                                          "${day.year}-${two(day.month)}-${two(day.day)}\n$m min",
                                        ),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                                        ],
                                      ),
                                    );
                                  },
                                  onDoubleTap: () {
                                    final day = start.add(Duration(days: w * 7 + d));
                                    onDoubleTap?.call(day);
                                  },
                                  onLongPress: () async {
                                    final day = start.add(Duration(days: w * 7 + d));
                                    final m = map[DateTime(day.year, day.month, day.day)] ?? 0;
                                    final text = "${day.year}-${two(day.month)}-${two(day.day)} • $m min";
                                    await Clipboard.setData(ClipboardData(text: text));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Copié: $text"), duration: const Duration(seconds: 2)),
                                      );
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Moins', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                  for (final c in palette)
                    Container(width: cellSize, height: cellSize, margin: const EdgeInsets.only(right: cellSpacing), color: c),
                  const SizedBox(width: 8),
                  Text('Plus', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeatCell extends StatelessWidget {
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  const _HeatCell({required this.size, required this.color, this.onTap, this.onDoubleTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
