class ActivityPlan {
  final String id;
  final String title;
  final String category;
  final DateTime day;
  final bool done;
  const ActivityPlan({required this.id, required this.title, required this.category, required this.day, this.done = false});

  ActivityPlan copyWith({bool? done}) => ActivityPlan(id: id, title: title, category: category, day: day, done: done ?? this.done);
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'category': category, 'day': day.toIso8601String(), 'done': done};
  factory ActivityPlan.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String?)?.trim() ?? '';
    if (title.isEmpty || title.length > 120) throw const FormatException('Geçersiz etkinlik');
    return ActivityPlan(id: json['id'] as String, title: title, category: json['category'] as String, day: DateTime.parse(json['day'] as String), done: json['done'] == true);
  }
}

bool sameActivityDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
