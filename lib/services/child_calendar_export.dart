import 'child_care_plans.dart';

/// Exports manually entered, incomplete child appointments as an iCalendar
/// document. Dates are all-day; no clinical schedule is generated.
String buildChildCareCalendar(List<ChildCareItem> all, String childId, String childName) {
  final items = careItemsForChild(all, childId).where((e) => !e.completed);
  final lines = <String>[
    'BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//Anne Bebek//Kisisel Saglik Plani//TR',
    'CALSCALE:GREGORIAN', 'METHOD:PUBLISH',
  ];
  for (final item in items) {
    final date = DateTime(item.date.year, item.date.month, item.date.day);
    final end = date.add(const Duration(days: 1));
    String day(DateTime d) => '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    lines.addAll([
      'BEGIN:VEVENT',
      'UID:${_escape(item.childId)}-${_escape(item.id)}@annebebek.local',
      'DTSTART;VALUE=DATE:${day(date)}',
      'DTEND;VALUE=DATE:${day(end)}',
      'SUMMARY:${_escape(childName)} - ${_escape(item.title)}',
      'DESCRIPTION:${_escape(item.category)} - ${_escape(item.note)}',
      'END:VEVENT',
    ]);
  }
  lines.add('END:VCALENDAR');
  // RFC 5545 requires CRLF; fold long content lines at 75 octets in a future revision.
  return '${lines.join('\r\n')}\r\n';
}

String _escape(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll('\r\n', '\n')
    .replaceAll('\r', '\n')
    .replaceAll('\n', r'\n')
    .replaceAll(',', r'\,')
    .replaceAll(';', r'\;');
