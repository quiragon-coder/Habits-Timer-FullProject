import 'package:flutter_test/flutter_test.dart';
import 'package:habits_timer/app/main.dart';   // <- ton HabitsTimerApp est défini ici
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    // On enveloppe HabitsTimerApp dans un ProviderScope
    await tester.pumpWidget(const ProviderScope(child: HabitsTimerApp()));
    expect(find.byType(HabitsTimerApp), findsOneWidget);
  });
}
