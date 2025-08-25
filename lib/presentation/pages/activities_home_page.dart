import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../infrastructure/db/database.dart';
import '../../application/providers/unified_providers.dart';
import 'activity_detail_page.dart';
import 'activity_edit_page.dart';

class ActivitiesHomePage extends HookConsumerWidget {
  const ActivitiesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes timers'),
      ),
      body: activitiesAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Aucune activité pour l'instant"),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final created = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => const ActivityEditPage()),
                      );
                      // Optionnel: rafraîchir si besoin
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
              return ListTile(
                leading: Text(a.emoji ?? '🕒', style: const TextStyle(fontSize: 20)),
                title: Text(a.name),
                subtitle: Text('Créée le ${DateTime.fromMillisecondsSinceEpoch(a.createdAtUtc * 1000, isUtc: true).toLocal()}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ActivityDetailPage(activityId: a.id), // ✅ passe activityId requis
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ActivityEditPage(activityId: a.id),
                      ),
                    );
                  },
                ),
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
