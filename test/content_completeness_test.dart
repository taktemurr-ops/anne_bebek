import 'dart:io';

import 'package:anne_bebek/data/age_guides.dart';
import 'package:anne_bebek/data/encyclopedia/encyclopedia.dart';
import 'package:anne_bebek/data/first_aid.dart';
import 'package:anne_bebek/data/monthly_baby_guide.dart';
import 'package:anne_bebek/data/women_lifestyle_content.dart';
import 'package:anne_bebek/guide_content.dart';
import 'package:anne_bebek/services/pregnancy_week_guide.dart';
import 'package:flutter_test/flutter_test.dart';

/// İçerikte boş kalan alan olmamasını denetler.
void main() {
  test('ansiklopedi başlıklarının özeti ve içeriği dolu', () {
    expect(encyclopediaTopics.length, greaterThan(100));
    for (final e in encyclopediaTopics) {
      expect(e.title.trim(), isNotEmpty, reason: e.id);
      expect(e.summary.trim(), isNotEmpty, reason: e.id);
      expect([...e.know, ...e.todo].where((s) => s.trim().isNotEmpty), isNotEmpty, reason: e.id);
    }
  });

  test('gebelik 1–40. haftaların her bölümü dolu', () {
    for (var w = 1; w <= 40; w++) {
      final g = pregnancyGuideForWeek(w);
      for (final s in [g.development, g.maternalChanges, g.preparation, g.safety]) {
        expect(s.trim(), isNotEmpty, reason: 'hafta $w');
      }
    }
  });

  test('ay ay bebek rehberi 0–72 ay boyunca tüm kategoriler dolu', () {
    for (var m = 0; m <= 72; m++) {
      final g = babyGuideForMonth(m);
      for (final c in babyGuideCategories) {
        expect((g.sections[c] ?? '').trim(), isNotEmpty, reason: 'ay $m · $c');
      }
    }
  });

  test('ilk yardım, yaşa uygun rehber ve kadın yaşamı içerikleri dolu', () {
    for (final c in firstAidCards) {
      expect(c.steps, isNotEmpty, reason: c.id);
      expect(c.when.trim(), isNotEmpty, reason: c.id);
    }
    for (final g in ageGuides) {
      expect(g.description.trim(), isNotEmpty, reason: g.id);
    }
    for (final a in lifestyleArticles) {
      expect(a.body.trim(), isNotEmpty, reason: a.id);
    }
  });

  test('ana menüdeki rehber kartlarının hepsi gerçek içeriğe açılır', () {
    final src = File('lib/main.dart').readAsStringSync();
    final topics = <String>{
      for (final m in RegExp(r"_rehberKart\('([^']+)'").allMatches(src)) m.group(1)!,
      for (final m in RegExp(r"_rehberKonuAc\('([^']+)'\)").allMatches(src)) m.group(1)!,
      for (final m in RegExp(r"for \(final t in \[([^\]]+)\]\) _rehberKart").allMatches(src))
        for (final q in RegExp(r"'([^']+)'").allMatches(m.group(1)!)) q.group(1)!,
    };
    expect(topics, isNotEmpty);
    for (final t in topics) {
      final hasContent = (guideContent[t]?.isNotEmpty ?? false) || searchEncyclopedia(t).isNotEmpty;
      expect(hasContent, isTrue, reason: t);
    }
  });
}
