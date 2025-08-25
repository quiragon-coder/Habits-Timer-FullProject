import 'package:flutter/services.dart';

class Haptics {
  static Future<void> tap() => HapticFeedback.selectionClick();
  static Future<void> success() => HapticFeedback.lightImpact();
  static Future<void> warn() => HapticFeedback.mediumImpact();
}
