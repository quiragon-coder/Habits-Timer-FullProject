import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NudgeSettings {
  final bool enabled;
  final bool dailyEnabled;
  final bool weeklyEnabled;
  final bool monthlyEnabled;
  final int eveningHour;       // 0..23
  final int deficitMinutes;    // >=0

  const NudgeSettings({
    required this.enabled,
    required this.dailyEnabled,
    required this.weeklyEnabled,
    required this.monthlyEnabled,
    required this.eveningHour,
    required this.deficitMinutes,
  });

  NudgeSettings copyWith({
    bool? enabled,
    bool? dailyEnabled,
    bool? weeklyEnabled,
    bool? monthlyEnabled,
    int? eveningHour,
    int? deficitMinutes,
  }) =>
      NudgeSettings(
        enabled: enabled ?? this.enabled,
        dailyEnabled: dailyEnabled ?? this.dailyEnabled,
        weeklyEnabled: weeklyEnabled ?? this.weeklyEnabled,
        monthlyEnabled: monthlyEnabled ?? this.monthlyEnabled,
        eveningHour: eveningHour ?? this.eveningHour,
        deficitMinutes: deficitMinutes ?? this.deficitMinutes,
      );
}

class NudgeSettingsNotifier extends StateNotifier<AsyncValue<NudgeSettings>> {
  static const _kEnabled = 'nudge_enabled';
  static const _kDailyEnabled = 'nudge_daily_enabled';
  static const _kWeeklyEnabled = 'nudge_weekly_enabled';
  static const _kMonthlyEnabled = 'nudge_monthly_enabled';
  static const _kEveningHour = 'nudge_evening_hour';
  static const _kDeficitMinutes = 'nudge_deficit_minutes';

  NudgeSettingsNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_kEnabled) ?? true;
      final daily = prefs.getBool(_kDailyEnabled) ?? true;
      final weekly = prefs.getBool(_kWeeklyEnabled) ?? true;
      final monthly = prefs.getBool(_kMonthlyEnabled) ?? true;
      final hour = prefs.getInt(_kEveningHour) ?? 18;
      final deficit = prefs.getInt(_kDeficitMinutes) ?? 30;
      state = AsyncValue.data(NudgeSettings(
        enabled: enabled,
        dailyEnabled: daily,
        weeklyEnabled: weekly,
        monthlyEnabled: monthly,
        eveningHour: hour.clamp(0, 23),
        deficitMinutes: deficit < 0 ? 0 : deficit,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _persist(NudgeSettings s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kEnabled, s.enabled);
      await prefs.setBool(_kDailyEnabled, s.dailyEnabled);
      await prefs.setBool(_kWeeklyEnabled, s.weeklyEnabled);
      await prefs.setBool(_kMonthlyEnabled, s.monthlyEnabled);
      await prefs.setInt(_kEveningHour, s.eveningHour);
      await prefs.setInt(_kDeficitMinutes, s.deficitMinutes);
    } catch (_) {}
  }

  void setEnabled(bool v) {
    final prev = state.value ?? const NudgeSettings(enabled: true, dailyEnabled: true, weeklyEnabled: true, monthlyEnabled: true, eveningHour: 18, deficitMinutes: 30);
    final next = prev.copyWith(enabled: v);
    state = AsyncValue.data(next);
    _persist(next);
  }

  void setDailyEnabled(bool v) {
    final prev = state.value ?? const NudgeSettings(enabled: true, dailyEnabled: true, weeklyEnabled: true, monthlyEnabled: true, eveningHour: 18, deficitMinutes: 30);
    final next = prev.copyWith(dailyEnabled: v);
    state = AsyncValue.data(next);
    _persist(next);
  }

  void setWeeklyEnabled(bool v) {
    final prev = state.value ?? const NudgeSettings(enabled: true, dailyEnabled: true, weeklyEnabled: true, monthlyEnabled: true, eveningHour: 18, deficitMinutes: 30);
    final next = prev.copyWith(weeklyEnabled: v);
    state = AsyncValue.data(next);
    _persist(next);
  }

  void setMonthlyEnabled(bool v) {
    final prev = state.value ?? const NudgeSettings(enabled: true, dailyEnabled: true, weeklyEnabled: true, monthlyEnabled: true, eveningHour: 18, deficitMinutes: 30);
    final next = prev.copyWith(monthlyEnabled: v);
    state = AsyncValue.data(next);
    _persist(next);
  }

  void setEveningHour(int hour) {
    final prev = state.value ?? const NudgeSettings(enabled: true, dailyEnabled: true, weeklyEnabled: true, monthlyEnabled: true, eveningHour: 18, deficitMinutes: 30);
    final next = prev.copyWith(eveningHour: hour.clamp(0, 23));
    state = AsyncValue.data(next);
    _persist(next);
  }

  void setDeficitMinutes(int minutes) {
    final prev = state.value ?? const NudgeSettings(enabled: true, dailyEnabled: true, weeklyEnabled: true, monthlyEnabled: true, eveningHour: 18, deficitMinutes: 30);
    final next = prev.copyWith(deficitMinutes: minutes < 0 ? 0 : minutes);
    state = AsyncValue.data(next);
    _persist(next);
  }
}

final nudgeSettingsProvider = StateNotifierProvider<NudgeSettingsNotifier, AsyncValue<NudgeSettings>>(
  (ref) => NudgeSettingsNotifier(),
);
