import 'package:anne_bebek/widgets/daily_quick_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GP-01 günlük hızlı işlemler doğru çağrıları yapar', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyQuickActions(
          onFeeding: () => calls.add('Beslenme'),
          onSleep: () => calls.add('Uyku'),
          onDiaper: () => calls.add('Bez'),
          onMeasurement: () => calls.add('Ölçüm'),
        ),
      ),
    ));

    for (final label in ['Beslenme', 'Uyku', 'Bez', 'Ölçüm']) {
      expect(find.text(label), findsOneWidget);
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(calls, ['Beslenme', 'Uyku', 'Bez', 'Ölçüm']);
  });
}
