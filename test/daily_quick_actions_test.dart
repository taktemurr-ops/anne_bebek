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

  for (final width in [280.0, 320.0, 360.0, 600.0]) {
    testWidgets('GP-01 hızlı işlemler dar ekranda taşmaz: ${width.toInt()} px',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DailyQuickActions(
              onFeeding: () {},
              onSleep: () {},
              onDiaper: () {},
              onMeasurement: () {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      for (final label in ['Beslenme', 'Uyku', 'Bez', 'Ölçüm']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('GP-01 hizli islem dugmeleri erisilebilir etiket tasir',
      (tester) async {
    final semantics = tester.ensureSemantics();
    // flutter_test requires semantic handles to close before test teardown.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyQuickActions(
          onFeeding: () {},
          onSleep: () {},
          onDiaper: () {},
          onMeasurement: () {},
        ),
      ),
    ));

    for (final label in ['Beslenme', 'Uyku', 'Bez', 'Ölçüm']) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byType(OutlinedButton),
      );
      expect(button, findsOneWidget);
      expect(tester.widget<OutlinedButton>(button).onPressed, isNotNull);
    }
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

}
