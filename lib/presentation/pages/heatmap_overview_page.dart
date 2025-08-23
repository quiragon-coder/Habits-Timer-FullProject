import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../../infrastructure/db/activity_dao_extras.dart';
import '../../application/providers/heatmap_provider.dart';
import '../../application/providers/providers.dart';
import '../widgets/heatmap_calendar.dart';

class HeatmapOverviewPage extends ConsumerStatefulWidget {
  final int? initialActivityId;
  final DateTime? initialDay;
  const HeatmapOverviewPage({super.key, this.initialActivityId, this.initialDay});

  @override
  ConsumerState<HeatmapOverviewPage> createState() => _HeatmapOverviewPageState();
}

class _HeatmapOverviewPageState extends ConsumerState<HeatmapOverviewPage> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialActivityId;
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(activityDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heatmap complète'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<Activity>>(
          stream: dao.watchAll(),
          builder: (context, snap) {
            final list = snap.data ?? const <Activity>[];

            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_selectedId == null && list.isNotEmpty) {
              _selectedId = list.first.id;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Activité: '),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _selectedId,
                      items: [
                        for (final a in list)
                          DropdownMenuItem(
                            value: a.id,
                            child: Text(a.emoji?.isNotEmpty == true ? '${a.emoji} ${a.name}' : a.name),
                          ),
                      ],
                      onChanged: (v) => setState(() => _selectedId = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectedId == null)
                  const Expanded(child: Center(child: Text('Aucune activité.')))
                else
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final heat = ref.watch(last365HeatmapProvider(_selectedId!));
                        return heat.when(
                          data: (d) => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: HeatmapCalendar(data: d, cellSize: 18, cellSpacing: 3),
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Erreur: $e')),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
