import 'package:flutter/material.dart';
import 'session_edit_page.dart';

class DayDetailPage extends StatelessWidget {
  final int activityId;
  final DateTime day;
  const DayDetailPage({super.key, required this.activityId, required this.day});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Détails du ${day.toLocal().toString().split(' ')[0]}")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Sessions du jour (mock)"),
            subtitle: const Text("Ici s'afficheront les sessions avec pauses."),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SessionEditPage(),
                  ));
                } else if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Confirmer suppression"),
                      content: const Text("Supprimer la session et ses pauses ?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
                        TextButton(onPressed: () {
                          Navigator.pop(ctx);
                        }, child: const Text("Supprimer"))
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text("✏️ Éditer")),
                const PopupMenuItem(value: 'delete', child: Text("🗑️ Supprimer")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}