import 'package:flutter/material.dart';
import '../services/child_data_audit.dart';
import '../services/child_journals.dart';
import '../services/child_profiles.dart';
import '../services/secure_health_store.dart';

class ChildDataAuditPage extends StatefulWidget {
  const ChildDataAuditPage({super.key});
  @override
  State<ChildDataAuditPage> createState() => _ChildDataAuditPageState();
}

class _ChildDataAuditPageState extends State<ChildDataAuditPage> {
  ChildDataAudit? result;
  String? error;
  bool loading = true;

  @override
  void initState() { super.initState(); _check(); }

  Future<void> _check() async {
    setState(() { loading = true; error = null; });
    try {
      final profiles = decodeChildProfiles(await SecureHealthStore.read('child_profiles_directory_v58'));
      final entries = decodeChildJournal(await SecureHealthStore.read('child_journal_entries_v59'));
      final audit = auditChildData(profiles, entries);
      if (mounted) setState(() => result = audit);
    } catch (_) {
      if (mounted) setState(() { result = null; error = 'Veriler doğrulanamadı. Hiçbir kayıt değiştirilmedi.'; });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Çocuk verisi kontrolü'), actions: [
      IconButton(onPressed: loading ? null : _check, icon: const Icon(Icons.refresh), tooltip: 'Yeniden kontrol et'),
    ]),
    body: loading ? const Center(child: CircularProgressIndicator()) :
      ListView(padding: const EdgeInsets.all(16), children: [
        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text(
          'Bu kontrol yalnızca çocuk profillerini ve çocuk bazlı günlük kayıtlarını inceler. '
          'Verileri silmez, değiştirmez veya otomatik taşımaz. Eski ana bebek kayıtları kapsam dışındadır.'))),
        if (error != null) Card(child: ListTile(leading: const Icon(Icons.error_outline), title: Text(error!))),
        if (result != null) ...[
          Card(child: ListTile(leading: Icon(result!.isClean ? Icons.check_circle_outline : Icons.warning_amber_outlined),
            title: Text(result!.isClean ? 'Kontrol edilen bağlantılarda sorun bulunmadı' : 'İncelenmesi gereken kayıtlar var'),
            subtitle: const Text('Bu sonuç tıbbi doğruluk veya tam yedekleme garantisi değildir.'))),
          ListTile(title: const Text('Çocuk profili'), trailing: Text('${result!.profileCount}')),
          ListTile(title: const Text('Çocuk bazlı günlük kaydı'), trailing: Text('${result!.journalCount}')),
          ListTile(title: const Text('Profili bulunamayan kayıt'), trailing: Text('${result!.orphanEntryIds.length}')),
          ListTile(title: const Text('Doğum tarihinden önceki kayıt'), trailing: Text('${result!.beforeBirthEntryIds.length}')),
          ListTile(title: const Text('Gelecekteki kayıt'), trailing: Text('${result!.futureEntryIds.length}')),
          if (!result!.isClean) const Padding(padding: EdgeInsets.all(12), child: Text(
            'Uyarı varsa kayıtları otomatik düzeltmeyin. Önce mevcut verilerin yedeğini alın ve ilgili tarih/profilleri inceleyin.')),
        ],
      ]),
  );
}
