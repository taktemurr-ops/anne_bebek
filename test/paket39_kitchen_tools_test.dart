import 'package:anne_bebek/screens/smart_shopping_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Akıllı alışveriş açılır; mutfak araçları kategorili ve aranabilir',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'alisveris': '["Süt","Ekmek"]',
      'tamamlanan': '["Ekmek"]',
    });
    await tester.pumpWidget(const MaterialApp(home: SmartShoppingPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Mutfak araçları'), findsOneWidget);

    final openAll = find.textContaining('Tümü (');
    await tester.ensureVisible(openAll);
    await tester.pumpAndSettle();
    await tester.tap(openAll);
    await tester.pumpAndSettle();
    expect(find.text('Liste ve geçmiş'), findsOneWidget);
    expect(find.text('Bütçe ve fiyat'), findsOneWidget);
    expect(find.text('Kiler ve stok'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('kitchen_tools_search')), 'şablon');
    await tester.pumpAndSettle();
    expect(find.text('Haftalık yemek şablonları'), findsOneWidget);
    expect(find.text('Bütçe ve fiyat'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
