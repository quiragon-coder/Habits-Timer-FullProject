import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../../application/providers/providers.dart';
import '../../application/providers/stats_provider.dart' as stats;
import '../pages/activity_detail_page.dart';
import '../pages/activity_edit_page.dart';
import '../../infrastructure/db/activity_dao_extras.dart';

class ActivityTile extends ConsumerWidget {
  final Activity activity;
  const ActivityTile({super.key, required this.activity});

  String _mmss(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
    }
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(stats.totalsProvider(activity.id));
    final dao = ref.read(activityDaoProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.1),
          child: Text(activity.emoji ?? '⏱️', style: const TextStyle(fontSize: 20)),
        ),
        title: Text(activity.name),
        subtitle: totals.when(
          data: (m) => Text("Aujourd'hui: ${_mmss(m['today']!)}"),
          loading: () => const Text('Calcul...'),
          error: (e, _) => Text('Erreur: $e'),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'open') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ActivityDetailPage(activityId: activity.id)),
              );
            } else if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ActivityEditPage(activityId: activity.id)),
              );
            } else if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Supprimer activité ?'),
                  content: const Text('Toutes les sessions seront aussi supprimées.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await dao.deleteActivityCascade(activity.id);
              }
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'open', child: Text('Ouvrir')),
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActivityDetailPage(activityId: activity.id)),
        ),
      ),
    );
  }
}
