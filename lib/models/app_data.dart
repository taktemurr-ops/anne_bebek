class BabyProfile {
  final String name;
  final DateTime birthDate;
  const BabyProfile({required this.name, required this.birthDate});
  Map<String, dynamic> toJson() => {'name': name, 'birthDate': birthDate.toIso8601String()};
  factory BabyProfile.fromJson(Map<String, dynamic> json) => BabyProfile(name: json['name'] as String, birthDate: DateTime.parse(json['birthDate'] as String));
}

class BabyEntry {
  final String id;
  final String category;
  final String note;
  final DateTime createdAt;
  const BabyEntry({required this.id, required this.category, required this.note, required this.createdAt});
  Map<String, dynamic> toJson() => {'id': id, 'category': category, 'note': note, 'createdAt': createdAt.toIso8601String()};
  factory BabyEntry.fromJson(Map<String, dynamic> json) => BabyEntry(id: json['id'] as String, category: json['category'] as String, note: json['note'] as String, createdAt: DateTime.parse(json['createdAt'] as String));
}
