import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../application/services/timer_service.dart';

class HomePage extends ConsumerWidget {
  final int activityId;
  const HomePage({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(activeTimerProvider(activityId));
    final timer = ref.read(activeTimerProvider(activityId).notifier);

    final isRunning = timerState.status == TimerStatus.running;

    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: isRunning ? null : () => timer.play(), child: const Text('Play')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: isRunning ? () => timer.pause() : null, child: const Text('Pause')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => timer.stop(), child: const Text('Stop')),
          ],
        ),
      ),
    );
  }
}
