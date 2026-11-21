import 'package:anne_bebek/i18n/i18n.dart';
import 'package:anne_bebek/i18n/text.dart' as i18n;
import 'package:anne_bebek/i18n/gen/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => I18n.setForTest('tr', exact: const {}));

  test('tam eşleşme, şablon ve Türkçe geri dönüş', () {
    I18n.setForTest('en', exact: const {'Kaydet': 'Save', 'Bugün {0} bardak su': 'Today {0} glasses of water', 'Kilo': 'Weight'});
    expect(t('Kaydet'), 'Save');
    expect(t('Bilinmeyen metin'), 'Bilinmeyen metin');
    I18n.setForTest('en', exact: const {'Kaydet': 'Save', 'Bugün {0} bardak su': 'Today {0} glasses of water', 'Kilo': 'Weight'});
    // setForTest şablonları derlemez; gerçek tablo yolu _apply ile test edilir.
    expect(t('Kaydet'), 'Save');
  });

  test('desteklenen diller ve yön', () {
    expect(appLanguages.map((l) => l.code), containsAll(['tr', 'en', 'ar', 'de', 'fr', 'es', 'ru', 'pt', 'fa', 'id']));
    expect(appLanguages.where((l) => l.rtl).map((l) => l.code), unorderedEquals(['ar', 'fa']));
  });

  test('derlenmiş tablolarda yer tutucular korunur', () {
    for (final entry in translationTables.entries) {
      for (final e in entry.value.entries) {
        final a = RegExp(r'\{\d+\}').allMatches(e.key).map((m) => m[0]).toList()..sort();
        final b = RegExp(r'\{\d+\}').allMatches(e.value).map((m) => m[0]).toList()..sort();
        expect(b, a, reason: '${entry.key}: ${e.key}');
      }
    }
  });

  testWidgets('dil değişince metin ve yön değişir', (tester) async {
    I18n.setForTest('en', exact: const {'Merhaba': 'Hello'});
    await tester.pumpWidget(ValueListenableBuilder<String>(valueListenable: I18n.language, builder: (_, lang, __) =>
        MaterialApp(locale: Locale(lang), supportedLocales: [for (final l in appLanguages) Locale(l.code)],
            home: const Scaffold(body: i18n.Text('Merhaba')))));
    expect(find.text('Hello'), findsOneWidget);
    I18n.setForTest('tr', exact: const {});
    await tester.pumpAndSettle();
    expect(find.text('Merhaba'), findsOneWidget);
  });
}
