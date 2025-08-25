import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../application/providers/unified_providers.dart';
import '../../infrastructure/db/database.dart';
import 'pickers/color_picker_adv.dart';
import 'pickers/emoji_picker_adv.dart';

class EditActivitySheet extends ConsumerStatefulWidget {
  final int activityId;
  const EditActivitySheet({super.key, required this.activityId});

  @override
  ConsumerState<EditActivitySheet> createState() => _EditActivitySheetState();
}

class _EditActivitySheetState extends ConsumerState<EditActivitySheet> {
  final _name = TextEditingController();
  String? _emoji;
  String? _colorHex;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<Activity?>(
      future: (db.select(db.activities)..where((a) => a.id.equals(widget.activityId))).getSingleOrNull(),
      builder: (ctx, snap) {
        final a = snap.data;
        if (a != null && _name.text.isEmpty) {
          _name.text = a.name;
          _emoji ??= a.emoji;
          _colorHex ??= a.color;
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Éditer l’activité', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom')),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () async { final e = await showEmojiPickerDialog(context, initialEmoji: _emoji); if (e != null) setState(() => _emoji = e); },
                    icon: Text(_emoji ?? '😀', style: const TextStyle(fontSize: 18)),
                    label: const Text('Emoji'),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () async { final c = await showColorPickerDialog(context, initialHex: _colorHex); if (c != null) setState(() => _colorHex = c); },
                    icon: Container(width: 16, height: 16, decoration: BoxDecoration(color: _colorHex == null ? null : Color(int.parse('FF${_colorHex!.substring(1)}', radix: 16)), shape: BoxShape.circle, border: Border.all(color: Colors.black12))),
                    label: const Text('Couleur'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      if (_name.text.trim().isEmpty) return;
                      await (db.update(db.activities)..where((a) => a.id.equals(widget.activityId))).write(
                        ActivitiesCompanion(
                          name: Value(_name.text.trim()),
                          emoji: Value(_emoji),
                          color: Value(_colorHex),
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
