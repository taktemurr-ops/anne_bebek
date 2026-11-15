import 'dart:convert';

/// User-entered appointments and developmental observations. Not a clinical schedule.
class ChildCareItem {
  final String id, childId, category, title, note;
  final DateTime date;
  final bool completed;
  const ChildCareItem({required this.id, required this.childId, required this.category,
    required this.title, required this.note, required this.date, required this.completed});

  Map<String, dynamic> toJson() => {'id': id, 'childId': childId,
    'category': category, 'title': title, 'note': note,
    'date': date.toIso8601String(), 'completed': completed};
  factory ChildCareItem.fromJson(Map<String, dynamic> value) {
    final id = value['id'], child = value['childId'], category = value['category'];
    final title = value['title'], note = value['note'], rawDate = value['date'];
    final completed = value['completed'];
    if (id is! String || id.isEmpty || child is! String || child.isEmpty ||
        category is! String || !{'Aşı', 'Doktor kontrolü', 'Gelişim gözlemi'}.contains(category) ||
        title is! String || title.trim().isEmpty || note is! String || rawDate is! String || completed is! bool) {
      throw const FormatException('Geçersiz takip kaydı');
    }
    final date = DateTime.tryParse(rawDate);
    if (date == null) throw const FormatException('Geçersiz tarih');
    return ChildCareItem(id: id, childId: child, category: category,
      title: title, note: note, date: date, completed: completed);
  }
  ChildCareItem withCompleted(bool value) => ChildCareItem(id: id, childId: childId,
    category: category, title: title, note: note, date: date, completed: value);
}

String encodeChildCareItems(List<ChildCareItem> items) =>
    jsonEncode(items.map((item) => item.toJson()).toList());

List<ChildCareItem> decodeChildCareItems(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) throw const FormatException('Takip listesi bozuk');
  final items = decoded.map((item) => ChildCareItem.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  if (items.map((e) => e.id).toSet().length != items.length) {
    throw const FormatException('Yinelenen kayıt kimliği');
  }
  return items;
}

List<ChildCareItem> careItemsForChild(List<ChildCareItem> items, String childId) =>
    items.where((item) => item.childId == childId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));


/// Only manually entered appointments are classified. Date comparison ignores time.
enum CareDueStatus { completed, overdue, today, upcoming }

CareDueStatus careDueStatus(ChildCareItem item, DateTime now) {
  if (item.completed) return CareDueStatus.completed;
  final day = DateTime(item.date.year, item.date.month, item.date.day);
  final current = DateTime(now.year, now.month, now.day);
  if (day.isBefore(current)) return CareDueStatus.overdue;
  if (day.isAtSameMomentAs(current)) return CareDueStatus.today;
  return CareDueStatus.upcoming;
}

List<ChildCareItem> filterCareItems(List<ChildCareItem> items, String childId,
    DateTime now, String filter) {
  final own = careItemsForChild(items, childId);
  if (filter == 'Tümü') return own;
  return own.where((item) {
    final status = careDueStatus(item, now);
    if (filter == 'Geciken') return status == CareDueStatus.overdue;
    if (filter == 'Bugün') return status == CareDueStatus.today;
    if (filter == 'Yaklaşan') return status == CareDueStatus.upcoming;
    if (filter == 'Tamamlanan') return status == CareDueStatus.completed;
    return false;
  }).toList();
}

