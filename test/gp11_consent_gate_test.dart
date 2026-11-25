import 'package:anne_bebek/widgets/consent_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('onay verilmeden uygulama içeriği açılmaz; onay kalıcıdır', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(
        home: ConsentGate(child: Text('UYGULAMA'))));
    await tester.pumpAndSettle();
    expect(find.text('UYGULAMA'), findsNothing);
    final button = tester.widget<FilledButton>(find.byKey(const ValueKey('consent_accept')));
    expect(button.onPressed, isNull);

    await tester.ensureVisible(find.byKey(const ValueKey('consent_checkbox')));
    await tester.tap(find.byKey(const ValueKey('consent_checkbox')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('consent_accept')));
    await tester.tap(find.byKey(const ValueKey('consent_accept')));
    await tester.pumpAndSettle();
    expect(find.text('UYGULAMA'), findsOneWidget);
    expect(await ConsentGate.isAccepted(), isTrue);
  });

  testWidgets('daha önce onay verildiyse doğrudan açılır', (tester) async {
    SharedPreferences.setMockInitialValues({ConsentGate.storageKey: ConsentGate.currentVersion});
    await tester.pumpWidget(const MaterialApp(
        home: ConsentGate(child: Text('UYGULAMA'))));
    await tester.pumpAndSettle();
    expect(find.text('UYGULAMA'), findsOneWidget);
  });
}
