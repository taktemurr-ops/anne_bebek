import 'dart:ui' as ui;

import 'package:anne_bebek/data/baby_recipe_catalog.dart';
import 'package:anne_bebek/data/general_recipe_catalog.dart';
import 'package:anne_bebek/widgets/recipe_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void _paintAll(Iterable<(String, String, List<String>)> items) {
  for (final (title, category, ingredients) in items) {
    final look = dishLookFor(title, category, ingredients);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    DishPainter(look).paint(canvas, const Size(160, 120));
    recorder.endRecording().dispose();
  }
}

void main() {
  test('Kap ve renk tarife göre seçilir', () {
    expect(dishLookFor('Mercimek çorbası', 'Çorbalar').vessel, DishVessel.bowl);
    expect(dishLookFor('Mercimek çorbası', 'Çorbalar').food, const Color(0xFFF2994A));
    expect(dishLookFor('Ev yapımı limonata', 'İçecekler').vessel, DishVessel.glass);
    expect(dishLookFor('Çikolatalı kek', 'Kek ve kurabiyeler').vessel, DishVessel.cakeSlice);
    expect(dishLookFor('Ispanaklı börek', 'Hamur işleri').vessel, DishVessel.pastry);
    expect(dishLookFor('Biberli menemen', 'Kahvaltılıklar').vessel, DishVessel.skillet);
    expect(dishLookFor('Çoban salata', 'Salatalar').toppings, contains(DishTopping.leaves));
    expect(dishLookFor('Izgara levrek', 'Balık ve deniz ürünleri').toppings, contains(DishTopping.fish));
    expect(dishLookFor('Domatesli makarna', 'Makarnalar').toppings, contains(DishTopping.pasta));
    expect(dishLookFor('Fırın makarna', 'Makarnalar').vessel, DishVessel.tray);
    // Aynı tarif her zaman aynı çizimi üretir.
    expect(dishLookFor('Kuru fasulye', 'Bakliyat yemekleri').seed,
        dishLookFor('Kuru fasulye', 'Bakliyat yemekleri').seed);
  });

  test('Tüm genel ve bebek tarifleri hatasız çizilir', () {
    _paintAll(generalRecipes.map((r) => (r.title, r.category, r.ingredients)));
    _paintAll(babyRecipes.map((r) => (r.title, r.category, r.ingredients)));
  });

  testWidgets('Tarif görseli ekranda çizilir', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Center(
        child: RecipeArt(title: 'Mercimek çorbası', category: 'Çorbalar', size: 120)))));
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
