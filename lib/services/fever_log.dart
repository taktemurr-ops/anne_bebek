import 'dart:convert';

/// Ateş ve ilaç kaydı. Teşhis koymaz, doz önermez; yalnızca yaygın kabul gören
/// "doktora başvur / acile git" eşiklerini hatırlatır (AAP ve NHS rehberleriyle
/// uyumlu genel eşikler).

const feverMethods = ['Koltuk altı', 'Kulak', 'Alın', 'Makattan'];

class FeverEntry {
  final DateTime time;
  final double? temperature; // °C
  final String method;
  final String medicine; // boşsa ilaç verilmedi
  final String note;
  const FeverEntry(this.time, {this.temperature, this.method = 'Koltuk altı', this.medicine = '', this.note = ''});

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        if (temperature != null) 'temperature': temperature,
        'method': method,
        if (medicine.isNotEmpty) 'medicine': medicine,
        if (note.isNotEmpty) 'note': note,
      };

  static FeverEntry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final t = DateTime.tryParse('${raw['time']}');
    if (t == null) return null;
    final temp = raw['temperature'];
    final m = raw['method'];
    final temperature = temp is num && validTemperature(temp.toDouble()) ? temp.toDouble() : null;
    final medicine = raw['medicine'] is String ? (raw['medicine'] as String).trim() : '';
    if (temperature == null && medicine.isEmpty) return null;
    return FeverEntry(t,
        temperature: temperature,
        method: feverMethods.contains(m) ? m as String : 'Koltuk altı',
        medicine: medicine,
        note: raw['note'] is String ? raw['note'] as String : '');
  }
}

bool validTemperature(double? t) => t != null && t.isFinite && t >= 34 && t <= 43;

/// Termometre girişi: "38,5" ya da "38.5". Geçersizse null.
double? parseTemperature(String text) {
  final v = double.tryParse(text.trim().replaceAll(',', '.'));
  return validTemperature(v) ? v : null;
}

enum FeverLevel { low, normal, fever, doctor, emergency }

class FeverAdvice {
  final FeverLevel level;
  final String message;
  const FeverAdvice(this.level, this.message);
}

/// [ageMonths] bilinmiyorsa null; o durumda bebek eşikleri uygulanmaz ama
/// 3 aydan küçük bebek uyarısı metinde hatırlatılır.
FeverAdvice feverAdvice(double temperature, String method, int? ageMonths) {
  // Koltuk altı ölçüm vücut içi sıcaklıktan yaklaşık 0,5 °C düşüktür.
  final core = method == 'Koltuk altı' ? temperature + 0.5 : temperature;
  if (core < 35.5) {
    return const FeverAdvice(FeverLevel.low,
        'Vücut ısısı düşük görünüyor. Bebeği ısıt, ölçümü tekrarla; düşük kalıyorsa ya da bebek halsizse hemen doktora başvur.');
  }
  if (core >= 40) {
    return const FeverAdvice(FeverLevel.emergency,
        '40 °C ve üzeri ateş: Beklemeden 112’yi ara ya da en yakın acile git.');
  }
  if (core < 38) {
    return const FeverAdvice(FeverLevel.normal, 'Ölçüm ateş sınırının altında.');
  }
  if (ageMonths != null && ageMonths < 3) {
    return const FeverAdvice(FeverLevel.emergency,
        '3 aydan küçük bebekte 38 °C ve üzeri ateş: Bebek iyi görünse bile hemen doktora ya da acile başvur.');
  }
  if (ageMonths != null && ageMonths < 6 && core >= 39) {
    return const FeverAdvice(FeverLevel.doctor,
        '3–6 aylık bebekte 39 °C ve üzeri ateş: Aynı gün doktoruna başvur.');
  }
  return FeverAdvice(FeverLevel.fever,
      'Ateş var. Bol sıvı ver, ince giydir ve ölçümü tekrarla. İlaç vereceksen dozu doktorun ya da eczacının söylediği şekilde, çocuğun kilosuna göre ver.'
      '${ageMonths == null ? ' Bebek 3 aydan küçükse hemen doktora başvur.' : ''}');
}

/// Kayıtlara göre ateşin ne zamandır sürdüğünü hesaplar: son ölçüm ateşliyse,
/// geriye doğru ateşsiz ölçüme rastlanana kadarki ilk ateşli ölçüm.
Duration? feverDuration(List<FeverEntry> entries, DateTime now) {
  final measured = entries.where((e) => e.temperature != null && !e.time.isAfter(now)).toList()
    ..sort((a, b) => b.time.compareTo(a.time));
  if (measured.isEmpty) return null;
  bool isFever(FeverEntry e) => (e.method == 'Koltuk altı' ? e.temperature! + 0.5 : e.temperature!) >= 38;
  if (!isFever(measured.first)) return null;
  var start = measured.first.time;
  for (final e in measured.skip(1)) {
    if (!isFever(e)) break;
    start = e.time;
  }
  return now.difference(start);
}

/// Uzun süren ateş uyarısı: 2 yaş altında 24 saat, üstünde 72 saat.
String? longFeverWarning(Duration? d, int? ageMonths) {
  if (d == null) return null;
  final limit = (ageMonths != null && ageMonths < 24) ? const Duration(hours: 24) : const Duration(hours: 72);
  if (d < limit) return null;
  return 'Ateş ${d.inHours} saattir sürüyor. Doktoruna başvur.';
}

/// Son ilaç kaydı ve üzerinden geçen süre; aynı ilacın gereğinden sık
/// verilmesini önlemeye yardımcı olmak için gösterilir.
({String medicine, Duration since})? lastMedicine(List<FeverEntry> entries, DateTime now) {
  FeverEntry? last;
  for (final e in entries) {
    if (e.medicine.isEmpty || e.time.isAfter(now)) continue;
    if (last == null || e.time.isAfter(last.time)) last = e;
  }
  return last == null ? null : (medicine: last.medicine, since: now.difference(last.time));
}

List<FeverEntry> decodeFeverLog(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final data = jsonDecode(raw);
    if (data is! List) return [];
    final list = data.map(FeverEntry.fromJson).whereType<FeverEntry>().toList()
      ..sort((a, b) => b.time.compareTo(a.time));
    return list;
  } catch (_) {
    return [];
  }
}

String encodeFeverLog(List<FeverEntry> entries) =>
    jsonEncode(entries.take(500).map((e) => e.toJson()).toList());

/// Gebelik günlüğü ölçümleri için uyarı.
String? pregnancyReadingWarning(String type, double? a, double? b) {
  if (type == 'Tansiyon' && a != null && b != null) {
    if (a >= 160 || b >= 110) {
      return 'Çok yüksek tansiyon: Beklemeden 112’yi ara ya da doğumhaneye git.';
    }
    if (a >= 140 || b >= 90) {
      return 'Tansiyon yüksek: Ölçümü 15 dakika dinlenip tekrarla ve aynı gün doktoruna haber ver. '
          'Şiddetli baş ağrısı, görme bozukluğu, karın üst kısmında ağrı ya da ani şişlik varsa 112’yi ara.';
    }
    if (a < 90 || b < 60) {
      return 'Tansiyon düşük: Baş dönmesi, bayılma hissi varsa uzan ve doktoruna danış.';
    }
  }
  if (type == 'Kan şekeri' && a != null) {
    if (a < 70) return 'Kan şekeri düşük: Hızlı emilen şeker al (ör. yarım bardak meyve suyu), 15 dk sonra yeniden ölç; düzelmezse doktoruna başvur.';
    if (a > 180) return 'Kan şekeri yüksek: Doktorunun verdiği hedeflere göre değerlendir ve doktoruna bildir.';
  }
  return null;
}
