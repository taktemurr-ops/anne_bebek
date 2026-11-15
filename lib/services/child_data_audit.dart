import 'child_journals.dart';
import 'child_profiles.dart';

/// Read-only consistency check. Never alters or migrates health data.
class ChildDataAudit {
  final int profileCount;
  final int journalCount;
  final List<String> orphanEntryIds;
  final List<String> futureEntryIds;
  final List<String> beforeBirthEntryIds;
  const ChildDataAudit({required this.profileCount, required this.journalCount,
    required this.orphanEntryIds, required this.futureEntryIds,
    required this.beforeBirthEntryIds});
  bool get isClean => orphanEntryIds.isEmpty && futureEntryIds.isEmpty && beforeBirthEntryIds.isEmpty;
}

ChildDataAudit auditChildData(List<ChildProfile> profiles,
    List<ChildJournalEntry> entries, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final byId = {for (final p in profiles) p.id: p};
  final orphans = <String>[];
  final future = <String>[];
  final beforeBirth = <String>[];
  for (final entry in entries) {
    final profile = byId[entry.childId];
    if (profile == null) {
      orphans.add(entry.id);
    } else if (entry.at.isBefore(DateTime(profile.birthDate.year,
        profile.birthDate.month, profile.birthDate.day))) {
      beforeBirth.add(entry.id);
    }
    if (entry.at.isAfter(current.add(const Duration(days: 1)))) {
      future.add(entry.id);
    }
  }
  return ChildDataAudit(profileCount: profiles.length, journalCount: entries.length,
    orphanEntryIds: List.unmodifiable(orphans),
    futureEntryIds: List.unmodifiable(future),
    beforeBirthEntryIds: List.unmodifiable(beforeBirth));
}
