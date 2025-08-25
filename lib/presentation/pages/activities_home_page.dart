import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/providers/unified_providers.dart';
import '../../infrastructure/db/database.dart';
import '../widgets/activity_tile.dart';
import 'activity_detail_page.dart';
import 'activity_edit_page.dart';

class ActivitiesHomePage extends ConsumerWidget {
  /// Optionnel maintenant (pour que AppScaffold puisse créer la Home sans ID).
  final int? activityId;

  const ActivitiesHomePage({super.key, this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes timers'),
      ),
      body: activitiesAsync.when(
        data: (List<Activity> list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Aucune activité pour l'instant"),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ActivityEditPage()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une activité'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final a = list[i];
              return ActivityTile(
                activity: a,
                onChanged: () {
                  // Optionnel : forcer un refresh si nécessaire
                  // ref.invalidate(activitiesStreamProvider);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ActivityEditPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau timer'),
      ),
    );
  }
}
