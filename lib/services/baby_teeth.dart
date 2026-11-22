// Süt dişleri ve genellikle çıktıkları aylar (Amerikan Diş Hekimleri Birliği
// tablosu). Her dişin sağ ve sol eşi vardır; toplam 20 süt dişi.

class ToothType {
  final String id;
  final bool upper;
  final String name;
  final int fromMonth, toMonth;
  const ToothType(this.id, this.upper, this.name, this.fromMonth, this.toMonth);
}

const toothTypes = <ToothType>[
  ToothType('lc', false, 'Alt orta kesici', 6, 10),
  ToothType('uc', true, 'Üst orta kesici', 8, 12),
  ToothType('ul', true, 'Üst yan kesici', 9, 13),
  ToothType('ll', false, 'Alt yan kesici', 10, 16),
  ToothType('u1', true, 'Üst birinci azı', 13, 19),
  ToothType('l1', false, 'Alt birinci azı', 14, 18),
  ToothType('uk', true, 'Üst köpek dişi', 16, 22),
  ToothType('lk', false, 'Alt köpek dişi', 17, 23),
  ToothType('l2', false, 'Alt ikinci azı', 23, 31),
  ToothType('u2', true, 'Üst ikinci azı', 25, 33),
];

const toothSides = ['sağ', 'sol'];

/// Diş kimliği: tür + taraf (ör. 'lc_sağ').
List<String> allToothIds() => [for (final t in toothTypes) for (final s in toothSides) '${t.id}_$s'];

ToothType? toothTypeOf(String id) {
  final p = id.split('_').first;
  for (final t in toothTypes) {
    if (t.id == p) return t;
  }
  return null;
}

Map<String, String> decodeTeeth(Object? raw) {
  if (raw is! Map) return {};
  final ids = allToothIds().toSet();
  final out = <String, String>{};
  raw.forEach((k, v) {
    if (ids.contains(k) && v is String && DateTime.tryParse(v) != null) out['$k'] = v;
  });
  return out;
}

/// Yaşa göre sıradaki beklenen dişler.
List<ToothType> expectedSoon(Map<String, String> erupted, int? ageMonths) {
  if (ageMonths == null) return const [];
  return toothTypes.where((t) {
    final both = toothSides.every((s) => erupted.containsKey('${t.id}_$s'));
    return !both && ageMonths >= t.fromMonth - 2 && ageMonths <= t.toMonth + 2;
  }).toList();
}

const teethCareTips = <String>[
  'İlk diş çıktığı gün fırçalamaya başla: pirinç tanesi kadar florürlü diş macunu, günde iki kez.',
  '3 yaştan sonra bezelye tanesi kadar macun yeterlidir; tükürmeyi öğret, durulamaya gerek yok.',
  'İlk diş hekimi ziyareti ilk diş çıktıktan sonra ve en geç 1 yaşında yapılmalı.',
  'Biberonla ya da emzikle uyutmak, şekerli içecek ve meyve suyu çürük riskini artırır.',
  'Diş çıkarırken diş eti kaşıyıcı veya soğutulmuş (dondurulmamış) diş halkası rahatlatır.',
  'Diş çıkarma yüksek ateş, ishal ya da uzun süren huzursuzluk yapmaz; bunlar varsa doktora danış.',
  'Diş çıkarma jelleri ve kehribar kolyeler önerilmez; boğulma ve zehirlenme riski taşır.',
];
