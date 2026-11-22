// Anı defteri kaydı: tarih, başlık, not ve isteğe bağlı fotoğraf.

const memoryTags = <String>[
  'İlk gülüş', 'İlk kahkaha', 'İlk diş', 'İlk adım', 'İlk kelime', 'İlk ek gıda',
  'Ay fotoğrafı', 'Doğum günü', 'Bayram / özel gün', 'Gezi', 'Diğer',
];

class Memory {
  final String id;
  final DateTime date;
  final String title;
  final String note;
  final String tag;
  final String? photo; // PhotoStore dosya adı
  const Memory({required this.id, required this.date, required this.title, this.note = '', this.tag = 'Diğer', this.photo});

  Map<String, dynamic> toJson() => {
        'id': id, 'date': date.toIso8601String(), 'title': title,
        if (note.isNotEmpty) 'note': note, 'tag': tag, if (photo != null) 'photo': photo,
      };

  static Memory? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final d = DateTime.tryParse('${raw['date']}');
    final title = raw['title'];
    if (id is! String || id.isEmpty || d == null || title is! String) return null;
    final photo = raw['photo'];
    return Memory(
      id: id, date: d, title: title,
      note: raw['note'] is String ? raw['note'] as String : '',
      tag: memoryTags.contains(raw['tag']) ? raw['tag'] as String : 'Diğer',
      photo: photo is String && photo.isNotEmpty && !photo.contains('/') ? photo : null,
    );
  }

  Memory copyWith({DateTime? date, String? title, String? note, String? tag, String? photo, bool clearPhoto = false}) => Memory(
      id: id, date: date ?? this.date, title: title ?? this.title, note: note ?? this.note,
      tag: tag ?? this.tag, photo: clearPhoto ? null : (photo ?? this.photo));
}

List<Memory> decodeMemories(Object? raw) {
  if (raw is! List) return [];
  return raw.map(Memory.fromJson).whereType<Memory>().toList()..sort((a, b) => b.date.compareTo(a.date));
}

/// "3. ay" gibi yaş etiketi.
String ageLabelAt(DateTime? birth, DateTime at) {
  if (birth == null || at.isBefore(birth)) return '';
  var m = (at.year - birth.year) * 12 + at.month - birth.month;
  if (at.day < birth.day) m--;
  if (m <= 0) return '${at.difference(birth).inDays}. gün';
  if (m < 24) return '$m. ay';
  return '${m ~/ 12} yaş ${m % 12} ay';
}
