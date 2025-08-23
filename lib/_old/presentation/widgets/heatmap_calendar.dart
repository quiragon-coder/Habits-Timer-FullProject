import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/heatmap_provider.dart';

/// A GitHub-like yearly heatmap (last 365 days).
class HeatmapCalendar extends ConsumerWidget {
  final List<HeatDay> data;
  final double cellSize;
  final double cellSpacing;
  final bool showWeekdayLabels;
  final bool showMonthLabels;

  const HeatmapCalendar({
    super.key,
    required this.data,
    this.cellSize = 14,
    this.cellSpacing = 2,
    this.showWeekdayLabels = true,
    this.showMonthLabels = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Determine start Monday
    final first = data.first.day.toLocal();
    final last = data.last.day.toLocal();
    final start = first.subtract(Duration(days: (first.weekday % 7))); // Monday=1 -> %7 => 1; Sunday=7 -> 0
    final weeks = ((last.difference(start).inDays + 1) / 7).ceil();

    // Compute buckets
    final vals = data.map((d) => d.minutes).toList();
    final maxVal = (vals.isEmpty ? 0 : vals.reduce((a, b) => a > b ? a : b));
    List<Color> palette = [
      const Color(0xFFE5E7EB), // 0
      const Color(0xFFDCFCE7),
      const Color(0xFFBBF7D0),
      const Color(0xFF86EFAC),
      const Color(0xFF22C55E),
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

    // Map dates to minutes for quick lookup
    final map = {for (final d in data) d.day.toLocal(): d.minutes};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMonthLabels)
          Padding(
            padding: EdgeInsets.only(left: showWeekdayLabels ? (cellSize + cellSpacing) * 1.5 : 0),
            child: _MonthLabels(start: start, weeks: weeks, cellSize: cellSize, cellSpacing: cellSpacing),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showWeekdayLabels)
              _WeekdayLabels(cellSize: cellSize, cellSpacing: cellSpacing),
            SizedBox(
              height: cellSize * 7 + cellSpacing * 6,
              child: Row(
                children: [
                  for (int w = 0; w < weeks; w++)
                    Padding(
                      padding: EdgeInsets.only(right: cellSpacing),
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
                                tooltip: () {
                                  final day = start.add(Duration(days: w * 7 + d));
                                  final m = map[DateTime(day.year, day.month, day.day)] ?? 0;
                                  return '${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}  •  ${m} min';
                                }(),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Moins'),
            const SizedBox(width: 8),
            for (int i = 0; i < palette.length; i++)
              Container(width: cellSize, height: cellSize, margin: EdgeInsets.only(right: cellSpacing), color: palette[i]),
            const SizedBox(width: 8),
            const Text('Plus'),
          ],
        )
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  final double size;
  final Color color;
  final String tooltip;
  const _HeatCell({required this.size, required this.color, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
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

class _WeekdayLabels extends StatelessWidget {
  final double cellSize;
  final double cellSpacing;
  const _WeekdayLabels({required this.cellSize, required this.cellSpacing});

  @override
  Widget build(BuildContext context) {
    final labels = ['L', '', 'M', '', 'J', '', 'S'];
    return Padding(
      padding: EdgeInsets.only(right: cellSpacing * 2),
      child: Column(
        children: [
          for (int i = 0; i < 7; i++)
            SizedBox(
              width: cellSize * 1.5,
              height: i == 6 ? cellSize : cellSize + cellSpacing,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(labels[i], style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthLabels extends StatelessWidget {
  final DateTime start;
  final int weeks;
  final double cellSize;
  final double cellSpacing;
  const _MonthLabels({required this.start, required this.weeks, required this.cellSize, required this.cellSpacing});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jui', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    List<Widget> labels = [];
    int? prevMonth;
    for (int w = 0; w < weeks; w++) {
      final day = start.add(Duration(days: w * 7));
      if (prevMonth != day.month) {
        labels.add(SizedBox(width: (cellSize + cellSpacing) * 0.5));
        labels.add(SizedBox(
          width: (cellSize + cellSpacing) * 4,
          child: Text(months[day.month - 1], textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ));
        prevMonth = day.month;
      } else {
        labels.add(SizedBox(width: (cellSize + cellSpacing) * 1));
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: labels),
    );
  }
}
