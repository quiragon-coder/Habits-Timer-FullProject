import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/providers/providers.dart';
import '../../infrastructure/db/database.dart';
import '../../infrastructure/db/activity_dao_extras.dart';
import 'activity_detail_page.dart';

// import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // optionnel si tu ajoutes la dépendance

class ActivityEditPage extends ConsumerStatefulWidget {
  final int? activityId; // null => création
  const ActivityEditPage({super.key, this.activityId});

  @override
  ConsumerState<ActivityEditPage> createState() => _ActivityEditPageState();
}

class _ActivityEditPageState extends ConsumerState<ActivityEditPage> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emojiCtrl = TextEditingController(text: '🎯');

  Color _color = const Color(0xFF6366F1);

  int _tabIndex = 1; // 0=jour, 1=semaine, 2=mois, 3=année
  double _hoursPerDay = 1;    // 0..12, pas de 0.25h
  double _hoursPerWeek = 5;   // 0..40, pas de 0.5h
  int _daysPerWeek = 3;       // 0..7
  double _hoursPerMonth = 20; // UI only pour l’instant
  double _hoursPerYear = 200; // UI only pour l’instant

  bool _loadingExisting = false;

  @override
  void initState() {
    super.initState();
    _maybeLoadExisting();
  }

  Future<void> _maybeLoadExisting() async {
    if (widget.activityId == null) return;
    setState(() => _loadingExisting = true);
    final dao = ref.read(activityDaoProvider);
    final existing = await dao.findById(widget.activityId!);
    if (!mounted) return;
    if (existing != null) {
      _nameCtrl.text = existing.name;
      _emojiCtrl.text = (existing.emoji?.isNotEmpty == true) ? existing.emoji! : '🎯';
      try {
        if ((existing.color ?? '').startsWith('#')) {
          _color = _fromHex(existing.color!);
        }
      } catch (_) {}
      // Si tu stockes déjà des objectifs, tu peux préremplir ici.
    }
    setState(() => _loadingExisting = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.activityId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier activité' : 'Nouvelle activité')),
      body: _loadingExisting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Nom',
            child: Form(
              key: _form,
              child: TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Ex: Dessin'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ),

          const SizedBox(height: 16),
          _Section(
            title: 'Émoji',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sélection rapide', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                _EmojiPresetGrid(
                  selected: _emojiCtrl.text,
                  onSelect: (e) => setState(() => _emojiCtrl.text = e),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final e = await _askAnyEmoji(context, initial: _emojiCtrl.text);
                        if (e != null) setState(() => _emojiCtrl.text = e);
                      },
                      icon: const Icon(Icons.add_reaction_outlined),
                      label: const Text('Tous les émojis…'),
                    ),
                    const SizedBox(width: 12),
                    Text('Choisi:  ${_emojiCtrl.text}', style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _Section(
            title: 'Couleur',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _palette
                      .map((c) => _ColorDot(
                    color: c,
                    selected: c.value == _color.value,
                    onTap: () => setState(() => _color = c),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Si tu ajoutes flutter_colorpicker, tu peux décommenter le bouton suivant.
                    /*
                          FilledButton.icon(
                            onPressed: () async {
                              final picked = await showDialog<Color?>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Choisir une couleur'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: _color,
                                      onColorChanged: (c) => _color = c,
                                      enableAlpha: false,
                                      labelTypes: const [],
                                      pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                                    FilledButton(onPressed: () => Navigator.pop(context, _color), child: const Text('OK')),
                                  ],
                                ),
                              );
                              if (picked != null) setState(() => _color = picked);
                            },
                            icon: const Icon(Icons.color_lens_outlined),
                            label: const Text('Roue de couleurs'),
                          ),
                          const SizedBox(width: 12),
                          */
                    Text('Actuelle : ', style: Theme.of(context).textTheme.bodyMedium),
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(color: _color, shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
                    ),
                    const SizedBox(width: 8),
                    Text(_toHex(_color), style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _Section(
            title: 'Objectifs',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(label: const Text('Jour'), selected: _tabIndex == 0, onSelected: (_) => setState(() => _tabIndex = 0)),
                    ChoiceChip(label: const Text('Semaine'), selected: _tabIndex == 1, onSelected: (_) => setState(() => _tabIndex = 1)),
                    ChoiceChip(label: const Text('Mois'), selected: _tabIndex == 2, onSelected: (_) => setState(() => _tabIndex = 2)),
                    ChoiceChip(label: const Text('Année'), selected: _tabIndex == 3, onSelected: (_) => setState(() => _tabIndex = 3)),
                  ],
                ),
                const SizedBox(height: 12),
                if (_tabIndex == 0) _GoalDaily(hours: _hoursPerDay, onChanged: (v) => setState(() => _hoursPerDay = v)),
                if (_tabIndex == 1)
                  _GoalWeekly(
                    hoursPerWeek: _hoursPerWeek,
                    daysPerWeek: _daysPerWeek,
                    onHoursChanged: (v) => setState(() => _hoursPerWeek = v),
                    onDaysChanged: (v) => setState(() => _daysPerWeek = v),
                  ),
                if (_tabIndex == 2) _GoalSimple(label: 'Heures par mois', hours: _hoursPerMonth, onChanged: (v) => setState(() => _hoursPerMonth = v), max: 200),
                if (_tabIndex == 3) _GoalSimple(label: 'Heures par année', hours: _hoursPerYear, onChanged: (v) => setState(() => _hoursPerYear = v), max: 3000),
                const SizedBox(height: 8),
                Text(
                  "NB: aujourd'hui la progression utilise les objectifs jour/semaine. "
                      "Mois/année seront pris en compte dès qu’on étendra la table SQLite.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _onSave,
            icon: const Icon(Icons.check),
            label: Text(widget.activityId == null ? 'Créer' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    // ✅ Fix nullability: pas d'expression nullable directement dans la condition
    final form = _form.currentState;
    if (form == null || !form.validate()) {
      setState(() {}); // force l'affichage des erreurs
      return;
    }

    final name = _nameCtrl.text.trim();
    final emoji = _emojiCtrl.text.trim().isEmpty ? null : _emojiCtrl.text.trim();
    final colorHex = _toHex(_color);

    final dao = ref.read(activityDaoProvider);
    final db = ref.read(databaseProvider);

    int id;
    if (widget.activityId == null) {
      id = await dao.insertActivity(
        ActivitiesCompanion.insert(
          name: name,
          emoji: Value(emoji),
          color: Value(colorHex),
          createdAtUtc: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
        ),
      );
    } else {
      id = widget.activityId!;
      await dao.updateActivityData(id: id, name: name, emoji: emoji, color: colorHex);
    }

    // ✅ Persistons les objectifs JOUR/SEMAINE sans dépendre d'un GoalDao.upsert
    final minutesPerWeek = (_hoursPerWeek * 60).round();
    final daysPerWeek = _daysPerWeek;
    final minutesPerDay = (_hoursPerDay * 60).round();

    // Utilise la table goals générée par Drift (insert OR REPLACE).
    // Si ta table s'appelle différemment ou si les colonnes ont d'autres noms, adapte ici.
    await db.into(db.goals).insertOnConflictUpdate(
      GoalsCompanion(
        activityId: Value(id),
        minutesPerWeek: Value(minutesPerWeek),
        daysPerWeek: Value(daysPerWeek),
        minutesPerDay: Value(minutesPerDay),
      ),
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ActivityDetailPage(activityId: id)),
    );
  }

  Future<String?> _askAnyEmoji(BuildContext context, {String? initial}) async {
    final ctrl = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choisir un émoji'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Tape ou colle un émoji (ex: 🎨)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              final txt = ctrl.text.trim();
              Navigator.pop(ctx, txt.isEmpty ? null : txt.characters.first);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static String _toHex(Color c) => '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  static Color _fromHex(String hex) {
    final v = hex.replaceAll('#', '');
    final parsed = int.parse(v.length == 6 ? 'FF$v' : v, radix: 16);
    return Color(parsed);
  }
}

/// ——————————————— UI widgets ———————————————

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmojiPresetGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _EmojiPresetGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final emojis = const [
      '🎨','✍️','📚','🏃‍♂️','🧘','🎹','🎸','💻','🧠','🧹','🍳','🌱','🧩','📝','📖','🐶','🧪','🎮','🚴','🏋️','📷','🎧','🧵','🧱'
    ];
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: [
        for (final e in emojis)
          ChoiceChip(
            label: Text(e, style: const TextStyle(fontSize: 18)),
            selected: selected == e,
            onSelected: (_) => onSelect(e),
          ),
        ActionChip(
          avatar: const Icon(Icons.add),
          label: const Text('Plus'),
          onPressed: () async {
            // Info + ensuite on ouvre la vraie saisie via _askAnyEmoji
            await showDialog<void>(
              context: context,
              builder: (dctx) => AlertDialog(
                title: const Text('Tous les émojis'),
                content: const Text('Tape ou colle un émoji dans la boîte qui s’ouvrira ensuite.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('OK')),
                ],
              ),
            );
            final e = await _ActivityEditPageState()._askAnyEmoji(context);
            if (e != null) onSelect(e);
          },
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? Colors.black : Colors.black12, width: selected ? 2 : 1),
        ),
      ),
    );
  }
}

class _GoalDaily extends StatelessWidget {
  final double hours;
  final ValueChanged<double> onChanged;
  const _GoalDaily({required this.hours, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heures par jour: ${hours.toStringAsFixed(2)} h'),
        Slider(
          min: 0, max: 12, divisions: 48,
          value: hours,
          label: '${hours.toStringAsFixed(2)} h',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _GoalWeekly extends StatelessWidget {
  final double hoursPerWeek;
  final int daysPerWeek;
  final ValueChanged<double> onHoursChanged;
  final ValueChanged<int> onDaysChanged;

  const _GoalWeekly({
    required this.hoursPerWeek,
    required this.daysPerWeek,
    required this.onHoursChanged,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heures par semaine: ${hoursPerWeek.toStringAsFixed(1)} h'),
        Slider(
          min: 0, max: 40, divisions: 80,
          value: hoursPerWeek,
          label: '${hoursPerWeek.toStringAsFixed(1)} h',
          onChanged: onHoursChanged,
        ),
        const SizedBox(height: 8),
        Text('Jours par semaine: $daysPerWeek'),
        Slider(
          min: 0, max: 7, divisions: 7,
          value: daysPerWeek.toDouble(),
          label: '$daysPerWeek',
          onChanged: (v) => onDaysChanged(v.round()),
        ),
      ],
    );
  }
}

class _GoalSimple extends StatelessWidget {
  final String label;
  final double hours;
  final double max;
  final ValueChanged<double> onChanged;
  const _GoalSimple({required this.label, required this.hours, required this.onChanged, required this.max});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${hours.toStringAsFixed(0)} h'),
        Slider(
          min: 0, max: max, divisions: max.toInt(),
          value: hours.clamp(0, max),
          label: '${hours.toStringAsFixed(0)} h',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

const _palette = <Color>[
  Color(0xFFEF4444), Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFF6366F1), Color(0xFF8B5CF6),
  Color(0xFFEC4899), Color(0xFF14B8A6), Color(0xFF22C55E), Color(0xFFEAB308), Color(0xFFFB923C), Color(0xFF60A5FA),
  Color(0xFFA78BFA), Color(0xFFF472B6), Color(0xFF34D399), Color(0xFF4ADE80), Color(0xFF93C5FD), Color(0xFF818CF8),
  Color(0xFF0EA5E9), Color(0xFF06B6D4), Color(0xFF84CC16), Color(0xFF65A30D), Color(0xFF059669), Color(0xFF16A34A),
];
