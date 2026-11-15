import 'forum_safety_page.dart';
import 'package:flutter/material.dart';
import '../services/women_forum_service.dart';

class WomenOnlineForumPage extends StatefulWidget {
  const WomenOnlineForumPage({super.key});
  @override
  State<WomenOnlineForumPage> createState() => _WomenOnlineForumPageState();
}

class _WomenOnlineForumPageState extends State<WomenOnlineForumPage> {
  static const categories = ['Tümü', 'Kadın Sağlığı', 'Gebelik', 'Doğum Sonrası', 'Bakım', 'Yaşam', 'Genel'];
  final search = TextEditingController();
  List<Map<String, dynamic>> posts = [];
  String category = 'Tümü';
  String? error;
  String? userId;
  bool loading = true;
  @override
  void initState() { super.initState(); search.addListener(_redraw); _load(); }
  void _redraw() { if (mounted) setState(() {}); }
  @override
  void dispose() { search.removeListener(_redraw); search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final results = await WomenForumService.posts();
      final id = await WomenForumService.currentUserId();
      if (mounted) setState(() { posts = results; userId = id; loading = false; });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); loading = false; });
    }
  }

  Future<String?> _input(String title, {int lines = 1}) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(title), content: TextField(controller: controller, maxLines: lines,
        maxLength: lines == 1 ? 100 : 2000, decoration: const InputDecoration(hintText: 'Yazınız...')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Kaydet'))],
    ));
    controller.dispose();
    return value == null || value.isEmpty ? null : value;
  }

  void _message(Object error) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  Future<void> _create() async {
    final title = await _input('Konu başlığı');
    if (!mounted || title == null) return;
    final body = await _input('Sorunuzu veya deneyiminizi yazın', lines: 5);
    if (!mounted || body == null) return;
    final selected = await showDialog<String>(context: context, builder: (ctx) => SimpleDialog(
      title: const Text('Kategori'), children: categories.skip(1).map((c) => SimpleDialogOption(
        onPressed: () => Navigator.pop(ctx, c), child: Text(c))).toList(),
    ));
    if (!mounted || selected == null) return;
    try { await WomenForumService.createPost(title, body, selected); await _load(); }
    catch (e) { _message(e); }
  }

  Future<void> _delete(String id) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Konuyu sil?'), content: const Text('Yanıtlar da silinecektir.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))],
    ));
    if (yes != true) return;
    try { await WomenForumService.deletePost(id); await _load(); }
    catch (e) { _message(e); }
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.toLowerCase().trim();
    final visible = posts.where((p) => (category == 'Tümü' || p['category'] == category) &&
      ('${p['title']} ${p['body']}').toLowerCase().contains(query)).toList();
    return Scaffold(appBar: AppBar(title: const Text('Kadınlar • Çevrim içi forum'), actions: [
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ForumNotificationsPage())), icon: const Icon(Icons.notifications_outlined), tooltip: 'Bildirimler'),
      PopupMenuButton<String>(onSelected: (value) { if (value == 'moderation') Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ForumModerationPage())); }, itemBuilder: (_) => [const PopupMenuItem(value: 'moderation', child: Text('Moderatör paneli'))]),
      IconButton(onPressed: _load, icon: const Icon(Icons.refresh), tooltip: 'Yenile')]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _create,
        icon: const Icon(Icons.edit_outlined), label: const Text('Konu aç')),
      body: loading ? const Center(child: CircularProgressIndicator()) : error != null
        ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
            mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_outlined, size: 42),
              const SizedBox(height: 12), Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 12), FilledButton(onPressed: _load, child: const Text('Tekrar dene'))])))
        : RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
          const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
            'Paylaşımlar diğer kullanıcılara açıktır. Kimlik, adres ve özel sağlık bilgilerinizi paylaşmayın. '
            'Bu forum tıbbi danışmanlık yerine geçmez.'))),
          TextField(controller: search, decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search), hintText: 'Konularda ara')),
          const SizedBox(height: 8), SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal,
            children: categories.map((c) => Padding(padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(label: Text(c), selected: category == c,
                onSelected: (_) => setState(() => category = c)))).toList())),
          if (visible.isEmpty) const Padding(padding: EdgeInsets.all(24),
            child: Text('Henüz konu bulunamadı.')),
          for (final post in visible) Card(child: ListTile(
            title: Text(post['title']?.toString() ?? ''),
            subtitle: Text(post['category']?.toString() ?? ''),
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) =>
              _WomenForumDetail(post: post))),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              ForumReportButton(forum: 'women', kind: 'post', contentId: post['id'].toString()),
              if (post['author_id']?.toString() == userId) IconButton(
                tooltip: 'Sil', icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(post['id'].toString())),
            ]),
          )), const SizedBox(height: 90),
        ])),
    );
  }
}

class _WomenForumDetail extends StatefulWidget {
  final Map<String, dynamic> post;
  const _WomenForumDetail({required this.post});
  @override
  State<_WomenForumDetail> createState() => _WomenForumDetailState();
}

class _WomenForumDetailState extends State<_WomenForumDetail> {
  List<Map<String, dynamic>> replies = [];
  String? error;
  bool loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final items = await WomenForumService.replies(widget.post['id'].toString());
      if (mounted) setState(() { replies = items; loading = false; error = null; });
    } catch (e) { if (mounted) setState(() { error = '$e'; loading = false; }); }
  }
  Future<void> _reply() async {
    final controller = TextEditingController();
    final message = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Yanıt yaz'), content: TextField(controller: controller,
        maxLines: 4, maxLength: 2000), actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Gönder')),
      ]));
    controller.dispose();
    if (message == null || message.isEmpty) return;
    try { await WomenForumService.createReply(widget.post['id'].toString(), message); await _load(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Konu detayları')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text(widget.post['category']?.toString() ?? ''),
      Text(widget.post['title']?.toString() ?? '', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12), Text(widget.post['body']?.toString() ?? ''),
      const Divider(height: 36),
      if (loading) const Center(child: CircularProgressIndicator()),
      if (error != null) Text(error!),
      for (final reply in replies) Card(child: ListTile(
        title: Text(reply['body']?.toString() ?? ''),
        trailing: ForumReportButton(forum: 'women', kind: 'reply',
          contentId: reply['id'].toString()))),
      const SizedBox(height: 12), FilledButton.icon(onPressed: _reply,
        icon: const Icon(Icons.reply), label: const Text('Yanıt ekle')),
    ]),
  );
}
