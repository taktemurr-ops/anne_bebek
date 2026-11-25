// Her kullanıcı ekranı boş açılmamalı: hatasız çizilmeli, yeterli içerik
// göstermeli ve en az bir etkileşim (kayıt girme, arama, açma) sunmalıdır.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/all_pages.dart';
import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final pages = allUserPages();
  for (final (name, build) in pages) {
    testWidgets('$name boş değil ve etkileşimli', (tester) async {
      SharedPreferences.setMockInitialValues({'privacy_consent_v1': 1});
      installSecureStorageMock();
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: build())));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final error = tester.takeException();
      expect(error, isNull, reason: '$name: ${error is FlutterError ? error.diagnostics.map((d) => d.toString()).join('\n') : error}');
      final texts = find.byType(Text).evaluate().length;
      expect(texts, greaterThanOrEqualTo(3), reason: '$name: ekran neredeyse boş ($texts metin)');
      final interactive = find.byWidgetPredicate((w) =>
          (w is ButtonStyleButton && w.onPressed != null) ||
          (w is IconButton && w.onPressed != null) ||
          (w is FloatingActionButton && w.onPressed != null) ||
          w is TextField || w is EditableText ||
          (w is ListTile && w.onTap != null) ||
          (w is InkWell && w.onTap != null) ||
          w is Checkbox || w is Switch || w is ChoiceChip || w is FilterChip || w is Tab ||
          w is DropdownButton || w is Slider || w is PopupMenuButton ||
          (w is GestureDetector && w.onTap != null));
      // Etkileşimli öğe ekranın altında olabilir; tembel listeyi aşağı kaydırarak ara.
      final scrollables = find.byType(Scrollable);
      for (var i = 0; i < 8 && interactive.evaluate().isEmpty && scrollables.evaluate().isNotEmpty; i++) {
        await tester.drag(scrollables.first, const Offset(0, -500), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(interactive, findsWidgets, reason: '$name: dokunulacak ya da kayıt girilecek bir öğe yok');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
