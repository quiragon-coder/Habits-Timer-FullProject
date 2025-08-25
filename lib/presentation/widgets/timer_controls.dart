import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/services/haptics_service.dart';
import '../../application/providers/settings_provider.dart';

class TimerControls extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final haptics = HapticsService(enabled: settings.hapticsEnabled);

    final btnStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: () {
            onPlay();
            haptics.play();
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
        ),
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: isRunning
              ? () {
                  onPause();
                  haptics.pause();
                }
              : null,
          icon: const Icon(Icons.pause),
          label: const Text('Pause'),
        ),
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: () {
            onStop();
            haptics.stop();
          },
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
        ),
      ],
    );
  }
}
