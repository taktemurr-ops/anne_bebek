import 'package:flutter/material.dart';
import '../services/child_profiles.dart';
import '../services/child_journals.dart';
import '../services/child_overview.dart';
import '../services/secure_health_store.dart';
import 'child_journal_page.dart';
import 'child_growth_trends_page.dart';
import 'child_care_plan_page.dart';
import 'child_report_page.dart';
import '../sleep_journal.dart';

class ChildOverviewPage extends StatefulWidget {
  final ChildProfile child;
  const ChildOverviewPage({super.key, required this.child});
  @override
  State<ChildOverviewPage> createState() => _ChildOverviewPageState();
}
class _ChildOverviewPageState extends State<ChildOverviewPage> {
  ChildOverview? overview;
  String? error;
  @override
  void initState() { super.initState(); _refresh(); }
  Future<void> _refresh() async {
    try {
      final records = decodeChildJournal(await SecureHealthStore.read('child_journal_entries_v59'));
      if (mounted) setState(() { overview = childOverview(records, widget.child.id, DateTime.now()); error = null; });
    } catch (_) { if (mounted) setState(() => error = 'Kayıtlar okunamadı. Mevcut veriler korunuyor.'); }
  }
  void _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) _refresh();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.child.name} · Genel bakış')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Doğum: ${widget.child.birthDate.day}.${widget.child.birthDate.month}.${widget.child.birthDate.year}', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      if (error != null) ListTile(title: Text(error!), trailing: TextButton(onPressed: _refresh, child: const Text('Tekrar dene'))),
      if (overview == null && error == null) const Center(child: CircularProgressIndicator()),
      if (overview != null) ...[
        Card(child: ListTile(title: const Text('Toplam kayıt'), trailing: Text('${overview!.total}'))),
        Card(child: ListTile(title: const Text('Son 7 gün'), trailing: Text('${overview!.last7Days}'))),
        Card(child: ListTile(title: const Text('Beslenme kayıtları'), trailing: Text('${overview!.feeding}'))),
        Card(child: ListTile(title: const Text('Uyku kayıtları'), trailing: Text('${overview!.sleep}'))),
        Card(child: ListTile(title: const Text('Sağlık notları'), trailing: Text('${overview!.health}'))),
      ],
      const Divider(),
      ListTile(leading: const Icon(Icons.edit_note), title: const Text('Çocuğa özel günlük'), onTap: () => _open(ChildJournalPage(child: widget.child))),
      ListTile(leading: const Icon(Icons.bedtime_outlined), title: const Text('Uyku takibi ve haftalık grafik'), onTap: () => _open(SleepJournalPage(child: widget.child))),
      ListTile(leading: const Icon(Icons.show_chart), title: const Text('Büyüme geçmişi'), onTap: () => _open(ChildGrowthTrendsPage(child: widget.child))),
      ListTile(leading: const Icon(Icons.vaccines_outlined), title: const Text('Aşı ve sağlık planı'), onTap: () => _open(ChildCarePlanPage(child: widget.child))),
      ListTile(leading: const Icon(Icons.description_outlined), title: const Text('Doktor özeti'), onTap: () => _open(ChildReportPage(child: widget.child))),
      const Padding(padding: EdgeInsets.only(top: 12), child: Text('Bu ekran yalnızca seçilen çocuğun yeni günlük kayıtlarını özetler. Eski ana bebek kayıtları otomatik aktarılmaz. Sağlık istatistikleri tanı amacı taşımaz.')),
    ]),
  );
}
