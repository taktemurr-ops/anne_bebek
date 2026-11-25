// Sağılmış anne sütü stoğu. Saklama süreleri CDC önerileridir (sağlıklı, term
// bebek için): oda sıcaklığı 4 saat, buzdolabı 4 gün, dondurucu 6 ay (en iyi)
// ile 12 ay (kabul edilebilir). Çözülmüş süt buzdolabında 24 saat; tekrar
// dondurulmaz.

const milkPlaces = ['Buzdolabı', 'Dondurucu', 'Oda sıcaklığı', 'Çözülmüş (buzdolabında)'];

class MilkBag {
  final String id;
  final DateTime pumped;
  final int ml;
  final String place;
  final DateTime? movedAt; // çözülmeye alındığı an
  final bool used;
  const MilkBag({required this.id, required this.pumped, required this.ml, this.place = 'Buzdolabı', this.movedAt, this.used = false});

  Map<String, dynamic> toJson() => {
        'id': id, 'pumped': pumped.toIso8601String(), 'ml': ml, 'place': place,
        if (movedAt != null) 'movedAt': movedAt!.toIso8601String(), if (used) 'used': true,
      };

  static MilkBag? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final p = DateTime.tryParse('${raw['pumped']}');
    final ml = raw['ml'];
    if (id is! String || p == null || ml is! int || ml <= 0 || ml > 1000) return null;
    return MilkBag(id: id, pumped: p, ml: ml,
        place: milkPlaces.contains(raw['place']) ? raw['place'] as String : 'Buzdolabı',
        movedAt: DateTime.tryParse('${raw['movedAt']}'), used: raw['used'] == true);
  }

  MilkBag copyWith({String? place, DateTime? movedAt, bool? used}) =>
      MilkBag(id: id, pumped: pumped, ml: ml, place: place ?? this.place, movedAt: movedAt ?? this.movedAt, used: used ?? this.used);

  /// Son kullanma anı.
  DateTime get expires => switch (place) {
        'Oda sıcaklığı' => pumped.add(const Duration(hours: 4)),
        'Dondurucu' => DateTime(pumped.year, pumped.month + 6, pumped.day, pumped.hour, pumped.minute),
        'Çözülmüş (buzdolabında)' => (movedAt ?? pumped).add(const Duration(hours: 24)),
        _ => pumped.add(const Duration(days: 4)),
      };

  bool expired(DateTime now) => now.isAfter(expires);
}

List<MilkBag> decodeMilkBags(Object? raw) {
  if (raw is! List) return [];
  return raw.map(MilkBag.fromJson).whereType<MilkBag>().toList()..sort((a, b) => a.pumped.compareTo(b.pumped));
}

/// Kullanılabilir torbalar, önce son kullanma tarihi en yakın olan.
List<MilkBag> usableFirst(List<MilkBag> bags, DateTime now) =>
    bags.where((b) => !b.used && !b.expired(now)).toList()..sort((a, b) => a.expires.compareTo(b.expires));

int totalMl(Iterable<MilkBag> bags) => bags.fold(0, (a, b) => a + b.ml);

const milkStorageTips = <String>[
  'Torbalara sağım tarihini yaz; önce en eski sütü kullan.',
  'Bebeğin bir öğünde içeceği kadar (60–120 ml) küçük porsiyonlarla dondur; israf azalır.',
  'Dondurucuda kapağa yakın değil, arka tarafta sakla; buzdolabında da kapak rafına koyma.',
  'Donmuş sütü buzdolabında bir gecede ya da ılık su içinde çöz; mikrodalgada ya da kaynar suda ısıtma.',
  'Çözülmüş süt buzdolabında 24 saat içinde kullanılır ve tekrar dondurulmaz.',
  'Bebeğin içmeye başladığı sütün kalanı 2 saat içinde kullanılmalı, sonra dökülmeli.',
  'Prematüre ya da hastanede yatan bebekler için süreler daha kısadır; hastanenin önerisine uy.',
];
