import 'package:anne_bebek/data/baby_recipe_catalog.dart';
import 'package:anne_bebek/screens/baby_recipes_page.dart';
import 'package:anne_bebek/screens/child_profiles_page.dart';
import 'package:anne_bebek/services/child_journals.dart';
import 'package:anne_bebek/services/child_profiles.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
  });

  testWidgets('GP-01: profil olusturma, genel bakis ve gunluk kaydi korunur',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ChildProfilesPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Henüz bebek profili eklenmedi.'), findsOneWidget);
    await tester.tap(find.text('Bebek ekle'));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    await tester.enterText(
      find.descendant(of: dialog, matching: find.byType(TextField)),
      'Deneme Bebek',
    );
    await tester.tap(find.descendant(
      of: dialog, matching: find.text('Kaydet'),
    ));
    await tester.pumpAndSettle();

    final profiles = decodeChildProfiles(
      await SecureHealthStore.read('child_profiles_directory_v58'),
    );
    expect(profiles, hasLength(1));
    expect(profiles.single.name, 'Deneme Bebek');
    expect(find.text('Deneme Bebek'), findsOneWidget);

    await tester.tap(find.text('Deneme Bebek'));
    await tester.pumpAndSettle();
    expect(find.text('Deneme Bebek · Genel bakış'), findsOneWidget);

    await tester.tap(find.text('Çocuğa özel günlük'));
    await tester.pumpAndSettle();
    expect(find.text('Deneme Bebek · Günlük'), findsOneWidget);

    await tester.tap(find.text('Kayıt ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog), matching: find.byType(TextField),
      ).first,
      'GP01 test beslenme',
    );
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog), matching: find.text('Kaydet'),
    ));
    await tester.pumpAndSettle();

    final journals = decodeChildJournal(
      await SecureHealthStore.read('child_journal_entries_v59'),
    );
    expect(journals, hasLength(1));
    expect(journals.single.childId, profiles.single.id);
    expect(journals.single.note, 'GP01 test beslenme');
    expect(find.textContaining('GP01 test beslenme'), findsOneWidget);
  });

  testWidgets('GP-01: tarif favorileri kaydedilir, filtrelenir ve geri okunur',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BabyRecipesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Bebek tarifleri'), findsOneWidget);
    final first = babyRecipes.first;
    await tester.tap(find.byTooltip('Favorilere ekle').first);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('baby_recipe_favorites_v1'), contains(first.id));
    expect(find.text('Favoriler (1)'), findsOneWidget);

    await tester.tap(find.text('Favoriler (1)'));
    await tester.pumpAndSettle();
    expect(find.text('1 sonuç'), findsOneWidget);
    expect(find.text(first.title), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'olmayan-tarif-xyz');
    await tester.pumpAndSettle();
    expect(find.text('0 sonuç'), findsOneWidget);
    expect(find.text('Bu filtrelerde tarif bulunamadı.'), findsOneWidget);

    await tester.tap(find.text('Filtreleri temizle'));
    await tester.pumpAndSettle();
    expect(find.text('${babyRecipes.length} sonuç'), findsOneWidget);
  });
}
