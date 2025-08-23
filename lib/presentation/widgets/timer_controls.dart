import 'package:flutter/material.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;

  const TimerControls({
    super.key,
    required this.isRunning,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: isRunning ? null : onPlay,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Lancer'),
        ),
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: isRunning ? onPause : null,
          icon: const Icon(Icons.pause),
          label: const Text('Pause'),
        ),
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: onStop,
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
        ),
      ],
    );
  }
}
