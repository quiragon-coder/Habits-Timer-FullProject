import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/heatmap_provider.dart';
import '../widgets/heatmap_calendar.dart';

class HeatmapDetailPage extends ConsumerWidget {
  final int activityId;
  final DateTime? initialDay;
  const HeatmapDetailPage({super.key, required this.activityId, this.initialDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heat = ref.watch(last365HeatmapProvider(activityId));
    return Scaffold(
      appBar: AppBar(title: const Text('Heatmap - Détail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: heat.when(
          data: (d) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HeatmapCalendar(data: d, cellSize: 18, cellSpacing: 3),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
        ),
      ),
    );
  }
}
