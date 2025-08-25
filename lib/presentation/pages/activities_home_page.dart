import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../../application/providers/unified_providers.dart';

class ActivitiesHomePage extends ConsumerWidget {
  const ActivitiesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Activités')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
          await db.into(db.activities).insert(
            ActivitiesCompanion.insert(
              name: 'Nouvelle activité',
              createdAtUtc: nowMs,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: const Center(child: Text('TODO: list activities')),
    );
  }
}
