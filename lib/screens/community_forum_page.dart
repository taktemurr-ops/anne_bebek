import '../utils/dialog_helpers.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'dart:convert';
import 'package:flutter/material.dart' hide Text;
import 'package:shared_preferences/shared_preferences.dart';

/// Offline forum prototype. A production multi-user forum requires an API,
/// authenticated identities, server-side moderation and privacy controls.
class CommunityForumPage extends StatefulWidget {
  final String community;
  const CommunityForumPage({super.key, required this.community});
  @override
  State<CommunityForumPage> createState() => _CommunityForumPageState();
}

class _CommunityForumPageState extends State<CommunityForumPage> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _posts = [];
  String _category = 'Tümü';
  bool _loading = true;
  List<String> get _categories => widget.community == 'Bebeğim'
      ? ['Tümü', 'Yenidoğan', 'Beslenme', 'Uyku', 'Gelişim', 'Sağlık', 'Genel']
      : ['Tümü', 'Kadın Sağlığı', 'Gebelik', 'Annelik', 'Bakım', 'İlişkiler', 'Genel'];
  String get _key => 'local_forum_${widget.community == 'Bebeğim' ? 'baby' : 'women'}_v1';

  @override
  void initState() { super.initState(); _load(); _search.addListener(_refresh); }
  void _refresh() { if (mounted) setState(() {}); }
  @override
  void dispose() { _search.removeListener(_refresh); _search.dispose(); super.dispose(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (!mounted) return;
    try {
      final decoded = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
      setState(() { _posts = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList(); _loading = false; });
    } catch (_) { setState(() { _posts = []; _loading = false; }); }
  }
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_posts));
  }
  Future<String?> _ask(String title, {int maxLines = 1}) async {
    final controller = TextEditingController();
    final result = await showDialogAndDispose<String>(disposables: [controller], context: context, builder: (ctx) => AlertDialog(
      title: Text(title), content: TextField(controller: controller, autofocus: true,
        maxLines: maxLines, maxLength: maxLines == 1 ? 100 : 2000,
        decoration: InputDecoration(hintText: t('Buraya yazın'))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Devam'))],
    ));
    return result == null || result.isEmpty ? null : result;
  }
  Future<void> _newPost() async {
    final title = await _ask('Konu başlığı');
    if (!mounted || title == null) return;
    final body = await _ask('Konunuzu yazın', maxLines: 5);
    if (!mounted || body == null) return;
    final category = await showDialog<String>(context: context, builder: (ctx) => SimpleDialog(
      title: const Text('Kategori seçin'), children: _categories.skip(1).map((c) =>
        SimpleDialogOption(onPressed: () => Navigator.pop(ctx, c), child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7), child: Text(c)))).toList()));
    if (!mounted || category == null) return;
    setState(() => _posts.insert(0, {
      'id': DateTime.now().microsecondsSinceEpoch.toString(), 'title': title,
      'body': body, 'category': category, 'created': DateTime.now().toIso8601String(),
      'replies': <Map<String, String>>[],
    }));
    await _save();
  }
  Future<void> _reply(Map<String, dynamic> post) async {
    final message = await _ask('Yanıt yazın', maxLines: 4);
    if (!mounted || message == null) return;
    setState(() {
      final replies = (post['replies'] as List).map((e) => Map<String, String>.from(e as Map)).toList();
      replies.add({'message': message, 'created': DateTime.now().toIso8601String()});
      post['replies'] = replies;
    });
    await _save();
  }
  Future<void> _delete(Map<String, dynamic> post) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Konuyu sil?'), content: const Text('Konu ve yanıtlar bu cihazdan silinecek.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (confirmed != true || !mounted) return;
    setState(() => _posts.removeWhere((p) => p['id'] == post['id']));
    await _save();
  }
  void _open(Map<String, dynamic> post) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => StatefulBuilder(
      builder: (ctx, refresh) => Scaffold(appBar: AppBar(title: const Text('Konu detayları')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Text(post['category'] as String, style: const TextStyle(color: Color(0xFF9D3979))),
          const SizedBox(height: 8), Text(post['title'] as String,
            style: Theme.of(ctx).textTheme.headlineSmall), const SizedBox(height: 12),
          Text(post['body'] as String), const Divider(height: 36),
          Text('Yanıtlar (${(post['replies'] as List).length})', style: Theme.of(ctx).textTheme.titleMedium),
          for (final reply in post['replies'] as List) Card(child: ListTile(
            leading: const Icon(Icons.chat_bubble_outline), title: Text(reply['message'] as String))),
          const SizedBox(height: 12), FilledButton.icon(onPressed: () async {
            await _reply(post); if (ctx.mounted) refresh(() {});
          }, icon: const Icon(Icons.reply), label: const Text('Yanıt ekle')),
        ])) )));
  }
  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase().trim();
    final visible = _posts.where((p) => (_category == 'Tümü' || p['category'] == _category) &&
      ('${p['title']} ${p['body']}').toLowerCase().contains(query)).toList();
    return Scaffold(appBar: AppBar(title: Text('${widget.community} • Topluluk')),
      floatingActionButton: FloatingActionButton.extended(onPressed: _newPost,
        icon: const Icon(Icons.edit_outlined), label: const Text('Konu aç')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16), children: [
          Card(color: const Color(0xFFFFE5F2), child: const Padding(
            padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Topluluk alanı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 6), Text('Bu sürüm çevrimdışı bir forum taslağıdır. Konular yalnızca bu cihazda görünür. Diğer kullanıcılarla paylaşım henüz aktif değildir.'),
              SizedBox(height: 6), Text('Kişisel sağlık bilgilerinizi ve çocukların özel bilgilerini paylaşmayın.', style: TextStyle(fontSize: 12)),
            ]))),
          const SizedBox(height: 10),
          TextField(controller: _search, decoration: InputDecoration(
            prefixIcon: Icon(Icons.search), hintText: t('Konularda ara...'))),
          const SizedBox(height: 10), SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal,
            children: _categories.map((c) => Padding(padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(label: Text(c), selected: _category == c,
                onSelected: (_) => setState(() => _category = c)))).toList())),
          const SizedBox(height: 10),
          if (visible.isEmpty) const Padding(padding: EdgeInsets.all(24),
            child: Center(child: Text('Henüz konu yok. İlk konuyu siz oluşturabilirsiniz.'))),
          for (final post in visible) Card(child: ListTile(
            title: Text(post['title'] as String, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('${post['category']} • ${(post['replies'] as List).length} yanıt'),
            leading: const Icon(Icons.forum_outlined, color: Color(0xFFB83D85)),
            onTap: () => _open(post),
            trailing: IconButton(tooltip: t('Konuyu sil'), icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(post)),
          )), const SizedBox(height: 90),
        ]));
  }
}
