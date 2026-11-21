import 'dart:convert';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:shared_preferences/shared_preferences.dart';

/// Device-only operational preview, not a protected server admin console.
class LocalAdminPreviewPage extends StatefulWidget {
  const LocalAdminPreviewPage({super.key});
  @override
  State<LocalAdminPreviewPage> createState() => _LocalAdminPreviewPageState();
}
class _LocalAdminPreviewPageState extends State<LocalAdminPreviewPage> {
  Map<String, int>? _stats;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      int count(String key) {
        final value = p.getString(key);
        if (value == null) return 0;
        final decoded = jsonDecode(value);
        return decoded is List ? decoded.length : 0;
      }
      if (!mounted) return;
      setState(() { _stats = {
        'Bebeğim forum konuları': count('local_forum_baby_v1'),
        'Kadınlar forum konuları': count('local_forum_women_v1'),
        'Alışveriş listesi kayıtları': count('alisveris'),
        'Favori tarif kayıtları': count('favoriler'),
      }; _error = null; });
    } catch (_) { if (mounted) setState(() => _error = 'Yerel özet okunamadı.'); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Yönetim özeti • Ön izleme'), actions: [IconButton(
      tooltip: t('Yenile'), onPressed: _load, icon: const Icon(Icons.refresh))]),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(color: Color(0xFFFFE6F3), child: Padding(padding: EdgeInsets.all(16), child: Text(
        'Bu ekran yalnızca bu cihazda tutulan bazı kayıtların sayısını gösterir. Gerçek yönetici yetkilendirmesi, merkezi kullanıcılar, moderasyon, gelir ve analitik verileri henüz mevcut değildir.'))),
      if (_error != null) Text(_error!),
      if (_stats == null && _error == null) const Center(child: CircularProgressIndicator()),
      if (_stats != null) for (final e in _stats!.entries) Card(child: ListTile(
        title: Text(e.key), trailing: Text('${e.value}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 16),
      const Text('Üretim ortamında yönetici paneli için ayrı oturum açma, rol bazlı erişim, denetim kayıtları ve sunucu tarafı doğrulama gereklidir.'),
    ]));
}
