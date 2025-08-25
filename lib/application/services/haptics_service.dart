import 'package:flutter/services.dart';

class HapticsService {
  HapticsService({required this.enabled});
  bool enabled;

  Future<void> play() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  Future<void> pause() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  Future<void> stop() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }
}
