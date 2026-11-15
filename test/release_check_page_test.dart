import 'package:anne_bebek/screens/release_check_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Kontrol listesi işaretleme ve kalıcılık', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: ReleaseCheckPage()));
    await tester.pumpAndSettle();
    expect(find.text('0 / ${releaseChecks.length} kontrol tamamlandı'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('release_check_0')));
    await tester.pumpAndSettle();
    expect(find.text('1 / ${releaseChecks.length} kontrol tamamlandı'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('release_checks_v32'), contains('0'));
  });

  testWidgets('Kaydedilen kontrol yeni açılışta yüklenir', (tester) async {
    SharedPreferences.setMockInitialValues({'release_checks_v32': <String>['2', '999', 'gecersiz']});
    await tester.pumpWidget(const MaterialApp(home: ReleaseCheckPage()));
    await tester.pumpAndSettle();
    expect(find.text('1 / ${releaseChecks.length} kontrol tamamlandı'), findsOneWidget);
    final tile = tester.widget<CheckboxListTile>(find.byKey(const ValueKey('release_check_2')));
    expect(tile.value, isTrue);
  });

  test('Kontrol listesi benzersiz ve boş olmayan maddeler içerir', () {
    expect(releaseChecks.length, greaterThanOrEqualTo(6));
    expect(releaseChecks.every((item) => item.trim().isNotEmpty), isTrue);
    expect(releaseChecks.toSet().length, releaseChecks.length);
    expect(releaseChecks.any((item) => item.contains('forumlarının')), isTrue);
    expect(releaseChecks.any((item) => item.contains('satın alma')), isTrue);
    expect(releaseChecks.any((item) => item.contains('AI servisine')), isTrue);
  });
}
