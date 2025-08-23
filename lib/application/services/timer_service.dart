import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../infrastructure/db/database.dart';
import '../providers/providers.dart';
import '../providers/stats_provider.dart';
import '../providers/goals_provider.dart';

enum TimerStatus { idle, running, paused, stopped }

class ActiveTimerState {
  final TimerStatus status;
  final Duration elapsed;
  final int? sessionId;
  final DateTime? startedAtUtc;
  final List<Pause> pauses;

  ActiveTimerState({
    required this.status,
    required this.elapsed,
    this.sessionId,
    this.startedAtUtc,
    this.pauses = const [],
  });

  ActiveTimerState copyWith({
    TimerStatus? status,
    Duration? elapsed,
    int? sessionId,
    DateTime? startedAtUtc,
    List<Pause>? pauses,
  }) {
    return ActiveTimerState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      sessionId: sessionId ?? this.sessionId,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      pauses: pauses ?? this.pauses,
    );
  }
}

class ActiveTimerNotifier extends StateNotifier<ActiveTimerState?> {
  final Ref _ref;
  final int activityId;
  final SessionDao sessionDao;
  final PauseDao pauseDao;
  Timer? _ticker;

  ActiveTimerNotifier({
    required Ref ref,
    required this.activityId,
    required this.sessionDao,
    required this.pauseDao,
  })  : _ref = ref,
        super(null);

  void _invalidate() {
    _ref.invalidate(recentHistoryProvider(activityId));
    _ref.invalidate(totalsProvider(activityId));
    _ref.invalidate(last7DaysTotalsProvider(activityId));
    _ref.invalidate(goalProgressProvider(activityId));
  }

  Future<void> play() async {
    if (state?.status == TimerStatus.running) return;
    final now = DateTime.now().toUtc();
    int sessionId;
    if (state == null || state!.status == TimerStatus.idle || state!.status == TimerStatus.stopped) {
      sessionId = await sessionDao.startSession(activityId: activityId, startUtc: now.millisecondsSinceEpoch ~/ 1000);
      state = ActiveTimerState(
        status: TimerStatus.running,
        elapsed: Duration.zero,
        sessionId: sessionId,
        startedAtUtc: now,
        pauses: const [],
      );
    } else if (state!.status == TimerStatus.paused) {
      await pauseDao.endLastOpenPause(sessionId: state!.sessionId!, endUtc: now.millisecondsSinceEpoch ~/ 1000);
      state = state!.copyWith(status: TimerStatus.running);
    }
    _startTicker();
    _invalidate();
  }

  Future<void> pause() async {
    if (state?.status != TimerStatus.running) return;
    final now = DateTime.now().toUtc();
    await pauseDao.startPause(sessionId: state!.sessionId!, startUtc: now.millisecondsSinceEpoch ~/ 1000);
    _stopTicker();
    state = state!.copyWith(status: TimerStatus.paused);
    _invalidate();
  }

  Future<void> stop() async {
    if (state == null || state!.sessionId == null) {
      state = ActiveTimerState(status: TimerStatus.idle, elapsed: Duration.zero);
      _stopTicker();
      _invalidate();
      return;
    }
    final now = DateTime.now().toUtc();
    try {
      await pauseDao.endLastOpenPause(sessionId: state!.sessionId!, endUtc: now.millisecondsSinceEpoch ~/ 1000);
    } catch (_) {}
    await sessionDao.stopSession(sessionId: state!.sessionId!, endUtc: now.millisecondsSinceEpoch ~/ 1000);

    _stopTicker();
    state = ActiveTimerState(
      status: TimerStatus.idle,
      elapsed: Duration.zero,
      sessionId: null,
      startedAtUtc: null,
      pauses: const [],
    );
    _invalidate();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state == null || state!.status != TimerStatus.running || state!.startedAtUtc == null) return;
      final now = DateTime.now().toUtc();
      final elapsed = now.difference(state!.startedAtUtc!);
      state = state!.copyWith(elapsed: elapsed);
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
