import 'package:flutter/material.dart';

enum StatsPeriod { day, week, month, year }

class PeriodSelector extends StatelessWidget {
  final StatsPeriod value;
  final ValueChanged<StatsPeriod> onChanged;
  const PeriodSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Jour'),
          selected: value == StatsPeriod.day,
          onSelected: (_) => onChanged(StatsPeriod.day),
        ),
        ChoiceChip(
          label: const Text('Semaine'),
          selected: value == StatsPeriod.week,
          onSelected: (_) => onChanged(StatsPeriod.week),
        ),
        ChoiceChip(
          label: const Text('Mois'),
          selected: value == StatsPeriod.month,
          onSelected: (_) => onChanged(StatsPeriod.month),
        ),
        ChoiceChip(
          label: const Text('Année'),
          selected: value == StatsPeriod.year,
          onSelected: (_) => onChanged(StatsPeriod.year),
        ),
      ],
    );
  }
}
