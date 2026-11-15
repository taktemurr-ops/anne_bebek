import 'package:flutter/material.dart';
import '../services/admin_dashboard_service.dart';
import '../services/forum_safety_service.dart';

/// Admin role is validated by the server RPC; this route is safe to expose
/// because unauthorized users receive no admin data.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _reports = [];
  String? _error;
  bool _loading = false;

  @override
  void initState() { super.initState(); _reload(); }

  Future<void> _reload() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final summary = await AdminDashboardService.summary();
      final reports = await ForumSafetyService.pendingReports();
      if (!mounted) return;
      setState(() { _summary = summary; _reports = reports; });
    } catch (_) {
      if (mounted) { setState(() {
        _summary = null; _reports = [];
        _error = 'Yönetim verilerine erişilemedi. Yönetici yetkinizi, oturumunuzu ve sunucu kurulumunu kontrol edin.';
      }); }
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _decide(Map<String, dynamic> report, String decision) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(decision == 'removed' ? 'İçeriği kaldır?' : 'Şikâyeti reddet?'),
      content: const Text('Bu işlem sunucu üzerinde uygulanır. Devam edilsin mi?'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Onayla'))],
    ));
    if (confirmed != true || !mounted) return;
    try {
      await ForumSafetyService.resolveReport(report['id'].toString(), decision);
      await _reload();
    } catch (_) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem tamamlanamadı. Yetki ve bağlantıyı kontrol edin.'))); }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Merkezi Yönetim'), actions: [
      IconButton(onPressed: _loading ? null : _reload, icon: const Icon(Icons.refresh), tooltip: 'Yenile')]),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(color: Color(0xFFFFE6F3), child: Padding(padding: EdgeInsets.all(14), child: Text(
        'Bu ekran yalnızca sunucu tarafından doğrulanmış yöneticilere veri gösterir. Kullanıcıların sağlık kayıtları burada görüntülenmez.'))),
      if (_loading) const LinearProgressIndicator(),
      if (_error != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!))),
      if (_summary != null) ...[
        const SizedBox(height: 12),
        const Text('Toplu platform istatistikleri', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        for (final item in <(String, String)>[
          ('users', 'Toplam kayıtlı hesap'),
          ('baby_posts', 'Bebeğim forum konuları'),
          ('women_posts', 'Kadınlar forum konuları'),
          ('baby_replies', 'Bebeğim forum yanıtları'),
          ('women_replies', 'Kadınlar forum yanıtları'),
          ('pending_reports', 'Bekleyen şikâyetler'),
        ]) Card(child: ListTile(title: Text(item.$2), trailing: Text('${_summary![item.$1] ?? '—'}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 20),
        const Text('Bekleyen forum şikâyetleri', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        if (_reports.isEmpty) const ListTile(title: Text('Bekleyen şikâyet bulunmuyor.')),
        for (final report in _reports) Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${report['forum'] == 'baby' ? 'Bebeğim' : 'Kadınlar'} • ${report['content_kind'] == 'post' ? 'Konu' : 'Yanıt'}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Neden: ${report['reason'] ?? ''}'),
          Text('Tarih: ${report['created_at'] ?? ''}', style: const TextStyle(color: Colors.black54)),
          Wrap(spacing: 8, children: [
            OutlinedButton(onPressed: _loading ? null : () => _decide(report, 'dismissed'), child: const Text('Reddet')),
            FilledButton(onPressed: _loading ? null : () => _decide(report, 'removed'), child: const Text('İçeriği kaldır')),
          ]),
        ]))),
      ],
      const SizedBox(height: 16),
      const Text('Kullanıcı arama, abonelik gelirleri, içerik editörü ve merkezi ürün yönetimi bu sürümde mevcut değildir.',
        style: TextStyle(color: Colors.black54)),
    ]),
  );
}
