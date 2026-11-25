import 'package:anne_bebek/data/first_aid.dart';
import 'package:anne_bebek/data/newborn_checklist.dart';
import 'package:anne_bebek/screens/food_intro_page.dart';
import 'package:anne_bebek/screens/milestones_page.dart';
import 'package:anne_bebek/screens/milk_stash_page.dart';
import 'package:anne_bebek/screens/mood_check_page.dart';
import 'package:anne_bebek/screens/teeth_page.dart';
import 'package:anne_bebek/screens/ttc_page.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/baby_milestones.dart';
import 'package:anne_bebek/services/baby_teeth.dart';
import 'package:anne_bebek/services/birth_plan.dart';
import 'package:anne_bebek/services/food_intro.dart';
import 'package:anne_bebek/services/json_store.dart';
import 'package:anne_bebek/services/memories.dart';
import 'package:anne_bebek/services/milk_stash.dart';
import 'package:anne_bebek/services/mood_screening.dart';
import 'package:anne_bebek/services/mother_exercise.dart';
import 'package:anne_bebek/services/potty_training.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:anne_bebek/services/ttc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Depolama', () {
    const newKeys = [
      'baby_milestones_v1', 'baby_teeth_v1', 'baby_food_intro_v1', 'baby_memories_v1', 'mood_screening_v1',
      'ttc_journal_v1', 'mother_exercise_v1', 'milk_stash_v1', 'birth_plan_v1', 'newborn_checklist_v1',
      'potty_training_v1', 'caregiver_card_v1',
    ];
    test('yeni anahtarlar şifreli depoda ve yedekte', () {
      for (final k in newKeys) {
        expect(SecureHealthStore.isAllowed(k), isTrue, reason: k);
        expect(BackupService.isBackupKey(k), isTrue, reason: k);
      }
    });
    test('bozuk JSON boş nesne okunur', () {
      expect(decodeJsonMap('{bozuk'), isEmpty);
      expect(decodeJsonMap('[1,2]'), isEmpty);
      expect(decodeJsonMap('{"a":1}'), {'a': 1});
    });
    test('yaş ay olarak', () {
      expect(ageInMonths(DateTime(2025, 1, 15), DateTime(2025, 7, 14)), 5);
      expect(ageInMonths(DateTime(2025, 1, 15), DateTime(2025, 7, 15)), 6);
      expect(ageInMonths(null, DateTime(2025)), isNull);
    });
  });

  group('Gelişim basamakları', () {
    test('kimlikler benzersiz, her yaşta en az 4 basamak', () {
      expect(milestones.map((m) => m.id).toSet().length, milestones.length);
      for (final a in milestoneAges) {
        expect(milestones.where((m) => m.month == a).length, greaterThanOrEqualTo(4), reason: '$a');
      }
    });
    test('yaş grubu ve gecikenler', () {
      expect(currentMilestoneAge(null), 2);
      expect(currentMilestoneAge(7), 9);
      expect(currentMilestoneAge(100), 60);
      final over = overdueMilestones({'m2_head': '2025-01-01'}, 6);
      expect(over.any((m) => m.id == 'm2_head'), isFalse);
      expect(over.any((m) => m.id == 'm4_coo'), isTrue);
      expect(over.any((m) => m.id == 'm6_roll'), isFalse);
    });
    test('bilinmeyen kimlik ve geçersiz tarih atılır', () {
      expect(decodeMilestoneDone({'m2_head': '2025-01-01', 'yok': '2025-01-01', 'm4_coo': 'x'}), {'m2_head': '2025-01-01'});
    });
  });

  group('Dişler', () {
    test('20 süt dişi', () => expect(allToothIds().length, 20));
    test('beklenen dişler yaşa göre', () {
      expect(expectedSoon({}, 7).map((t) => t.id), contains('lc'));
      expect(expectedSoon({'lc_sağ': '2025-01-01', 'lc_sol': '2025-01-02'}, 7).map((t) => t.id), isNot(contains('lc')));
      expect(toothTypeOf('u2_sol')?.name, 'Üst ikinci azı');
    });
  });

  group('Ek gıda', () {
    test('durum ve alerjen hatırlatma', () {
      final now = DateTime(2025, 6, 30);
      final m = decodeFoodTries({
        'yumurta': [{'date': '2025-06-01', 'reaction': 0}],
        'yer_fistigi': [{'date': '2025-06-25', 'reaction': 0}],
        'balik': [{'date': '2025-06-20', 'reaction': 2}],
        'bilinmeyen': [{'date': '2025-06-20'}],
      });
      expect(m.keys, isNot(contains('bilinmeyen')));
      expect(foodStatus(m['balik']), FoodStatus.reaction);
      expect(foodStatus(m['kabak']), FoodStatus.notTried);
      expect(allergensToKeepGiving(m, now).map((f) => f.id), ['yumurta']);
      expect(decodeFoodTries(encodeFoodTries(m)).length, m.length);
    });
    test('bal ve inek sütü 12 aydan sonra', () {
      expect(introFoods.firstWhere((f) => f.id == 'bal').fromMonth, 12);
      expect(introFoods.firstWhere((f) => f.id == 'inek_sutu').fromMonth, 12);
    });
  });

  group('Anılar', () {
    test('fotoğraf adı yol içeremez', () {
      final m = Memory.fromJson({'id': 'a', 'date': '2025-01-01', 'title': 'İlk diş', 'photo': '../x.jpg'});
      expect(m!.photo, isNull);
    });
    test('yaş etiketi', () {
      expect(ageLabelAt(DateTime(2025, 1, 1), DateTime(2025, 1, 11)), '10. gün');
      expect(ageLabelAt(DateTime(2025, 1, 1), DateTime(2025, 4, 1)), '3. ay');
      expect(ageLabelAt(DateTime(2023, 1, 1), DateTime(2025, 3, 1)), '2 yaş 2 ay');
    });
  });

  group('EPDS', () {
    test('puanlama ve 10. soru', () {
      final none = scoreEpds(List.filled(10, 0), DateTime(2025));
      // Ters puanlanan sorularda 0. seçenek 3 puandır.
      expect(none.score, 7 * 3);
      final best = scoreEpds([0, 0, 3, 0, 3, 3, 3, 3, 3, 3], DateTime(2025));
      expect(best.score, 0);
      expect(best.selfHarm, isFalse);
      expect(best.band, EpdsBand.low);
      final harm = scoreEpds([0, 0, 3, 0, 3, 3, 3, 3, 3, 2], DateTime(2025));
      expect(harm.selfHarm, isTrue);
      expect(scoreEpds([3, 3, 0, 3, 0, 0, 0, 0, 0, 0], DateTime(2025)).score, 30);
    });
    test('eşikler', () {
      expect(EpdsResult(DateTime(2025), 9, false).band, EpdsBand.low);
      expect(EpdsResult(DateTime(2025), 10, false).band, EpdsBand.possible);
      expect(EpdsResult(DateTime(2025), 13, false).band, EpdsBand.likely);
    });
  });

  group('Gebe kalma', () {
    test('doğurgan dönem ve pozitif test', () {
      final starts = [DateTime(2025, 5, 1), DateTime(2025, 5, 29)];
      final w = nextFertileWindow(starts, const [], DateTime(2025, 6, 5))!;
      expect(w.ovulation, DateTime(2025, 6, 12));
      expect(w.start, DateTime(2025, 6, 7));
      final w2 = nextFertileWindow(starts, [TtcDay(DateTime(2025, 6, 9), opk: 1)], DateTime(2025, 6, 5))!;
      expect(w2.ovulation, DateTime(2025, 6, 10));
      expect(cycleDay(starts, DateTime(2025, 6, 5)), 8);
      expect(nextFertileWindow(const [], const [], DateTime(2025)), isNull);
    });
    test('bazal ateş doğrulama', () {
      expect(parseBbt('36,45'), 36.45);
      expect(parseBbt('40'), isNull);
      expect(decodeTtcDays([{'day': '2025-06-01', 'bbt': 99}]).single.bbt, isNull);
    });
  });

  group('Süt stoğu', () {
    test('son kullanma süreleri', () {
      final p = DateTime(2025, 1, 1, 8);
      expect(MilkBag(id: 'a', pumped: p, ml: 100).expires, DateTime(2025, 1, 5, 8));
      expect(MilkBag(id: 'a', pumped: p, ml: 100, place: 'Oda sıcaklığı').expires, DateTime(2025, 1, 1, 12));
      expect(MilkBag(id: 'a', pumped: p, ml: 100, place: 'Dondurucu').expires, DateTime(2025, 7, 1, 8));
      final thawed = MilkBag(id: 'a', pumped: p, ml: 100, place: 'Çözülmüş (buzdolabında)', movedAt: DateTime(2025, 3, 1, 9));
      expect(thawed.expires, DateTime(2025, 3, 2, 9));
    });
    test('önce son kullanması yakın olan', () {
      final now = DateTime(2025, 1, 2);
      final bags = [
        MilkBag(id: 'f', pumped: DateTime(2024, 12, 1), ml: 90, place: 'Dondurucu'),
        MilkBag(id: 'r', pumped: DateTime(2025, 1, 1), ml: 60),
        MilkBag(id: 'u', pumped: DateTime(2025, 1, 1), ml: 60, used: true),
        MilkBag(id: 'x', pumped: DateTime(2024, 12, 20), ml: 60),
      ];
      expect(usableFirst(bags, now).map((b) => b.id), ['r', 'f']);
      expect(totalMl(usableFirst(bags, now)), 150);
      expect(MilkBag.fromJson({'id': 'a', 'pumped': '2025-01-01', 'ml': 0}), isNull);
    });
  });

  group('Diğer', () {
    test('kegel serisi', () {
      final now = DateTime(2025, 3, 10);
      expect(exerciseStreak({'2025-03-10', '2025-03-09', '2025-03-07'}, now), 2);
      expect(exerciseStreak({'2025-03-09', '2025-03-08'}, now), 2);
      expect(exerciseStreak({}, now), 0);
    });
    test('tuvalet eğitimi başarı oranı', () {
      final now = DateTime(2025, 3, 10);
      final days = [PottyDay(DateTime(2025, 3, 10), pee: 3, accidents: 1), PottyDay(DateTime(2025, 2, 1), accidents: 9)];
      expect(weeklySuccessRate(days, now), 75);
      expect(weeklySuccessRate(const [], now), isNull);
    });
    test('doğum planı metni yalnızca seçilenleri içerir', () {
      final plan = BirthPlan.fromJson({'choices': {'baby': ['Hemen ten tene temas', 'uydurma']}, 'texts': {'notes': 'Kan grubu 0+'}});
      final text = plan.render((s) => s);
      expect(text, contains('Hemen ten tene temas'));
      expect(text, isNot(contains('uydurma')));
      expect(text, contains('Kan grubu 0+'));
      expect(text, isNot(contains('Ortam')));
    });
    test('ilk yardım ve yapılacaklar kimlikleri benzersiz', () {
      expect(firstAidCards.map((c) => c.id).toSet().length, firstAidCards.length);
      expect(newbornChecklist.map((c) => c.id).toSet().length, newbornChecklist.length);
      for (final c in newbornChecklist) {
        expect(checklistPhases, contains(c.phase));
      }
    });
  });

  group('Ekran etkileşimi', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      installSecureStorageMock();
    });

    Future<void> pumpPage(WidgetTester tester, Widget page) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: page)));
      await tester.pumpAndSettle();
    }

    testWidgets('EPDS: 10. soruya evet cevabı acil destek gösterir', (tester) async {
      await pumpPage(tester, const MoodCheckPage());
      await tester.tap(find.byKey(const Key('epds_basla')));
      await tester.pumpAndSettle();
      // En iyi cevaplar, son soruda "Bazen".
      const best = [0, 0, 3, 0, 3, 3, 3, 3, 3, 1];
      for (var q = 0; q < 10; q++) {
        await tester.tap(find.byKey(Key('epds_${q}_${best[q]}')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('epds_ileri')));
        await tester.pumpAndSettle();
      }
      expect(find.text('Şimdi destek al'), findsOneWidget);
      expect(find.byKey(const Key('ara_112')), findsWidgets);
      final saved = decodeEpdsHistory((await JsonStore.readMap(MoodCheckPage.storageKey))['history']);
      expect(saved.single.selfHarm, isTrue);
    });

    testWidgets('Gelişim basamağı işaretlenir ve kaydedilir', (tester) async {
      await pumpPage(tester, MilestonesPage(birth: DateTime.now().subtract(const Duration(days: 70))));
      await tester.tap(find.byKey(const Key('basamak_m2_smile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK').evaluate().isNotEmpty ? find.text('OK') : find.text('Tamam'));
      await tester.pumpAndSettle();
      final all = await JsonStore.readMap(MilestonesPage.storageKey);
      expect(decodeMilestoneDone(all['main']).keys, contains('m2_smile'));
    });

    testWidgets('Diş işaretlenir', (tester) async {
      await pumpPage(tester, TeethPage(birth: DateTime.now().subtract(const Duration(days: 250))));
      await tester.tap(find.byKey(const Key('dis_lc_sağ')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK').evaluate().isNotEmpty ? find.text('OK') : find.text('Tamam'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 20 süt dişi çıktı'), findsOneWidget);
    });

    testWidgets('Ek gıda denemesi eklenir', (tester) async {
      await pumpPage(tester, FoodIntroPage(birth: DateTime.now().subtract(const Duration(days: 200))));
      await tester.tap(find.byTooltip('Deneme ekle').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('besin_kaydet')));
      await tester.pumpAndSettle();
      final all = await JsonStore.readMap(FoodIntroPage.storageKey);
      expect(decodeFoodTries(all['main']).keys, contains('kabak'));
    });

    testWidgets('Süt stoğuna ekleme ve doğrulama', (tester) async {
      await pumpPage(tester, const MilkStashPage());
      await tester.tap(find.byKey(const Key('sut_ekle')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('sut_ml')), '0');
      await tester.tap(find.byKey(const Key('sut_kaydet')));
      await tester.pumpAndSettle();
      expect(find.text('1–1000 ml arasında bir miktar gir.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('sut_ml')), '120');
      await tester.tap(find.byKey(const Key('sut_kaydet')));
      await tester.pumpAndSettle();
      expect(find.text('120 ml'), findsOneWidget);
    });

    testWidgets('Gebelik testi pozitif kaydedilince tebrik çıkar', (tester) async {
      await pumpPage(tester, TtcPage(periodStarts: [DateTime.now().subtract(const Duration(days: 30))], onPregnant: () {}));
      await tester.tap(find.byKey(const Key('ttc_bugun')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ttc_test_1')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('ttc_kaydet')));
      await tester.pumpAndSettle();
      expect(find.text('Gebelik takibini aç'), findsOneWidget);
    });
  });
}
