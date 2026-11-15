import 'package:flutter/material.dart';
import '../services/forum_safety_service.dart';

class ForumReportButton extends StatelessWidget {
  final String forum;
  final String kind;
  final String contentId;
  const ForumReportButton({super.key, required this.forum, required this.kind,
    required this.contentId});
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Şikâyet et', icon: const Icon(Icons.flag_outlined),
    onPressed: () async {
      const reasons = ['Spam / reklam', 'Hakaret / taciz', 'Kişisel veri paylaşımı',
        'Yanıltıcı sağlık bilgisi', 'Diğer'];
      final reason = await showDialog<String>(context: context, builder: (ctx) =>
        SimpleDialog(title: const Text('Şikâyet nedeni'), children: reasons.map((r) =>
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, r), child: Text(r))).toList()));
      if (reason == null || !context.mounted) return;
      try {
        await ForumSafetyService.report(forum: forum, kind: kind,
          contentId: contentId, reason: reason);
        if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şikâyetiniz inceleme için iletildi.'))); }
      } catch (e) {
        if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şikâyet gönderilemedi: $e'))); }
      }
    },
  );
}

class ForumNotificationsPage extends StatefulWidget {
  const ForumNotificationsPage({super.key});
  @override
  State<ForumNotificationsPage> createState() => _ForumNotificationsPageState();
}
class _ForumNotificationsPageState extends State<ForumNotificationsPage> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final result = await ForumSafetyService.notifications();
      if (mounted) setState(() { items = result; loading = false; });
    } catch (e) { if (mounted) setState(() { error = '$e'; loading = false; }); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Forum bildirimleri'), actions: [
      IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
    body: loading ? const Center(child: CircularProgressIndicator()) : error != null
      ? Center(child: Text(error!)) : RefreshIndicator(onRefresh: _load,
        child: ListView(children: [
          const ListTile(title: Text('Uygulama içi bildirimler'), subtitle: Text(
            'Yeni yanıtlar burada görüntülenir. Anlık telefon bildirimi henüz etkin değildir.')),
          if (items.isEmpty) const ListTile(title: Text('Henüz bildiriminiz yok.')),
          for (final item in items) ListTile(
            leading: Icon(item['read_at'] == null ? Icons.markunread : Icons.drafts_outlined),
            title: Text(item['forum'] == 'baby' ? 'Bebeğim forumunda yeni yanıt' : 'Kadınlar forumunda yeni yanıt'),
            subtitle: Text(item['created_at']?.toString() ?? ''),
            trailing: item['read_at'] == null ? TextButton(onPressed: () async {
              try { await ForumSafetyService.markRead(item['id'].toString()); await _load(); }
              catch (e) { if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e'))); } }
            }, child: const Text('Okundu')) : null,
          ),
        ])),
  );
}

class ForumModerationPage extends StatefulWidget {
  const ForumModerationPage({super.key});
  @override
  State<ForumModerationPage> createState() => _ForumModerationPageState();
}
class _ForumModerationPageState extends State<ForumModerationPage> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final result = await ForumSafetyService.pendingReports();
      if (mounted) setState(() { items = result; loading = false; });
    } catch (e) { if (mounted) setState(() { error = '$e'; loading = false; }); }
  }
  Future<void> _decide(String id, String status) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Moderatör kararı'),
      content: Text(status == 'removed' ? 'Şikâyet edilen içerik silinsin mi?' : 'Şikâyet reddedilsin mi?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Onayla'))]));
    if (yes != true) return;
    try { await ForumSafetyService.resolveReport(id, status); await _load(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Moderatör incelemeleri'), actions: [
      IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
    body: loading ? const Center(child: CircularProgressIndicator()) : error != null
      ? Center(child: Text(error!)) : RefreshIndicator(onRefresh: _load,
        child: ListView(children: [
          const ListTile(title: Text('Yetki kontrollü moderasyon'), subtitle: Text(
            'Yalnızca sunucuda moderatör olarak tanımlanan hesaplar şikâyetleri görüntüleyebilir.')),
          if (items.isEmpty) const ListTile(title: Text('Bekleyen şikâyet bulunamadı.')),
          for (final item in items) Card(child: Column(children: [
            ListTile(title: Text(item['reason']?.toString() ?? ''),
              subtitle: Text('${item['forum']} • ${item['content_kind']} • ${item['created_at']}')),
            Wrap(spacing: 8, children: [
              TextButton(onPressed: () => _decide(item['id'].toString(), 'dismissed'),
                child: const Text('Reddet')),
              FilledButton(onPressed: () => _decide(item['id'].toString(), 'removed'),
                child: const Text('İçeriği kaldır')),
            ]),
          ])),
        ])),
  );
}
