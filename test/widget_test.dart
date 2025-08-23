import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:habits_timer/main.dart';

void main() {
  testWidgets('App boots to Habits Timer home', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HabitsTimerApp()));
    expect(find.text('Habits Timer'), findsOneWidget);
  });
}
