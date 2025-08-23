import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/heatmap_provider.dart';
import 'mini_heatmap.dart';
import '../pages/heatmap_detail_page.dart';

class AnnualHeatmapSection extends ConsumerWidget {
  final int activityId;
  const AnnualHeatmapSection({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heat = ref.watch(last365HeatmapProvider(activityId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Derniers 12 mois', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: heat.when(
              data: (d) => MiniHeatmap(
                data: d,
                onDoubleTap: (day) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HeatmapDetailPage(activityId: activityId, initialDay: day)),
                  );
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erreur heatmap: $e'),
            ),
          ),
        ),
      ],
    );
  }
}
