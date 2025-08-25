import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../infrastructure/db/database.dart';
import '../../application/providers/unified_providers.dart';
import 'pickers/color_picker_adv.dart';
import 'pickers/emoji_picker_adv.dart';

class NewActivitySheet extends ConsumerStatefulWidget {
  const NewActivitySheet({super.key});
  @override
  ConsumerState<NewActivitySheet> createState() => _NewActivitySheetState();
}

class _NewActivitySheetState extends ConsumerState<NewActivitySheet> {
  final _name = TextEditingController();
  String? _emoji = '⏱️';
  String? _colorHex; // ex: "#FFAA00"

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    final chosen = await showColorPickerDialog(context, initialHex: _colorHex);
    if (chosen != null) setState(() => _colorHex = chosen);
  }

  Future<void> _pickEmoji() async {
    final chosen = await showEmojiPickerDialog(context, initialEmoji: _emoji);
    if (chosen != null) setState(() => _emoji = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nouvelle activité', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(onPressed: _pickEmoji, icon: const Text('😀', style: TextStyle(fontSize: 18)), label: Text(_emoji ?? 'Emoji')),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: _pickColor,
                icon: Container(width: 16, height: 16, decoration: BoxDecoration(color: _colorHex == null ? null : Color(int.parse('FF${_colorHex!.substring(1)}', radix: 16)), shape: BoxShape.circle, border: Border.all(color: Colors.black12))),
                label: Text(_colorHex ?? 'Couleur'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () async {
                final name = _name.text.trim();
                if (name.isEmpty) return;
                final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
                final companion = ActivitiesCompanion(
                  name: Value(name),
                  createdAtUtc: Value(nowMs),
                  emoji: Value(_emoji),
                  color: Value(_colorHex),
                );
                await db.into(db.activities).insert(companion);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Créer'),
            ),
          ),
        ],
      ),
    );
  }
}
