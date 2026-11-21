// Tasarım incelemesi için ana ekranların PNG görüntülerini üretir.
// Normal CI'da çalışmaz; .github/workflows/screens.yml ile
// `flutter test integration_test/screenshots --update-goldens` olarak çalıştırılır.
import 'dart:convert';
import 'dart:io';

import 'package:anne_bebek/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/support/secure_storage_mock.dart';

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) return;
  final files = dir.listSync().whereType<File>().toList();
  Future<void> load(String family, bool Function(String) pick) async {
    final loader = FontLoader(family);
    for (final f in files.where((f) => pick(f.uri.pathSegments.last))) {
      loader.addFont(Future.value(ByteData.view(Uint8List.fromList(f.readAsBytesSync()).buffer)));
    }
    await loader.load();
  }
  await load('Roboto', (n) => n.startsWith('Roboto') && n.endsWith('.ttf'));
  await load('MaterialIcons', (n) => n.startsWith('MaterialIcons'));
  // CI emoji yazı tipini indirir (EMOJI_FONT); yoksa emojiler kutu görünür.
  final emoji = Platform.environment['EMOJI_FONT'];
  if (emoji != null && File(emoji).existsSync()) {
    final loader = FontLoader('Noto Color Emoji');
    loader.addFont(Future.value(ByteData.view(Uint8List.fromList(File(emoji).readAsBytesSync()).buffer)));
    await loader.load();
  }
}

Map<String, Object> _sampleData() {
  final now = DateTime.now();
  final birth = DateTime(now.year, now.month - 8, now.day - 14);
  String at(int h, [int daysAgo = 0]) =>
      DateTime(now.year, now.month, now.day - daysAgo, h).toIso8601String();
  return {
    'privacy_consent_v1': 1,
    'bebekAdi': 'Defne',
    'dogum': birth.toIso8601String(),
    'sonAdet': DateTime(now.year, now.month, now.day - 9).toIso8601String(),
    'olaylar': jsonEncode([
      {'tur': 'Uyku', 'not': '2 saat', 'zaman': at(10)},
      {'tur': 'Beslenme', 'not': '150 ml mama', 'zaman': at(12)},
      {'tur': 'Bez değişimi', 'not': 'Temiz', 'zaman': at(11)},
      {'tur': 'Beslenme', 'not': '120 ml', 'zaman': at(8)},
    ]),
    'olcumler': jsonEncode([
      {'boy': '66', 'kilo': '7.4', 'basCevresi': '42', 'tarih': DateTime(now.year, now.month - 3, 1).toIso8601String()},
      {'boy': '69', 'kilo': '8.0', 'basCevresi': '43', 'tarih': DateTime(now.year, now.month - 2, 1).toIso8601String()},
      {'boy': '72', 'kilo': '8.6', 'basCevresi': '44', 'tarih': DateTime(now.year, now.month - 1, 1).toIso8601String()},
    ]),
    'alisveris': jsonEncode(['Bebek bezi (3 numara)', 'Islak mendil', 'Pişik kremi', 'Biberon']),
    'tamamlanan': jsonEncode(['Islak mendil', 'Biberon']),
    'alisveris_adet': jsonEncode({'Islak mendil': 2}),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);
  setUp(installSecureStorageMock);

  Iterable<ScrollableState> vertical() => find.byType(Scrollable).evaluate()
      .map((e) => (e as StatefulElement).state as ScrollableState)
      .where((s) => s.position.axis == Axis.vertical);

  Future<void> toTop(WidgetTester tester) async {
    for (final st in vertical()) {
      if (st.position.pixels != 0) st.position.jumpTo(0);
    }
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    try {
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
    } catch (e) {
      // Bir ekranın çekilememesi diğerlerini engellemesin.
      // ignore: avoid_print
      print('Ekran çekilemedi: $name: $e');
    }
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await toTop(tester);
    await capture(tester, name);
    final main = vertical().where((s) => s.position.maxScrollExtent > 0).toList();
    if (main.isNotEmpty) {
      final st = main.first;
      st.position.jumpTo((st.position.pixels + 650).clamp(0, st.position.maxScrollExtent).toDouble());
      await tester.pumpAndSettle();
      await capture(tester, '${name}_b');
      await toTop(tester);
    }
  }

  Future<bool> tapText(WidgetTester tester, String text, {bool last = false}) async {
    final f = find.text(text);
    if (f.evaluate().isEmpty) {
      // ignore: avoid_print
      print('Bulunamadı: $text');
      return false;
    }
    final target = last ? f.last : f.first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target, warnIfMissed: false);
    await tester.pumpAndSettle();
    return true;
  }

  testWidgets('ekran görüntüleri', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(_sampleData());

    await tester.pumpWidget(const AnneBebekApp());
    await shot(tester, '01_ana_sayfa');

    Future<void> home() async {
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.popUntil((r) => r.isFirst);
      await tester.pumpAndSettle();
      await tapText(tester, 'Ana Sayfa', last: true);
      await toTop(tester);
    }

    final targets = <(String, String, bool)>[
      ('Bebeğim', '02_bebegim', true),
      ('Günlük Takip', '03_gunluk_takip', false),
      ('Tarifler', '04_tarifler', true),
      ('Kadınlar', '05_kadinlar', false),
      ('Gebelik', '06_gebelik', false),
      ('Alışveriş', '07_alisveris', false),
      ('Profil', '08_profil', true),
    ];
    for (final (label, name, isNav) in targets) {
      await home();
      if (await tapText(tester, label, last: isNav)) await shot(tester, name);
    }
  });
}
