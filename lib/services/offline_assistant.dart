import '../data/baby_recipe_catalog.dart';
import '../data/general_recipe_catalog.dart';
import '../guide_content.dart';
import 'baby_activity_catalog.dart';
import 'pregnancy_week_guide.dart';
import 'turkey_vaccine_schedule.dart';

/// Yanıtın bir bölümü: başlık, maddeler ve kaynağı.
class AssistantSection {
  final String title;
  final List<String> lines;
  final String source;
  const AssistantSection(this.title, this.lines, this.source);
}

/// Cihaz içi yanıt. Hiçbir veri cihazdan çıkmaz.
class AssistantAnswer {
  /// Acil belirti algılandıysa ilk gösterilecek uyarı.
  final String? urgent;
  final List<AssistantSection> sections;
  const AssistantAnswer({this.urgent, required this.sections});
  bool get isEmpty => urgent == null && sections.isEmpty;
}

/// Sunucusuz bilgi asistanı: uygulamadaki doğrulanmış içerikten
/// (rehber, gebelik haftaları, aşı takvimi, etkinlikler, tarifler)
/// anahtar kelime eşleştirmesiyle yanıt derler. Yeni tıbbi bilgi üretmez.
class OfflineAssistant {
  const OfflineAssistant._();

  static const _urgentTerms = <String>[
    'nefes alam', 'nefes darl', 'morar', 'bayıl', 'bilinç', 'havale', 'nöbet',
    'kasıl', 'yüksek ateş', '40 derece', 'kanl', 'kanama', 'zehirlen',
    'yuttu', 'düştü', 'kafasını çarp', 'su geldi', 'suyum geldi',
    'hareket azal', 'hareket etmiyor', 'şiddetli ağrı', 'kusma dur',
  ];

  static const _stopWords = <String>{
    've', 'ile', 'bir', 'bu', 'şu', 'mi', 'mı', 'mu', 'mü', 'ne', 'nasıl',
    'neden', 'için', 'de', 'da', 'ki', 'çok', 'daha', 'en', 'gibi', 'var',
    'yok', 'olur', 'olan', 'ben', 'benim', 'bebeğim', 'bebek', 'bebeğe',
    'yapmalıyım', 'nedir', 'nelerdir', 'hangi', 'kaç', 'zaman', 'ne zaman',
    'öneri', 'önerisi', 'öneriler', 'önerileri', 'verebilir', 'yapabilirim', 'olmalı',
  };

  /// Gündelik ifadeleri rehber başlıklarına bağlar (kök → başlıklar).
  static const _topicHints = <String, List<String>>{
    'uyku': ['Uyku Düzeni'], 'uyu': ['Uyku Düzeni'], 'uyan': ['Uyku Düzeni'],
    'ninni': ['Uyku Düzeni'], 'gece': ['Uyku Düzeni'],
    'regl': ['Adet Dönemi'], 'adet': ['Adet Dönemi'], 'döngü': ['Adet Dönemi'],
    'emzir': ['Anne Sütü'], 'süt': ['Anne Sütü'], 'meme': ['Anne Sütü'],
    'ateş': ['Hastalıklar ve Belirtiler', 'Sağlık'], 'öksür': ['Hastalıklar ve Belirtiler'],
    'ishal': ['Hastalıklar ve Belirtiler'], 'kus': ['Hastalıklar ve Belirtiler'],
    'hasta': ['Hastalıklar ve Belirtiler', 'Sağlık'], 'kabız': ['Hastalıklar ve Belirtiler', 'Beslenme'],
    'gaz': ['Bebek Bakımı', 'Bebek Masajı'], 'kolik': ['Bebek Bakımı', 'Bebek Masajı'],
    'pişik': ['Bebek Bakımı'], 'bez': ['Bebek Bakımı'], 'banyo': ['Bebek Bakımı'],
    'aşı': ['Aşı Takvimi'], 'alerji': ['Alerji'], 'masaj': ['Bebek Masajı'],
    'gebe': ['Gebelik'], 'hamile': ['Gebelik'], 'doğum': ['Doğum'],
    'lohusa': ['Doğum Sonrası'], 'doğum sonra': ['Doğum Sonrası'],
    'stres': ['Ruh Sağlığı', 'Rahatlama'], 'üzgün': ['Ruh Sağlığı'], 'depres': ['Ruh Sağlığı'],
    'mutsuz': ['Ruh Sağlığı'], 'yorgun': ['Ruh Sağlığı', 'Rahatlama'], 'kayg': ['Ruh Sağlığı'],
    'ek gıda': ['Beslenme', 'Beslenme Önerileri'], 'yemek': ['Beslenme Önerileri'],
    'oyun': ['Eğitim & Oyun'], 'oyna': ['Eğitim & Oyun'], 'gelişim': ['Bebek Gelişimi'],
    'konuş': ['Bebek Gelişimi'], 'yürü': ['Bebek Gelişimi'], 'diş': ['Bebek Gelişimi', 'Sağlık'],
  };

  /// Türkçe küçük harf (İ→i, I→ı) ve fazlalık boşluk temizliği.
  static String normalize(String text) => text
      .replaceAll('İ', 'i').replaceAll('I', 'ı')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zçğıöşü0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static List<String> _tokens(String normalized) => normalized
      .split(' ')
      .where((t) => t.length >= 3 && !_stopWords.contains(t))
      .toList();

  /// Kök eşleştirme: Türkçe ekleri kabaca yok saymak için ilk 5 harf.
  static bool _matches(String haystack, String token) =>
      haystack.contains(token.length > 5 ? token.substring(0, 5) : token);

  /// "8 aylık", "8 ay", "2 yaşında" → ay. Bulunamazsa [childMonths].
  static int? monthsFrom(String normalized, {int? childMonths}) {
    final m = RegExp(r'(\d{1,2})\s*(aylık|ay)\b').firstMatch(normalized);
    if (m != null) return int.parse(m.group(1)!);
    final y = RegExp(r'(\d)\s*(yaş|yaşında|yaşındaki)').firstMatch(normalized);
    if (y != null) return int.parse(y.group(1)!) * 12;
    return childMonths;
  }

  static int? pregnancyWeekFrom(String normalized) {
    final m = RegExp(r'(\d{1,2})\s*\.?\s*(hafta|haftalık)').firstMatch(normalized);
    if (m == null) return null;
    final w = int.parse(m.group(1)!);
    return w >= 1 && w <= 40 ? w : null;
  }

  static AssistantAnswer answer(String question, {int? childMonths, DateTime? childBirth}) {
    final q = normalize(question);
    if (q.isEmpty) return const AssistantAnswer(sections: []);
    final tokens = _tokens(q);
    final sections = <AssistantSection>[];

    String? urgent;
    if (_urgentTerms.any(q.contains)) {
      urgent = 'Yazdıkların acil değerlendirme gerektirebilecek bir duruma benziyor. '
          'Beklemeden 112\'yi ara veya en yakın acil servise başvur. '
          'Bu uygulama tanı koymaz ve acil durumda yol gösterici değildir.';
    }

    final pregnancy = q.contains('gebelik') || q.contains('hamile') || q.contains('gebe');
    final week = pregnancyWeekFrom(q);
    final hasMonthPhrase = RegExp(r'\d{1,2}\s*(aylık|ay)\b').hasMatch(q);
    if (week != null && (pregnancy || !hasMonthPhrase)) {
      final g = pregnancyGuideForWeek(week);
      sections.add(AssistantSection('Gebeliğin $week. haftası', [
        'Bebeğin gelişimi: ${g.development}',
        'Sende: ${g.maternalChanges}',
        'Hazırlık: ${g.preparation}',
        'Dikkat: ${g.safety}',
      ], 'Uygulama içi gebelik haftası rehberi'));
    }

    final months = monthsFrom(q, childMonths: childMonths);
    final asksVaccine = q.contains('aşı');
    if (asksVaccine) {
      final birth = childBirth;
      final relevant = standardVaccines.where((v) =>
          months == null || (v.month >= months - 1 && v.month <= months + 6)).toList()
        ..sort((a, b) => a.month.compareTo(b.month));
      sections.add(AssistantSection(
        months == null ? 'Ulusal aşı takvimi' : '$months. ay civarındaki aşılar',
        [
          for (final v in relevant.take(8))
            '${v.title}: ${v.month == 0 ? 'doğumda' : '${v.month}. ay'}'
            '${birth == null ? '' : ' (${_date(v.dueDate(birth))})'}',
          'Kesin tarih ve geciken dozlar için aile hekimine danış.',
        ],
        'Sağlık Bakanlığı rutin aşı takvimi (uygulama içi özet)'));
    }

    final asksFood = q.contains('tarif') || q.contains('yemek') || q.contains('ek gıda') ||
        q.contains('beslen') || q.contains('kahvaltı') || q.contains('püre') || q.contains('çorba');
    final explicitMonths = monthsFrom(q) != null;
    final babyContext = explicitMonths || q.contains('bebe') || q.contains('ek gıda') || q.contains('püre');
    if (asksFood && months != null && months <= 72 && (babyContext || childMonths != null)) {
      final fit = babyRecipes.where((r) => r.minMonths <= months).toList();
      final scored = _rank(fit, tokens, (r) => normalize('${r.title} ${r.category} ${r.ingredients.join(' ')}'));
      final picks = (scored.isEmpty ? fit.reversed.toList() : scored).take(5);
      if (fit.isNotEmpty) {
        sections.add(AssistantSection('$months ay için tarif önerileri', [
          for (final r in picks) '${r.title} (${r.minMonths}+ ay, ${r.category})',
          if (months < 12) '12 aydan önce tuz, şeker ve bal eklenmez; bütün kuruyemiş verilmez.',
        ], 'Bebek tarifleri kataloğu'));
      }
    }
    if (asksFood && !babyContext) {
      final ranked = _rank(generalRecipes, tokens,
          (r) => normalize('${r.title} ${r.category} ${r.ingredients.join(' ')}'));
      if (ranked.isNotEmpty) {
        sections.add(AssistantSection('Tarif önerileri', [
          for (final r in ranked.take(5)) '${r.title} (${r.minutes} dk, ${r.category})',
        ], 'Genel tarif kataloğu'));
      }
    }

    final asksPlay = q.contains('oyun') || q.contains('etkinlik') || q.contains('aktivite') ||
        q.contains('oyna') || q.contains('gelişim');
    if (asksPlay && months != null) {
      final acts = BabyActivityCatalog.all
          .where((a) => months >= a.minMonth && months <= a.maxMonth)
          .take(5)
          .toList();
      if (acts.isNotEmpty) {
        sections.add(AssistantSection('$months ay için oyun ve etkinlikler', [
          for (final a in acts) '${a.title} (${a.area}, ${a.minutes} dk): ${a.steps.split('\n').first}',
          acts.first.safety,
        ], 'Yaşa göre etkinlik kataloğu'));
      }
    }

    // Rehber konuları: eş anlamlı ipucu veya başlık eşleşmesi önceliklidir.
    final hinted = <String>{
      for (final e in _topicHints.entries)
        if (q.contains(e.key)) ...e.value,
    };
    final guides = <(int, String)>[];
    guideContent.forEach((topic, lines) {
      final text = normalize('$topic ${lines.join(' ')}');
      final topicN = normalize(topic);
      var score = hinted.contains(topic) ? 6 : 0;
      for (final t in tokens) {
        if (_matches(topicN, t)) score += 3;
        if (_matches(text, t)) score += 1;
      }
      if (score > 0) guides.add((score, topic));
    });
    guides.sort((a, b) => b.$1.compareTo(a.$1));
    // Başka bölüm varsa yalnızca güçlü eşleşmeler; acil durumda yalnızca sağlık.
    final minScore = sections.isEmpty ? 2 : 3;
    final allowed = guides.where((g) => g.$1 >= minScore &&
        (urgent == null || g.$2 == 'Hastalıklar ve Belirtiler' || g.$2 == 'Sağlık'));
    for (final (_, topic) in allowed.take(sections.isEmpty ? 3 : 2)) {
      sections.add(AssistantSection(topic, guideContent[topic]!, 'Uygulama içi rehber'));
    }

    return AssistantAnswer(urgent: urgent, sections: sections);
  }

  static List<T> _rank<T>(List<T> items, List<String> tokens, String Function(T) text) {
    if (tokens.isEmpty) return [];
    final scored = <(int, T)>[];
    for (final item in items) {
      final t = text(item);
      final s = tokens.where((tok) => _matches(t, tok)).length;
      if (s > 0) scored.add((s, item));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return scored.map((e) => e.$2).toList();
  }

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
