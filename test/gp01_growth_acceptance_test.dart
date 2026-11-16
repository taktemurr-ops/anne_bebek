import 'package:anne_bebek/screens/child_growth_trends_page.dart';
import 'package:anne_bebek/services/child_journals.dart';
import 'package:anne_bebek/services/child_profiles.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
  });

  testWidgets('GP-01: cocuga ait olcumler gecmis ve grafige aktarilir',
      (tester) async {
    final child = ChildProfile(
      id: 'child-a',
      name: 'Deneme',
      birthDate: DateTime(2025, 8, 26),
    );
    final entries = [
      ChildJournalEntry(
        id: 'w1', childId: 'child-a', category: 'Kilo (kg)',
        note: '', at: DateTime(2026, 9, 1), value: 9.2,
      ),
      ChildJournalEntry(
        id: 'w2', childId: 'child-a', category: 'Kilo (kg)',
        note: '', at: DateTime(2026, 10, 1), value: 9.8,
      ),
      ChildJournalEntry(
        id: 'w3', childId: 'child-b', category: 'Kilo (kg)',
        note: '', at: DateTime(2026, 10, 1), value: 14.0,
      ),
    ];
    await SecureHealthStore.write(
      'child_journal_entries_v59', encodeChildJournal(entries),
    );

    await tester.pumpWidget(MaterialApp(
      home: ChildGrowthTrendsPage(child: child),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Deneme · Büyüme geçmişi'), findsOneWidget);
    expect(find.textContaining('İlk–son ölçüm farkı: +0.60'), findsOneWidget);
    expect(find.textContaining('Son iki farklı ölçüm günü: 30 gün'),
        findsOneWidget);
    // Another child's measurement must never appear in this child view.
    expect(find.text('14.00'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
