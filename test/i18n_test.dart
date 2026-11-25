import 'package:anne_bebek/i18n/i18n.dart';
import 'package:anne_bebek/i18n/text.dart' as i18n;
import 'package:anne_bebek/i18n/gen/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => I18n.setForTest('tr', exact: const {}));

  test('tam eşleşme, şablon ve Türkçe geri dönüş', () {
    I18n.setForTest('en', exact: const {'Kaydet': 'Save', 'Bugün {0} bardak su': 'Today {0} glasses of water', 'Kilo': 'Weight'});
    expect(t('Kaydet'), 'Save');
    expect(t('Bilinmeyen metin'), 'Bilinmeyen metin');
    I18n.setForTest('en', exact: const {'Kaydet': 'Save', 'Bugün {0} bardak su': 'Today {0} glasses of water', 'Kilo': 'Weight'});
    expect(t('Kaydet'), 'Save');
    expect(t('Bugün 5 bardak su'), 'Today 5 glasses of water');
  });

  test('karışık sıralı yer tutucular doğru değere eşlenir', () {
    expect(I18n.templateOrder('Uyanık: {1} (son uyanış {0})'), [1, 0]);
    I18n.setForTest('en', exact: const {
      'Uyanık: {1} (son uyanış {0})': 'Awake: {1} (last woke at {0})',
      '{0} kayıt • İlk: {1} {3} • Son: {2} {4}': '{0} records • First: {1} {3} • Last: {2} {4}',
    });
    // Kaynakta {1} önce geldiği için ilk yakalanan değer {1} yerine geçmeli.
    expect(t('Uyanık: 2 sa 10 dk (son uyanış 11:30)'), 'Awake: 2 sa 10 dk (last woke at 11:30)');
    expect(t('3 kayıt • İlk: 5 kg • Son: 7 kg'), isNot(contains('{')));
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
    await tester.pumpWidget(ValueListenableBuilder<String>(valueListenable: I18n.language, builder: (_, lang, _) =>
        MaterialApp(key: ValueKey(lang), locale: Locale(lang),
            localizationsDelegates: GlobalMaterialLocalizations.delegates, supportedLocales: [for (final l in appLanguages) Locale(l.code)],
            home: const Scaffold(body: i18n.Text('Merhaba')))));
    expect(find.text('Hello'), findsOneWidget);
    I18n.setForTest('tr', exact: const {});
    await tester.pumpAndSettle();
    expect(find.text('Merhaba'), findsOneWidget);
  });
}
