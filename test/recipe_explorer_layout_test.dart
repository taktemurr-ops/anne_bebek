import 'package:anne_bebek/screens/recipe_explorer_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

void main() {
  testWidgets('Tarif keşfi dar ekranda taşmaz', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final errors = <String>[];
    final old = FlutterError.onError;
    FlutterError.onError = (d) => errors.add(d.toString());
    await tester.pumpWidget(const MaterialApp(home: RecipeExplorerPage()));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    FlutterError.onError = old;
    debugPrint(errors.join('\n----\n'));
    expect(errors, isEmpty, reason: errors.join('\n----\n'));
  });
}
