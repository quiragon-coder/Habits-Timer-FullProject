// Timer service using Drift APIs (insert/update) without custom DAO methods.
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../providers/providers.dart';
import '../../infrastructure/db/database.dart';

enum TimerStatus { idle, running, paused }

class ActiveTimerState {
  final TimerStatus status;
  final Duration elapsed;
  final int? sessionId;
  final DateTime? startUtc;

  const ActiveTimerState({
    required this.status,
    required this.elapsed,
    this.sessionId,
    this.startUtc,
  });

  ActiveTimerState copyWith({
    TimerStatus? status,
    Duration? elapsed,
    int? sessionId,
    DateTime? startUtc,
  }) {
    return ActiveTimerState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      sessionId: sessionId ?? this.sessionId,
      startUtc: startUtc ?? this.startUtc,
    );
  }

  static const initial = ActiveTimerState(status: TimerStatus.idle, elapsed: Duration.zero);
}

class ActiveTimerNotifier extends StateNotifier<ActiveTimerState> {
  final Ref _ref;
  final int activityId;
  Timer? _tick;

  ActiveTimerNotifier(this._ref, this.activityId) : super(ActiveTimerState.initial);

  AppDatabase get _db => _ref.read(databaseProvider);

  int _nowSecs() => (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).floor();

  void _startTicker() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == TimerStatus.running && state.startUtc != null) {
        final elapsed = DateTime.now().toUtc().difference(state.startUtc!);
        state = state.copyWith(elapsed: elapsed);
      }
    });
  }

  void _stopTicker() {
    _tick?.cancel();
    _tick = null;
  }

  Future<void> play() async {
    if (state.status == TimerStatus.running) return;
    final nowUtc = DateTime.now().toUtc();
    final id = await _db.into(_db.sessions).insert(SessionsCompanion.insert(
      activityId: activityId,
      startUtc: _nowSecs(),
    ));
    state = ActiveTimerState(
      status: TimerStatus.running,
      elapsed: Duration.zero,
      sessionId: id,
      startUtc: nowUtc,
    );
    _startTicker();
  }

  Future<int?> _openPauseId(int sessionId) async {
    final q = (_db.select(_db.pauses)
      ..where((p) => p.sessionId.equals(sessionId) & p.endUtc.isNull())
      ..orderBy([(t) => drift.OrderingTerm.desc(t.startUtc)])
      ..limit(1));
    final row = await q.getSingleOrNull();
    return row?.id;
  }

  Future<void> pause() async {
    if (state.status != TimerStatus.running || state.sessionId == null) return;
    await _db.into(_db.pauses).insert(PausesCompanion.insert(
      sessionId: state.sessionId!,
      startUtc: _nowSecs(),
      endUtc: const drift.Value.absent(), // open pause
    ));
    state = state.copyWith(status: TimerStatus.paused);
    _stopTicker();
  }

  Future<void> resume() async {
    if (state.status != TimerStatus.paused || state.sessionId == null) return;
    final pid = await _openPauseId(state.sessionId!);
    if (pid != null) {
      await (_db.update(_db.pauses)..where((p) => p.id.equals(pid))).write(
        PausesCompanion(endUtc: drift.Value(_nowSecs())),
      );
    }
    state = state.copyWith(status: TimerStatus.running);
    _startTicker();
  }

  Future<void> stop() async {
    final sid = state.sessionId;
    if (sid != null) {
      // close any open pause
      final pid = await _openPauseId(sid);
      if (pid != null) {
        await (_db.update(_db.pauses)..where((p) => p.id.equals(pid))).write(
          PausesCompanion(endUtc: drift.Value(_nowSecs())),
        );
      }
      // set endUtc on session
      await (_db.update(_db.sessions)..where((s) => s.id.equals(sid))).write(
        SessionsCompanion(endUtc: drift.Value(_nowSecs())),
      );
    }
    state = ActiveTimerState.initial;
    _stopTicker();
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
