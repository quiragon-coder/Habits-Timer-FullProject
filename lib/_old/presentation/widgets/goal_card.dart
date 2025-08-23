import 'dart:math';
import 'package:flutter/material.dart';
import '../../application/providers/goals_provider.dart';
import 'goal_gauge.dart';

/// Card Objectifs avec mini confetti (sans package). Affiche 2 jauges.
class GoalCard extends StatefulWidget {
  final GoalProgress progress;
  const GoalCard({super.key, required this.progress});

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _celebrate = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _maybeCelebrate();
  }

  @override
  void didUpdateWidget(covariant GoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeCelebrate();
  }

  void _maybeCelebrate() {
    final weekTarget = widget.progress.minutesPerWeek;
    final hit = weekTarget > 0 && widget.progress.doneWeek.inMinutes >= weekTarget;
    if (hit && !_celebrate) {
      setState(() => _celebrate = true);
      _ctrl.forward(from: 0);
      Future.delayed(const Duration(seconds: 1, milliseconds: 200), () {
        if (mounted) setState(() => _celebrate = false);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;
    final weekTargetMin = p.minutesPerWeek;
    final week = p.doneWeek.inMinutes;
    final pr = weekTargetMin == 0 ? 0.0 : week / weekTargetMin;

    return Stack(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag, size: 20),
                    const SizedBox(width: 6),
                    Text('Objectifs', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    if (weekTargetMin > 0)
                      Chip(
                        label: Text('${(pr.clamp(0,1)*100).round()}%'),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.1),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    GoalGauge(progress: pr.isNaN ? 0 : pr, label: 'Semaine: ${week.round()} / $weekTargetMin min'),
                    GoalGauge(progress: p.daysPerWeek == 0 ? 0 : p.daysDone / p.daysPerWeek, label: 'Jours: ${p.daysDone}/${p.daysPerWeek}'),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_celebrate)
          Positioned.fill(child: CustomPaint(painter: _ConfettiPainter(_ctrl.value)))
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  _ConfettiPainter(this.t);

  final rnd = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 80; i++) {
      paint.color = Colors.primaries[i % Colors.primaries.length].withOpacity((1 - t).clamp(0, 1));
      final dx = size.width * (i / 80) + (i.isEven ? 1 : -1) * 30 * t;
      final dy = size.height * .1 + t * (size.height * .8) * (i % 7) / 7;
      canvas.drawCircle(Offset(dx, dy), 2 + (i % 3) * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
