import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../infrastructure/db/database.dart';
import '../../infrastructure/db/activity_dao_extras.dart';
import '../../application/providers/providers.dart';
import 'activity_detail_page.dart';
import 'activity_edit_page.dart';
import 'heatmap_overview_page.dart';

class ActivitiesHomePage extends ConsumerWidget {
  const ActivitiesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(activityDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits Timer'),
        actions: [
          IconButton(
            tooltip: 'Heatmap',
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HeatmapOverviewPage()));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Activity>>(
        stream: dao.watchAll(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Activity>[];
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Aucune activité pour le moment.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityEditPage()));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Créer ma première activité'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = items[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Text(a.emoji?.isNotEmpty == true ? a.emoji! : '🎯', style: const TextStyle(fontSize: 22)),
                  title: Text(a.name),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityDetailPage(activityId: a.id)));
                  },
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityEditPage()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle'),
      ),
    );
  }
}
