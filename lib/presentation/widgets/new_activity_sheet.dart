import 'package:drift/drift.dart' show Value;
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/unified_providers.dart';
import '../../infrastructure/db/database.dart';
import '../../application/providers/monthly_goals_provider.dart';
import 'color_picker_dialog.dart';
import 'emoji_picker_sheet.dart';

class NewActivitySheet extends ConsumerStatefulWidget {
  const NewActivitySheet({super.key});

  @override
  ConsumerState<NewActivitySheet> createState() => _NewActivitySheetState();
}

class _NewActivitySheetState extends ConsumerState<NewActivitySheet> {
  final _name = TextEditingController();
  Color _color = const Color(0xFF607D8B);
  String _emoji = '⏱️';

  // goals
  double _hDay = 0;    // hours per day
  double _hWeek = 0;   // hours per week
  double _hMonth = 0;  // hours per month
  final Set<int> _weekdays = {}; // Monday=1 ... Sunday=7

  final _swatches = const [
    Color(0xFFEF5350), Color(0xFFAB47BC), Color(0xFF5C6BC0), Color(0xFF29B6F6),
    Color(0xFF26A69A), Color(0xFF66BB6A), Color(0xFFFFCA28), Color(0xFFFF7043),
    Color(0xFF8D6E63), Color(0xFF607D8B),
  ];

  final _curatedEmoji = const ['🎨','✍️','📚','🏃','🧘','💻','🎹','📖','🧪','🍳','🧺','🎮','🚴','⏱️'];

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Nouvelle activité', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Ex. Dessin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Emoji + Couleur
            Row(
              children: [
                // Emoji bloc
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Emoji'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8, runSpacing: 8, children: [
                          for (final e in _curatedEmoji)
                            ChoiceChip(
                              label: Text(e, style: const TextStyle(fontSize: 20)),
                              selected: _emoji == e,
                              onSelected: (_) => setState(() => _emoji = e),
                            ),
                          ActionChip(
                            label: const Text('＋', style: TextStyle(fontSize: 20)),
                            onPressed: () async {
                              final picked = await showModalBottomSheet<String>(
                                context: context, isScrollControlled: true,
                                builder: (_) => const EmojiPickerSheet(initial: '⏱️', showMore: true),
                              );
                              if (picked != null && picked.isNotEmpty) setState(() => _emoji = picked);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Color bloc
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Couleur'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8, runSpacing: 8, children: [
                          for (final c in _swatches)
                            GestureDetector(
                              onTap: () => setState(() => _color = c),
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                                  boxShadow: [if (_color == c) const BoxShadow(blurRadius: 4)],
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDialog<Color>(
                                context: context,
                                builder: (_) => ColorPickerDialog(initial: _color),
                              );
                              if (picked != null) setState(() => _color = picked);
                            },
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: _color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                              ),
                              child: const Center(child: Text('+', style: TextStyle(color: Colors.white))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 12),
            Text('Objectifs (optionnel)', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 4),
            _goalRow(
              title: 'Heures / jour',
              value: _hDay, max: 24, onChanged: (v) => setState(() => _hDay = v),
            ),
            _goalRow(
              title: 'Heures / semaine',
              value: _hWeek, max: 168, onChanged: (v) => setState(() => _hWeek = v),
            ),
            _goalRow(
              title: 'Heures / mois',
              value: _hMonth, max: 300, onChanged: (v) => setState(() => _hMonth = v),
            ),
            const SizedBox(height: 8),
            Text('Jours / semaine', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                for (var i = 1; i <= 7; i++)
                  ChoiceChip(
                    label: Text(_weekdayLabel(i)),
                    selected: _weekdays.contains(i),
                    onSelected: (_) => setState(() {
                      if (_weekdays.contains(i)) {
                        _weekdays.remove(i);
                      } else {
                        _weekdays.add(i);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Astuce: si vous renseignez “Heures / mois”, on en déduit “Heures / semaine” (~4.3 semaines/mois) si vide.',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.check),
                  label: const Text('Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayLabel(int i) {
    // 1 Mon ... 7 Sun => FR letters
    const letters = ['L','M','M','J','V','S','D'];
    return letters[i - 1];
  }

  Widget _goalRow({required String title, required double value, required double max, int? divisions, required ValueChanged<double> onChanged}) {
    return Row(
      children: [
        SizedBox(width: 140, child: Text(title)),
        Expanded(
          child: Slider(
            value: value, onChanged: onChanged, max: max, divisions: divisions,
            label: value.toStringAsFixed(1),
          ),
        ),
        SizedBox(width: 60, child: Text('${value.toStringAsFixed(1)} h', textAlign: TextAlign.end)),
      ],
    );
  }

  Future<void> _create() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donnez un nom à votre activité.')));
      return;
    }
    final db = ref.read(databaseProvider);
    try {
      final id = await db.into(db.activities).insert(ActivitiesCompanion.insert(
        name: _name.text.trim(),
        emoji: Value(_emoji),
        color: Value(_color.value),
        createdAtUtc: Value(DateTime.now().toUtc()),
      ));

      // derive weekly from month if not set
      var weekly = _hWeek;
      if (weekly <= 0 && _hMonth > 0) weekly = _hMonth / 4.345;

      // minutes conversions
      final minutesPerDay = (_hDay * 60).round();
      final minutesPerWeek = (weekly * 60).round();
      final daysPerWeek = _weekdays.length;
      final minutesPerMonth = (_hMonth * 60).round();

      await _upsertGoalDynamic(
        id: id,
        minutesPerDay: minutesPerDay > 0 ? minutesPerDay : null,
        minutesPerWeek: minutesPerWeek > 0 ? minutesPerWeek : null,
        daysPerWeek: daysPerWeek > 0 ? daysPerWeek : null,
        minutesPerMonth: minutesPerMonth > 0 ? minutesPerMonth : null,
      );

      if (mounted) Navigator.pop<int>(context, id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur création: $e')));
      }
    }
  }

  Future<void> _upsertGoalDynamic({
    required int id,
    int? minutesPerDay,
    int? minutesPerWeek,
    int? daysPerWeek,
    int? minutesPerMonth,
  }) async {
    final db = ref.read(databaseProvider);

    // Check if minutes_per_month column exists
    final cols = await db.customSelect('PRAGMA table_info(goals)').get();
    final hasMonth = cols.any((row) => (row.data['name'] as String).toLowerCase() == 'minutes_per_month');

    // Does a goal already exist?
    final existing = await db.customSelect('SELECT COUNT(*) as c FROM goals WHERE activity_id = ?', variables: [drift.Variable(id)]).getSingle();
    final hasRow = (existing.data['c'] as int) > 0;

    // Build dynamic SQL
    final fields = ['activity_id'];
    final values = <Object?>[id];
    final setters = <String>[];

    if (minutesPerDay != null) { fields.add('minutes_per_day'); values.add(minutesPerDay); setters.add('minutes_per_day = excluded.minutes_per_day'); }
    if (minutesPerWeek != null) { fields.add('minutes_per_week'); values.add(minutesPerWeek); setters.add('minutes_per_week = excluded.minutes_per_week'); }
    if (daysPerWeek != null) { fields.add('days_per_week'); values.add(daysPerWeek); setters.add('days_per_week = excluded.days_per_week'); }
    // monthly goal stored in SharedPreferences, not DB

    if (fields.length == 1) return; // nothing to insert

    if (hasRow) {
      // UPDATE existing row (set only provided fields)
      final sets = <String>[];
      final updVals = <Object?>[];
      if (minutesPerDay != null) { sets.add('minutes_per_day = ?'); updVals.add(minutesPerDay); }
      if (minutesPerWeek != null) { sets.add('minutes_per_week = ?'); updVals.add(minutesPerWeek); }
      if (daysPerWeek != null) { sets.add('days_per_week = ?'); updVals.add(daysPerWeek); }
      // monthly goal stored in SharedPreferences, not DB
      if (sets.isEmpty) return;
      updVals.add(id);
      await db.customStatement('UPDATE goals SET ${sets.join(', ')} WHERE activity_id = ?', updVals);
    } else {
      // INSERT (include only provided fields)
      final qMarks = List.filled(fields.length, '?').join(', ');
      await db.customStatement('INSERT INTO goals (${fields.join(', ')}) VALUES ($qMarks)', values);
    }
  }
}
