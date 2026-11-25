import 'dart:convert';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modül bazında manuel kabul testleri; gerçek cihaz/derleme testi yerine geçmez.
class ProjectCompletionCenterPage extends StatefulWidget {
  const ProjectCompletionCenterPage({super.key});
  @override
  State<ProjectCompletionCenterPage> createState() => _ProjectCompletionCenterPageState();
}

class _ProjectCompletionCenterPageState extends State<ProjectCompletionCenterPage> {
  static const _key = 'anne_bebek_completion_center_v1';
  static const _purple = Color(0xFF48235F);
  static const _groups = <String, List<String>>{
    'Bebek ve çocuk': [
      'Profil oluşturma, düzenleme ve silme akışları',
      'Büyüme kayıtları ve grafiklerin doğrulanması',
      'Beslenme ve uyku geçmişi',
      'Sağlık kayıtları ve aşı bilgilendirmeleri',
      'Çocuk günlüğü ve bakım planı',
      'Yaşa uygun içerik ve rehberler',
    ],
    'Kadın sağlığı': [
      'Kadın sağlığı günlüğü veri kalıcılığı',
      'Doğum sonrası bakım ekranları',
      'Kadın yaşam modülü geçişleri',
      'Sağlık içeriklerinde tıbbi uyarılar',
    ],
    'Mutfak ve alışveriş': [
      'Alışveriş listesi oluşturma ve tamamlama',
      'Bütçe ve harcama hesapları',
      'Stok hareketi ve SKT işlemleri',
      'Haftalık yemek planı',
      'Tarif arama, favori ve listeye ekleme',
      'Kapasite ve görev önerileri',
      'Onaylı görev değişikliklerinin geçmişi',
    ],
    'Topluluk ve yapay zekâ': [
      'Bebek forumu bağlantısı ve erişim politikaları',
      'Kadın forumu bağlantısı ve erişim politikaları',
      'Şikâyet ve içerik güvenliği',
      'AI asistanı bağlantısı ve hata durumları',
      'AI sağlık yanıtlarında güvenli yönlendirme',
    ],
    'Hesap, yedek ve güvenlik': [
      'Hesap ve üyelik akışları',
      'Yedek oluşturma ve test verisiyle geri yükleme',
      'Hassas verilerin dışa aktarım kontrolleri',
      'Çevrimdışı kullanım',
      'Uygulama güncellemesinde veri korunması',
    ],
    'Yayın ve kalite': [
      'Flutter analyze temiz',
      'Flutter test başarılı',
      'Android gerçek cihaz testi',
      'iOS gerçek cihaz/TestFlight testi',
      'Erişilebilirlik ve büyük yazı testi',
      'Gizlilik, izinler ve mağaza beyanları',
      'Release AAB/APK ve imzalama',
      'Çökme, performans ve açılış testi',
    ],
  };
  final Set<String> _done = {};
  String _filter = 'Tümü';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final allowed = _groups.entries.expand((e) =>
              e.value.map((item) => '${e.key}::$item')).toSet();
          _done.addAll(decoded.map((e) => e.toString()).where(allowed.contains));
        }
      }
    } catch (_) {
      // Bozuk kontrol listesi verisi diğer uygulama kayıtlarını etkilemez.
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggle(String id, bool value) async {
    if (_saving) return;
    final old = Set<String>.of(_done);
    setState(() {
      _saving = true;
      if (value) { _done.add(id); } else { _done.remove(id); }
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setString(_key, jsonEncode(_done.toList()..sort()));
      if (!ok) throw StateError('Kaydetme başarısız');
    } catch (_) {
      if (mounted) {
        setState(() { _done..clear()..addAll(old); });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kontrol kaydedilemedi.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _export() async {
    final rows = <String>['"Modül","Kontrol","Durum"'];
    String cell(String s) => '"${s.replaceAll('"', '""')}"';
    for (final group in _groups.entries) {
      for (final item in group.value) {
        rows.add([group.key, item,
          _done.contains('${group.key}::$item') ? 'Tamamlandı' : 'Bekliyor']
            .map(cell).join(','));
      }
    }
    await Clipboard.setData(ClipboardData(text: '\uFEFF${rows.join('\r\n')}'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kontrol raporu CSV olarak panoya kopyalandı.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _groups.values.fold<int>(0, (sum, list) => sum + list.length);
    final ratio = total == 0 ? 0.0 : _done.length / total;
    final visible = _groups.entries.where(
      (entry) => _filter == 'Tümü' || entry.key == _filter);
    return Scaffold(
      appBar: AppBar(title: const Text('Proje Tamamlama Merkezi')),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
        Card(color: const Color(0xFFFFF7FC), child: Padding(
          padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Modül bazlı kabul kontrolü',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _purple)),
            const SizedBox(height: 8),
            Text('${_done.length} / $total kontrol işaretlendi'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: ratio),
            const SizedBox(height: 8),
            const Text('Bu oran yalnızca manuel işaretlenen maddeleri gösterir; '
              'kodun çalıştığını veya mağaza onayını doğrulamaz.',
              style: TextStyle(fontSize: 12)),
          ]))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(isExpanded: true, 
          initialValue: _filter,
          decoration: InputDecoration(labelText: t('Modül filtresi'),
            border: OutlineInputBorder()),
          items: ['Tümü', ..._groups.keys].map(
            (name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
          onChanged: (value) => setState(() => _filter = value ?? 'Tümü'),
        ),
        const SizedBox(height: 8),
        for (final entry in visible)
          Card(child: ExpansionTile(
            title: Text(entry.key),
            subtitle: Text('${entry.value.where((item) =>
              _done.contains('${entry.key}::$item')).length}/${entry.value.length} tamamlandı'),
            children: [
              for (final item in entry.value)
                CheckboxListTile(
                  title: Text(item),
                  value: _done.contains('${entry.key}::$item'),
                  onChanged: _saving ? null : (value) =>
                    _toggle('${entry.key}::$item', value ?? false),
                ),
            ],
          )),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _export,
          icon: const Icon(Icons.table_chart_outlined),
          label: const Text('Tüm kontrol listesini CSV kopyala')),
        const SizedBox(height: 12),
        const Text('Not: Sağlık ve çocuk verileri üzerinde test yapmadan önce '
          'yedek alın. Kontrolleri yalnızca gerçekten doğruladığınızda işaretleyin.'),
      ]),
    );
  }
}
