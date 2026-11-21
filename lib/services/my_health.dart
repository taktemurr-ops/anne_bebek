import 'dart:convert';

/// Kadının kendi sağlığı: ölçümler, ilaç/vitamin planı ve koruyucu kontroller.
/// Tümü cihazda, güvenli depoda tutulur. Tanı koymaz; eşikler genel bilgidir.

class HealthKind {
  final String id;
  final String title;
  final String emoji;
  final String unit;
  final double min;
  final double max;
  final bool twoValues; // tansiyon
  final double? dailyGoal;
  const HealthKind(this.id, this.title, this.emoji, this.unit, this.min, this.max,
      {this.twoValues = false, this.dailyGoal});
}

const healthKinds = <HealthKind>[
  HealthKind('weight', 'Kilo', '⚖️', 'kg', 25, 250),
  HealthKind('water', 'Su', '💧', 'bardak', 1, 30, dailyGoal: 8),
  HealthKind('bp', 'Tansiyon', '🩺', 'mmHg', 60, 250, twoValues: true),
  HealthKind('glucose', 'Kan şekeri', '🩸', 'mg/dL', 20, 600),
  HealthKind('sleep', 'Uyku', '😴', 'saat', 0.5, 24),
  HealthKind('exercise', 'Egzersiz', '🏃‍♀️', 'dk', 1, 600, dailyGoal: 30),
  HealthKind('steps', 'Adım', '👟', 'adım', 1, 100000),
  HealthKind('mood', 'Ruh hâli', '🙂', '/5', 1, 5),
];

HealthKind kindById(String id) => healthKinds.firstWhere((k) => k.id == id);

class HealthEntry {
  final String kind;
  final DateTime date;
  final double value;
  final double? value2;
  final String note;
  const HealthEntry(this.kind, this.date, this.value, {this.value2, this.note = ''});

  Map<String, dynamic> toJson() => {
        'kind': kind, 'date': date.toIso8601String(), 'value': value,
        if (value2 != null) 'value2': value2, if (note.isNotEmpty) 'note': note,
      };
  static HealthEntry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final k = raw['kind'], d = DateTime.tryParse('${raw['date']}'), v = raw['value'];
    if (k is! String || d == null || v is! num || !healthKinds.any((x) => x.id == k)) return null;
    final kind = kindById(k);
    if (v < kind.min || v > kind.max) return null;
    final v2 = raw['value2'];
    return HealthEntry(k, d, v.toDouble(), value2: v2 is num ? v2.toDouble() : null,
        note: raw['note'] is String ? raw['note'] as String : '');
  }
}

/// Ölçüm doğrulama: aralık dışı ve tansiyonda küçük değer eksikse null.
String? validateEntry(String kind, double? v, double? v2) {
  final k = kindById(kind);
  if (v == null || !v.isFinite || v < k.min || v > k.max) {
    return '${k.title} için ${_n(k.min)}–${_n(k.max)} ${k.unit} arasında bir değer girin.';
  }
  if (k.twoValues && (v2 == null || v2 < 30 || v2 > 160 || v2 >= v)) {
    return 'Küçük tansiyonu (30–160 mmHg, büyük tansiyondan küçük) girin.';
  }
  return null;
}

String _n(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

String formatEntryValue(HealthEntry e) {
  final k = kindById(e.kind);
  if (k.twoValues) return '${_n(e.value)}/${_n(e.value2 ?? 0)} ${k.unit}';
  if (k.id == 'mood') return '${moodEmoji(e.value.round())} ${_n(e.value)}/5';
  return '${_n(e.value)} ${k.unit}';
}

String moodEmoji(int v) => const ['😢', '😟', '😐', '🙂', '😄'][(v.clamp(1, 5)) - 1];

/// Genel uyarılar (gebelik dışı yetişkin kadın için).
String? entryWarning(HealthEntry e, {List<HealthEntry> history = const []}) {
  switch (e.kind) {
    case 'bp':
      final s = e.value, d = e.value2 ?? 0;
      if (s >= 180 || d >= 120) return 'Çok yüksek tansiyon. Baş ağrısı, göğüs ağrısı, nefes darlığı ya da konuşma bozukluğu varsa hemen 112’yi ara.';
      if (s >= 140 || d >= 90) return 'Tansiyon yüksek. Dinlenip tekrar ölç; tekrarlıyorsa doktoruna başvur.';
      if (s < 90 || d < 60) return 'Tansiyon düşük. Baş dönmesi ya da bayılma hissi varsa doktoruna danış.';
    case 'glucose':
      if (e.value < 70) return 'Kan şekeri düşük. Hızlı emilen şeker al, 15 dk sonra yeniden ölç; düzelmezse doktoruna başvur.';
      if (e.value >= 250) return 'Kan şekeri çok yüksek. Doktoruna hemen başvur.';
      if (e.value > 180) return 'Kan şekeri yüksek. Doktorunun önerdiği hedeflere göre değerlendir.';
    case 'mood':
      final lowDays = [e, ...history].where((h) => h.kind == 'mood' && h.value <= 2 &&
          e.date.difference(h.date).inDays.abs() <= 14).map((h) => '${h.date.year}-${h.date.month}-${h.date.day}').toSet();
      if (lowDays.length >= 5) {
        return 'Son iki haftada birçok gün kendini kötü hissetmişsin. Bu yalnız taşıman gereken bir yük değil; '
            'bir yakınınla ya da doktorunla konuş. Kendine zarar verme düşüncesi varsa hemen 112’yi ara.';
      }
    case 'sleep':
      if (e.value < 5) return 'Kısa uyku. Bebeğin uyurken dinlenmeye, yardım istemeye çalış.';
  }
  return null;
}

/// Gün toplamı (su, egzersiz, adım) ya da günün son ölçümü.
double? todayValue(List<HealthEntry> entries, String kind, DateTime now) {
  final today = entries.where((e) => e.kind == kind && e.date.year == now.year &&
      e.date.month == now.month && e.date.day == now.day).toList();
  if (today.isEmpty) return null;
  if (const {'water', 'exercise', 'steps'}.contains(kind)) {
    return today.fold<double>(0, (s, e) => s + e.value);
  }
  today.sort((a, b) => b.date.compareTo(a.date));
  return today.first.value;
}

double? bmi(double weightKg, double heightCm) =>
    heightCm < 100 || heightCm > 230 ? null : weightKg / ((heightCm / 100) * (heightCm / 100));

String bmiLabel(double b) => b < 18.5 ? 'zayıf' : b < 25 ? 'normal' : b < 30 ? 'fazla kilolu' : 'obez';

// ---------------- İlaç ve vitamin ----------------

class Medication {
  final String id;
  final String name;
  final String dose;
  final List<String> times; // "08:00"
  final bool notify;
  final bool active;
  const Medication(this.id, this.name, {this.dose = '', this.times = const ['09:00'], this.notify = false, this.active = true});

  Medication copyWith({String? name, String? dose, List<String>? times, bool? notify, bool? active}) =>
      Medication(id, name ?? this.name, dose: dose ?? this.dose, times: times ?? this.times,
          notify: notify ?? this.notify, active: active ?? this.active);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'dose': dose, 'times': times, 'notify': notify, 'active': active};
  static Medication? fromJson(Object? raw) {
    if (raw is! Map || raw['id'] is! String || raw['name'] is! String) return null;
    final times = raw['times'] is List
        ? (raw['times'] as List).whereType<String>().where(validTime).toList()
        : <String>[];
    return Medication(raw['id'] as String, raw['name'] as String,
        dose: raw['dose'] is String ? raw['dose'] as String : '',
        times: times.isEmpty ? const ['09:00'] : times,
        notify: raw['notify'] == true, active: raw['active'] != false);
  }
}

bool validTime(String t) {
  final m = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(t);
  if (m == null) return false;
  return int.parse(m[1]!) < 24 && int.parse(m[2]!) < 60;
}

String dayKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Alındı kaydı anahtarı: ilaç|gün|saat.
String doseKey(String medId, DateTime day, String time) => '$medId|${dayKey(day)}|$time';

// ---------------- Koruyucu kontroller ----------------

class Checkup {
  final String id;
  final String title;
  final String detail;
  final int intervalMonths;
  final int minAge;
  final int maxAge;
  const Checkup(this.id, this.title, this.detail, this.intervalMonths, {this.minAge = 18, this.maxAge = 120});
}

/// Genel tarama önerileri; kişisel risk ve ülke programına göre doktor değiştirebilir.
const checkups = <Checkup>[
  Checkup('breast_self', 'Meme kendi muayenesi', 'Her ay, adet bitiminden birkaç gün sonra. Ele gelen kitle, meme başı akıntısı ya da ciltte çekinti varsa doktora git.', 1, minAge: 20),
  Checkup('breast_clinical', 'Klinik meme muayenesi', '20–39 yaş arası 1–3 yılda bir, 40 yaştan sonra yılda bir.', 12, minAge: 20),
  Checkup('mammography', 'Mamografi', '40–69 yaş arası 1–2 yılda bir (Türkiye’de KETEM’lerde ücretsiz, 2 yılda bir).', 24, minAge: 40, maxAge: 69),
  Checkup('cervical', 'Rahim ağzı taraması (HPV/smear)', '30–65 yaş arası 5 yılda bir; doktorun daha sık önerebilir.', 60, minAge: 30, maxAge: 65),
  Checkup('dental', 'Diş kontrolü', 'Altı ayda bir; gebelikte de güvenle yapılabilir.', 6),
  Checkup('eye', 'Göz muayenesi', '1–2 yılda bir; görme değişikliği varsa daha erken.', 24),
  Checkup('blood_pressure', 'Tansiyon ölçümü', 'En az yılda bir.', 12),
  Checkup('blood_tests', 'Kan tahlilleri (şeker, kolesterol, demir, B12, D vitamini)', 'Yılda bir genel kontrol; doktorunun önerisine göre.', 12),
  Checkup('skin', 'Ben ve cilt kontrolü', 'Yılda bir; büyüyen, renk değiştiren ya da kanayan ben için beklemeden.', 12),
  Checkup('colon', 'Kalın bağırsak taraması', '50–70 yaş arası 2 yılda bir gaitada gizli kan testi.', 24, minAge: 50, maxAge: 70),
  Checkup('bone', 'Kemik yoğunluğu ölçümü', '65 yaştan sonra ya da menopoz sonrası risk varsa doktorun önerisiyle.', 24, minAge: 65),
];

DateTime addMonths(DateTime d, int months) {
  final m = d.month - 1 + months;
  final y = d.year + m ~/ 12;
  final mm = m % 12 + 1;
  final last = DateTime(y, mm + 1, 0).day;
  return DateTime(y, mm, d.day > last ? last : d.day);
}

enum CheckupState { notApplicable, never, due, ok }

CheckupState checkupState(Checkup c, DateTime? last, int? age, DateTime now) {
  if (age != null && (age < c.minAge || age > c.maxAge)) return CheckupState.notApplicable;
  if (last == null) return CheckupState.never;
  return addMonths(last, c.intervalMonths).isAfter(now) ? CheckupState.ok : CheckupState.due;
}

// ---------------- Depolama ----------------

class MyHealthData {
  final List<HealthEntry> entries;
  final List<Medication> meds;
  final Set<String> taken; // doseKey
  final Map<String, DateTime> checks;
  final double? heightCm;
  const MyHealthData({this.entries = const [], this.meds = const [], this.taken = const {},
      this.checks = const {}, this.heightCm});

  MyHealthData copyWith({List<HealthEntry>? entries, List<Medication>? meds, Set<String>? taken,
          Map<String, DateTime>? checks, double? heightCm}) =>
      MyHealthData(entries: entries ?? this.entries, meds: meds ?? this.meds, taken: taken ?? this.taken,
          checks: checks ?? this.checks, heightCm: heightCm ?? this.heightCm);

  static MyHealthData decode(String? raw) {
    if (raw == null || raw.isEmpty) return const MyHealthData();
    try {
      final d = jsonDecode(raw);
      if (d is! Map) return const MyHealthData();
      final entries = (d['entries'] is List ? d['entries'] as List : const [])
          .map(HealthEntry.fromJson).whereType<HealthEntry>().toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      final meds = (d['meds'] is List ? d['meds'] as List : const [])
          .map(Medication.fromJson).whereType<Medication>().toList();
      final taken = (d['taken'] is List ? d['taken'] as List : const []).whereType<String>().toSet();
      final checks = <String, DateTime>{};
      if (d['checks'] is Map) {
        (d['checks'] as Map).forEach((k, v) {
          final t = DateTime.tryParse('$v');
          if (k is String && t != null && checkups.any((c) => c.id == k)) checks[k] = t;
        });
      }
      final h = d['height'];
      return MyHealthData(entries: entries, meds: meds, taken: taken, checks: checks,
          heightCm: h is num && h >= 100 && h <= 230 ? h.toDouble() : null);
    } catch (_) {
      return const MyHealthData();
    }
  }

  /// 90 günden eski "alındı" işaretleri atılır.
  String encode(DateTime now) {
    final cutoff = dayKey(now.subtract(const Duration(days: 90)));
    return jsonEncode({
      'entries': entries.take(3000).map((e) => e.toJson()).toList(),
      'meds': meds.map((m) => m.toJson()).toList(),
      'taken': taken.where((k) => k.split('|').elementAtOrNull(1) != null && k.split('|')[1].compareTo(cutoff) >= 0).toList(),
      'checks': checks.map((k, v) => MapEntry(k, v.toIso8601String())),
      if (heightCm != null) 'height': heightCm,
    });
  }
}
