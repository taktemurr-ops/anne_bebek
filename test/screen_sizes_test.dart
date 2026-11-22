// Tüm ekranlar küçük telefon, büyük yazı, yatay telefon ve tabletlerde
// (dikey ve yatay) taşma ya da çizim hatası olmadan açılmalıdır.
import 'package:anne_bebek/main.dart';
import 'package:anne_bebek/widgets/adaptive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/all_pages.dart';
import 'support/secure_storage_mock.dart';

class _Device {
  const _Device(this.name, this.size, this.dpr, {this.textScale = 1.0});
  final String name;
  final Size size; // mantıksal piksel
  final double dpr;
  final double textScale;
}

const _devices = <_Device>[
  _Device('küçük telefon 320x568', Size(320, 568), 2),
  _Device('telefon büyük yazı 360x640 x1.3', Size(360, 640), 3, textScale: 1.3),
  _Device('yatay telefon 800x360', Size(800, 360), 3),
  _Device('7 inç tablet 600x960', Size(600, 960), 2),
  _Device('10 inç tablet dikey 800x1280', Size(800, 1280), 2),
  _Device('10 inç tablet yatay 1280x800', Size(1280, 800), 2),
  _Device('büyük tablet 1024x1366', Size(1024, 1366), 2),
];

String _describe(Object e) {
  if (e is FlutterErrorDetails) {
    final first = e.exceptionAsString().split('\n').first;
    final lib = e.library ?? '';
    final ctx = e.context?.toDescription() ?? '';
    final where = e.informationCollector?.call()
            .map((d) => d.toString())
            .where((l) => l.contains('lib/') || l.contains('file://'))
            .take(2)
            .join(' | ') ??
        '';
    return '$first ($lib $ctx) $where'.trim();
  }
  return e.toString().split('\n').first;
}

Future<void> _setDevice(WidgetTester tester, _Device d) async {
  tester.view.physicalSize = d.size * d.dpr;
  tester.view.devicePixelRatio = d.dpr;
  tester.platformDispatcher.textScaleFactorTestValue = d.textScale;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final pages = allUserPages();

  for (final d in _devices) {
    testWidgets('Tüm ekranlar: ${d.name}', (tester) async {
      SharedPreferences.setMockInitialValues({'privacy_consent_v1': 1});
      installSecureStorageMock();
      await _setDevice(tester, d);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final problems = <String>{};
      final previous = FlutterError.onError;
      String current = '';
      FlutterError.onError = (details) => problems.add('$current: ${_describe(details)}');
      try {
        for (final (name, build) in pages) {
          current = name;
          await tester.pumpWidget(MaterialApp(
            builder: (context, child) => ResponsiveFrame(child: child!),
            home: Scaffold(body: build()),
          ));
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          final e = tester.takeException();
          if (e != null) problems.add('$name: ${_describe(e)}');
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(milliseconds: 300));
        }
      } finally {
        FlutterError.onError = previous;
      }
      final report = problems.toList()..sort();
      for (final p in report) {
        // ignore: avoid_print
        print('[${d.name}] $p');
      }
      expect(report, isEmpty, reason: '${d.name}:\n${report.join('\n')}');
    });

    testWidgets('Ana uygulama sekmeleri: ${d.name}', (tester) async {
      SharedPreferences.setMockInitialValues({'privacy_consent_v1': 1});
      installSecureStorageMock();
      await _setDevice(tester, d);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final problems = <String>{};
      final previous = FlutterError.onError;
      String current = 'Ana Sayfa';
      FlutterError.onError = (details) => problems.add('$current: ${_describe(details)}');
      try {
        await tester.pumpWidget(const AnneBebekApp());
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        for (final tab in ['Bebek', 'Anne', 'Kadınlar', 'Ana Sayfa']) {
          current = tab;
          final f = find.text(tab);
          if (f.evaluate().isEmpty) {
            problems.add('$tab: alt menüde bulunamadı');
            continue;
          }
          await tester.tap(f.last, warnIfMissed: false);
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 100));
          }
          final e = tester.takeException();
          if (e != null) problems.add('$tab: ${_describe(e)}');
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      } finally {
        FlutterError.onError = previous;
      }
      final report = problems.toList()..sort();
      for (final p in report) {
        // ignore: avoid_print
        print('[${d.name}] $p');
      }
      expect(report, isEmpty, reason: '${d.name}:\n${report.join('\n')}');
    });
  }

  test('Sütun sayısı genişliğe göre artar', () {
    expect(adaptiveColumns(320, minTileWidth: 150), 2);
    expect(adaptiveColumns(800, minTileWidth: 150), 5);
    expect(adaptiveColumns(800, minTileWidth: 150, max: 4), 4);
    expect(adaptiveColumns(100, minTileWidth: 150), 1);
  });
}
