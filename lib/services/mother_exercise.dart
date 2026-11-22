// Pelvik taban (Kegel) programı, nefes egzersizleri ve doğum sonrası hareket
// rehberi. NHS pelvik taban önerileri ve ACOG doğum sonrası egzersiz görüşü
// temel alınmıştır.

class KegelLevel {
  final String name;
  final int holdSeconds, relaxSeconds, reps;
  const KegelLevel(this.name, this.holdSeconds, this.relaxSeconds, this.reps);
}

const kegelLevels = <KegelLevel>[
  KegelLevel('Başlangıç', 3, 3, 10),
  KegelLevel('Orta', 5, 5, 10),
  KegelLevel('İleri', 10, 10, 10),
  KegelLevel('Hızlı sıkmalar', 1, 1, 10),
];

class BreathPattern {
  final String name;
  final String description;
  /// (etiket, saniye) adımları; döngü halinde tekrarlanır.
  final List<(String, int)> steps;
  const BreathPattern(this.name, this.description, this.steps);
  int get cycleSeconds => steps.fold(0, (a, s) => a + s.$2);
}

const breathPatterns = <BreathPattern>[
  BreathPattern('Sakinleştirici nefes', 'Burnundan 4 saniye al, ağzından 6 saniyede yavaşça ver. Verişin uzun olması bedeni sakinleştirir.',
      [('Nefes al', 4), ('Nefes ver', 6)]),
  BreathPattern('Kutu nefesi', 'Al, tut, ver, tut: her biri 4 saniye. Kaygı ve stres anlarında odaklanmaya yardımcı olur.',
      [('Nefes al', 4), ('Tut', 4), ('Nefes ver', 4), ('Tut', 4)]),
  BreathPattern('4-7-8 uykuya hazırlık', '4 saniye al, 7 saniye tut, 8 saniyede ver. Uykuya dalmayı kolaylaştırabilir. Başın dönerse bırak.',
      [('Nefes al', 4), ('Tut', 7), ('Nefes ver', 8)]),
];

const kegelHowTo = <String>[
  'Çişini tutmaya ve gaz çıkarmamaya çalışıyormuş gibi kasları içeri ve yukarı doğru sık.',
  'Karnını, kalçanı ve bacaklarını sıkma; nefesini tutma, normal nefes al.',
  'Günde 3 kez yap. Oturarak, yatarak ya da ayakta yapabilirsin.',
  'Sonuçlar genellikle 3–6 haftada hissedilir; 3 aydır yapıyorsan ve kaçırma sürüyorsa fizyoterapiste başvur.',
  'Tuvaletteyken idrarı kesip başlatmayı alışkanlık hâline getirme; mesaneye zarar verebilir.',
];

class RecoveryStage {
  final String title;
  final List<String> items;
  const RecoveryStage(this.title, this.items);
}

const recoveryStages = <RecoveryStage>[
  RecoveryStage('İlk 2 hafta', [
    'Karın (diyafram) nefesi: sırtüstü yat, nefes alırken karnın yükselsin, verirken pelvik tabanı hafifçe sık.',
    'Pelvik taban egzersizlerine kendini hazır hissettiğinde başla; sonda takıldıysa çıkarılınca.',
    'Ev içinde kısa yürüyüşler, ayak bileği çevirme (pıhtı riskini azaltır).',
    'Bebek, puset ya da alışveriş poşeti dışında ağır kaldırma.',
  ]),
  RecoveryStage('2–6. haftalar', [
    'Yürüyüşleri günde 10–30 dakikaya çıkar.',
    'Duruşuna dikkat et: emzirirken sırtını destekle, omuzlarını gevşet.',
    'Hafif esneme ve pelvik taban egzersizine devam et.',
  ]),
  RecoveryStage('6. hafta kontrolünden sonra', [
    'Doktorun onay verdiyse düşük etkili egzersizlere başla: tempolu yürüyüş, doğum sonrası pilates, sabit bisiklet.',
    'Yüzmeye kanama tamamen bittikten ve dikişler iyileştikten sonra başla.',
    'Karın kaslarını nazik egzersizlerle çalıştır; mekik ve plank için acele etme.',
  ]),
  RecoveryStage('12. haftadan sonra', [
    'Koşu, zıplama ve ağırlık gibi yüksek etkili sporlara pelvik tabanın hazırsa (kaçırma, basınç hissi yoksa) kademeli dön.',
    'Haftada en az 150 dakika orta yoğunlukta hareket hedefle.',
  ]),
];

const recoveryWarnings = <String>[
  'Sezaryen sonrası ilk 6 hafta karnı zorlayan egzersiz ve ağır kaldırmadan kaçın; doktorunun önerisine uy.',
  'Egzersiz sırasında ağrı, kanamada artış, idrar ya da gaz kaçırma, vajinada basınç hissi olursa dur ve doktora ya da fizyoterapiste danış.',
  'Karnın ortasında kabarma (karın kası ayrılması/diyastaz) fark edersen fizyoterapist desteği al.',
  'Göğüs ağrısı, nefes darlığı, bacakta tek taraflı şişlik ya da ağrı acil durumdur: 112’yi ara.',
];

/// Kegel oturum günleri (yyyy-mm-dd) → seri hesabı.
int exerciseStreak(Set<String> days, DateTime now) {
  var d = DateTime(now.year, now.month, now.day);
  String key(DateTime x) => '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
  if (!days.contains(key(d))) d = d.subtract(const Duration(days: 1));
  var n = 0;
  while (days.contains(key(d))) {
    n++;
    d = d.subtract(const Duration(days: 1));
  }
  return n;
}

String dayKey(DateTime x) => '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
