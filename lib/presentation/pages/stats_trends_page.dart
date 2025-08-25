import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/providers/trends_provider.dart';
import '../../application/providers/periods_provider.dart';
import '../widgets/delta_chip.dart';
import '../widgets/trends_chart.dart';
import '../../application/services/formatting.dart';

enum TrendTab { weeks, months }
const _prefsKeyTrendsTab = 'stats_trends_tab'; // 0 weeks, 1 months

class StatsTrendsPage extends ConsumerStatefulWidget {
  final int activityId;
  final String activityName;
  const StatsTrendsPage({super.key, required this.activityId, required this.activityName});

  @override
  ConsumerState<StatsTrendsPage> createState() => _StatsTrendsPageState();
}

class _StatsTrendsPageState extends ConsumerState<StatsTrendsPage> {
  TrendTab _tab = TrendTab.weeks;

  @override
  void initState() {
    super.initState();
    _restoreTab();
  }

  Future<void> _restoreTab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idx = prefs.getInt(_prefsKeyTrendsTab);
      if (idx != null && idx >= 0 && idx < TrendTab.values.length) {
        setState(() {
          _tab = TrendTab.values[idx];
        });
      }
    } catch (_) {}
  }

  Future<void> _saveTab(TrendTab tab) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKeyTrendsTab, tab.index);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final weeksAsync = ref.watch(last8WeeksTotalsProvider(widget.activityId));
    final monthsAsync = ref.watch(last12MonthsTotalsProvider(widget.activityId));
    final weekNow = ref.watch(currentWeekStatsProvider(widget.activityId));
    final weekPrev = ref.watch(previousWeekStatsProvider(widget.activityId));
    final monthNow = ref.watch(currentMonthStatsProvider(widget.activityId));
    final monthPrev = ref.watch(previousMonthStatsProvider(widget.activityId));

    return Scaffold(
      appBar: AppBar(title: Text('Tendances – ${widget.activityName}')),
      body: CustomScrollView(
        slivers: [
          // Top spacing + Delta chips (now Wrap to avoid overflow)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: weekNow.when(
                data: (cw) => monthPrev.when(
                  data: (pm) => Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      DeltaChip(
                        label: 'Semaine',
                        currentHours: cw.duration.inMinutes / 60.0,
                        previousHours: ref.read(previousWeekStatsProvider(widget.activityId)).maybeWhen(
                          data: (pw) => pw.duration.inMinutes / 60.0,
                          orElse: () => 0,
                        ),
                      ),
                      monthNow.when(
                        data: (cm) => DeltaChip(
                          label: 'Mois',
                          currentHours: cm.duration.inMinutes / 60.0,
                          previousHours: pm.duration.inMinutes / 60.0,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Sticky toggle header with elevation when overlapping
          SliverPersistentHeader(
            pinned: true,
            delegate: _ToggleHeader(
              tab: _tab,
              onChanged: (t) {
                setState(() => _tab = t);
                _saveTab(t);
              },
            ),
          ),

          // Content
          if (_tab == TrendTab.weeks)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: weeksAsync.when(
                  data: (weeks) {
                    final ys = weeks.map((w) => w.minutes / 60.0).toList();
                    final ls = weeks.map((w) => '${w.start.day}/${w.start.month}').toList();
                    final totalH = ys.fold<double>(0, (a, b) => a + b);
                    final avgH = weeks.isEmpty ? 0.0 : totalH / weeks.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('8 dernières semaines (heures)', style: Theme.of(context).textTheme.titleLarge)),
                            Text('Total: ${formatHours(totalH)} • Moy: ${formatHours(avgH)}/sem',
                                style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TrendsChart(y: ys, labels: ls, title: ''),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Erreur semaines: $e'),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: monthsAsync.when(
                  data: (months) {
                    final ys = months.map((m) => m.minutes / 60.0).toList();
                    final ls = months.map((m) => '${m.start.month}/${m.start.year % 100}').toList();
                    final totalH = ys.fold<double>(0, (a, b) => a + b);
                    final avgH = months.isEmpty ? 0.0 : totalH / months.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('12 derniers mois (heures)', style: Theme.of(context).textTheme.titleLarge)),
                            Text('Total: ${formatHours(totalH)} • Moy: ${formatHours(avgH)}/mois',
                                style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TrendsChart(y: ys, labels: ls, title: ''),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Erreur mois: $e'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToggleHeader extends SliverPersistentHeaderDelegate {
  final TrendTab tab;
  final ValueChanged<TrendTab> onChanged;

  _ToggleHeader({required this.tab, required this.onChanged});

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ToggleButtons(
          borderRadius: BorderRadius.circular(12),
          constraints: const BoxConstraints(minWidth: 120, minHeight: 40),
          isSelected: [
            tab == TrendTab.weeks,
            tab == TrendTab.months,
          ],
          onPressed: (index) => onChanged(TrendTab.values[index]),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Semaines')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Mois')),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ToggleHeader oldDelegate) => oldDelegate.tab != tab;
}
