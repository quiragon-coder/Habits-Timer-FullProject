import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../infrastructure/db/database.dart';
import '../../application/providers/unified_providers.dart';

class ActivityEditPage extends ConsumerStatefulWidget {
  final int? activityId; // null => création
  const ActivityEditPage({super.key, this.activityId});

  @override
  ConsumerState<ActivityEditPage> createState() => _ActivityEditPageState();
}

class _ActivityEditPageState extends ConsumerState<ActivityEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _emoji;
  late final TextEditingController _color;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _emoji = TextEditingController();
    _color = TextEditingController();

    // Pré-remplir si édition
    Future.microtask(() async {
      final db = ref.read(databaseProvider);
      if (widget.activityId != null) {
        final row = await (db.select(db.activities)..where((a) => a.id.equals(widget.activityId!))).getSingleOrNull();
        if (row != null) {
          _name.text = row.name;
          _emoji.text = row.emoji ?? '';
          _color.text = row.color ?? '';
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    _color.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = ref.read(databaseProvider);
    final nowUtc = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    if (widget.activityId == null) {
      // insert
      await db.into(db.activities).insert(ActivitiesCompanion.insert(
        name: _name.text.trim(),
        emoji: drift.Value(_emoji.text.trim().isEmpty ? null : _emoji.text.trim()),
        color: drift.Value(_color.text.trim().isEmpty ? null : _color.text.trim()),
        createdAtUtc: nowUtc,
      ));
    } else {
      // update
      await (db.update(db.activities)..where((a) => a.id.equals(widget.activityId!))).write(
        ActivitiesCompanion(
          name: drift.Value(_name.text.trim()),
          emoji: drift.Value(_emoji.text.trim().isEmpty ? null : _emoji.text.trim()),
          color: drift.Value(_color.text.trim().isEmpty ? null : _color.text.trim()),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.activityId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier activité' : 'Nouvelle activité'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  hintText: 'Ex: Dessin, Sport, Lecture...',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emoji,
                decoration: const InputDecoration(
                  labelText: 'Emoji (facultatif)',
                  hintText: '🎨',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _color,
                decoration: const InputDecoration(
                  labelText: 'Couleur (hex facultative)',
                  hintText: '#AABBCC',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Objectifs (à ajouter plus tard)',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
