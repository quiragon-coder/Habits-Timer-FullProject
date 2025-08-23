import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/providers/providers.dart';
import '../../application/services/timer_service.dart'; // ✅ import TimerStatus

class HomePage extends ConsumerWidget {
  final int activityId;
  const HomePage({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(activeTimerProvider(activityId));
    final timer = ref.read(activeTimerProvider(activityId).notifier);
    final isRunning = timerState?.status == TimerStatus.running;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Timer: ${timerState?.elapsed ?? Duration.zero}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () => timer.play(), child: const Text("Play")),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => timer.pause(), child: const Text("Pause")),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => timer.stop(), child: const Text("Stop")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
