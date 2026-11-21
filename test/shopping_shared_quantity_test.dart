import 'dart:convert';
import 'package:anne_bebek/screens/smart_shopping_page.dart';
import 'package:anne_bebek/widgets/reference_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Akıllı Alışveriş ana sekmeyle aynı adet kaydını okur ve yazar', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'alisveris': jsonEncode(['Islak mendil']),
      'tamamlanan': '[]',
      'alisveris_adet': jsonEncode({'Islak mendil': 3}),
    });
    await tester.pumpWidget(const MaterialApp(home: SmartShoppingPage()));
    await tester.pumpAndSettle();

    final stepper = find.byType(QuantityStepper);
    await tester.ensureVisible(stepper);
    await tester.pumpAndSettle();
    expect(tester.widget<QuantityStepper>(stepper).value, 3);

    tester.widget<QuantityStepper>(stepper).onChanged(5);
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('alisveris_adet')!), {'Islak mendil': 5});
  });
}
