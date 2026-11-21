import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/baby_names.dart';
import '../services/mom_tools.dart';
import '../services/secure_health_store.dart';
import '../tracking_journal.dart' show decodeJournal;

const _mor = Color(0xFF764A72);
const _pembe = Color(0xFFFFE3F0);
const _lila = Color(0xFFEDE4FF);

/// Kasılma sayacı, tekme sayacı, emzirme zamanlayıcısı ve isim önerileri.
class MomToolsPage extends StatefulWidget {
  /// 0 kasılma, 1 tekme, 2 emzirme, 3 isimler
  final int initialTab;
  final DateTime Function()? clock;
  const MomToolsPage({super.key, this.initialTab = 0, this.clock});

  static const storageKey = 'mom_tools_v1';
  static const feedingKey = 'baby_feeding_journal_v5';
  static const nameFavoritesKey = 'baby_name_favorites_v1';

  @override
  State<MomToolsPage> createState() => _MomToolsPageState();
}

class _MomToolsPageState extends State<MomToolsPage> {
  MomToolsData _data = const MomToolsData([], [], NursingTimer());
  String? _suggestedSide;
  bool _loading = true;
  Timer? _ticker;
  final _nameSearch = TextEditingController();
  String? _gender;
  String? _initial;
  Set<String> _favorites = {};
  bool _onlyFavorites = false;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _nameSearch.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    MomToolsData data = const MomToolsData([], [], NursingTimer());
    String? side;
    try {
      data = MomToolsData.decode(await SecureHealthStore.read(MomToolsPage.storageKey));
      side = suggestNextSide(decodeJournal(await SecureHealthStore.read(MomToolsPage.feedingKey)));
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    Set<String> fav = {};
    try {
      final raw = jsonDecode(prefs.getString(MomToolsPage.nameFavoritesKey) ?? '[]');
      if (raw is List) fav = raw.whereType<String>().toSet();
    } catch (_) {}
    if (!mounted) return;
    setState(() { _data = data; _suggestedSide = side; _favorites = fav; _loading = false; });
    _syncTicker();
  }

  bool get _anyRunning =>
      _data.nursing.running ||
      (_data.contractions.isNotEmpty && _data.contractions.last.end == null) ||
      (_data.kicks.isNotEmpty && _data.kicks.last.end == null);

  void _syncTicker() {
    if (_anyRunning) {
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  Future<void> _update(MomToolsData next) async {
    setState(() => _data = next);
    _syncTicker();
    try {
      await SecureHealthStore.write(MomToolsPage.storageKey, next.encode());
    } catch (_) {
      if (mounted) _snack('Kayıt cihazda saklanamadı. Lütfen tekrar deneyin.');
    }
  }

  void _snack(String text) {
    final m = ScaffoldMessenger.maybeOf(context);
    m?..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialTab.clamp(0, 3),
      child: Column(children: [
        Material(color: Colors.white, child: const TabBar(
          isScrollable: true, labelColor: _mor, indicatorColor: _mor,
          tabs: [
            Tab(key: Key('tab_kasilma'), text: 'Kasılma'),
            Tab(key: Key('tab_tekme'), text: 'Tekme'),
            Tab(key: Key('tab_emzirme'), text: 'Emzirme'),
            Tab(key: Key('tab_isim'), text: 'İsimler'),
          ])),
        Expanded(child: TabBarView(children: [
          _contractionTab(), _kickTab(), _nursingTab(), _namesTab(),
        ])),
      ]),
    );
  }

  // ---------------- Kasılma ----------------
  Widget _contractionTab() {
    final now = _now();
    final list = _data.contractions;
    final open = list.isNotEmpty && list.last.end == null ? list.last : null;
    final s = summarizeContractions(list, now);
    String dur(Duration? d) => d == null ? '—' : formatClock(d.inSeconds);
    final history = list.reversed.take(30).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      _infoCard('Kasılma sayacı',
          'Kasılma başlayınca “Başladı”ya, geçince “Bitti”ye dokun. Süreyi ve '
          'iki kasılma arasını uygulama hesaplar.'),
      const SizedBox(height: 12),
      Center(child: Text(open == null ? '00:00' : formatClock(now.difference(open.start).inSeconds),
          key: const Key('kasilma_sure'),
          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: _mor))),
      const SizedBox(height: 8),
      Center(child: FilledButton.icon(
        key: const Key('kasilma_dugme'),
        style: FilledButton.styleFrom(backgroundColor: open == null ? _mor : Colors.redAccent,
            minimumSize: const Size(220, 54)),
        icon: Icon(open == null ? Icons.play_arrow_rounded : Icons.stop_rounded),
        label: Text(open == null ? 'Kasılma başladı' : 'Kasılma bitti'),
        onPressed: () {
          final t = _now();
          final next = [...list];
          if (open == null) {
            next.add(Contraction(t));
          } else {
            next[next.length - 1] = Contraction(open.start, t);
          }
          _update(MomToolsData(next, _data.kicks, _data.nursing));
        },
      )),
      const SizedBox(height: 14),
      Row(children: [
        _stat('Son 1 saat', '${s.countLastHour}'),
        _stat('Ort. süre', dur(s.averageDuration)),
        _stat('Ort. aralık', dur(s.averageInterval)),
      ]),
      if (s.fiveOneOne) ...[
        const SizedBox(height: 12),
        Card(key: const Key('kasilma_511'), color: const Color(0xFFFFE0E0), child: const ListTile(
          leading: Icon(Icons.local_hospital_rounded, color: Colors.redAccent),
          title: Text('5-1-1 örüntüsü', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('Son bir saattir kasılmalar 5 dakikada bir geliyor ve en az 1 dakika sürüyor. '
              'Doktorunu ya da doğum yapacağın hastaneyi ara; sana söylenen plana göre yola çık.'),
        )),
      ],
      const SizedBox(height: 8),
      _warning('Suyun gelmesi, kanama, şiddetli ve geçmeyen ağrı, bebek hareketlerinde azalma '
          'ya da 37. haftadan önce düzenli kasılma varsa beklemeden 112’yi ara veya hastaneye git.'),
      if (history.isNotEmpty) ...[
        Row(children: [
          const Expanded(child: Text('Kayıtlar', style: TextStyle(fontWeight: FontWeight.w700, color: _mor))),
          TextButton(onPressed: () => _confirmClear('Tüm kasılma kayıtları silinsin mi?',
              () => _update(MomToolsData(const [], _data.kicks, _data.nursing))),
              child: const Text('Temizle')),
        ]),
        for (var i = 0; i < history.length; i++)
          Card(child: ListTile(dense: true,
            title: Text('${_hm(history[i].start)}  •  ${history[i].end == null ? 'sürüyor' : formatClock(history[i].duration!.inSeconds)}'),
            subtitle: i + 1 < history.length
                ? Text('Önceki kasılmadan ${formatClock(history[i].start.difference(history[i + 1].start).inSeconds)} sonra')
                : null)),
      ],
    ]);
  }

  // ---------------- Tekme ----------------
  Widget _kickTab() {
    final now = _now();
    final list = _data.kicks;
    final open = list.isNotEmpty && list.last.end == null ? list.last : null;
    final status = open == null ? null : kickStatus(open, now);
    return ListView(padding: const EdgeInsets.all(16), children: [
      _infoCard('Tekme (hareket) sayacı',
          '28. haftadan sonra, bebeğin genelde hareketli olduğu bir saatte yan yatarak '
          'başla. Her tekme, dönme ya da kıpırtıda dokun; 10 harekete kaç dakikada '
          'ulaştığını görürsün.'),
      const SizedBox(height: 12),
      if (open == null)
        Center(child: FilledButton.icon(key: const Key('tekme_basla'),
          style: FilledButton.styleFrom(backgroundColor: _mor, minimumSize: const Size(220, 54)),
          icon: const Icon(Icons.play_arrow_rounded), label: const Text('Saymaya başla'),
          onPressed: () => _update(MomToolsData(_data.contractions, [...list, KickSession(_now())], _data.nursing))))
      else ...[
        Center(child: Text('${open.count} / $kickTarget', key: const Key('tekme_sayi'),
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: _mor))),
        Center(child: Text('Geçen süre: ${formatClock(now.difference(open.start).inSeconds)}')),
        const SizedBox(height: 10),
        Center(child: SizedBox(width: 150, height: 150, child: ElevatedButton(
          key: const Key('tekme_dokun'),
          style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: _pembe,
              foregroundColor: _mor),
          onPressed: () {
            final next = [...list];
            var s = open.kick();
            if (s.count >= kickTarget) s = s.finish(_now());
            next[next.length - 1] = s;
            _update(MomToolsData(_data.contractions, next, _data.nursing));
            if (s.end != null) _snack('10 harekete ${formatClock(s.end!.difference(s.start).inSeconds)} içinde ulaştın.');
          },
          child: const Text('👣\nHareket', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
        ))),
        const SizedBox(height: 8),
        Center(child: TextButton(onPressed: () {
          final next = [...list];
          next[next.length - 1] = open.finish(_now());
          _update(MomToolsData(_data.contractions, next, _data.nursing));
        }, child: const Text('Oturumu bitir'))),
        if (status == KickStatus.overdue)
          Card(key: const Key('tekme_uyari'), color: const Color(0xFFFFE0E0), child: const ListTile(
            leading: Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            title: Text('2 saatte 10 hareket sayılmadı'),
            subtitle: Text('Bekleme; doktorunu ya da doğumhaneyi hemen ara.'))),
      ],
      const SizedBox(height: 8),
      _warning('Bebeğin hareketleri her zamankinden belirgin azaldıysa ya da değiştiyse sayacı '
          'beklemeden doktorunu veya doğumhaneyi ara.'),
      if (list.any((k) => k.end != null)) ...[
        const Text('Önceki oturumlar', style: TextStyle(fontWeight: FontWeight.w700, color: _mor)),
        ...list.where((k) => k.end != null).toList().reversed.take(20).map((k) => Card(child: ListTile(dense: true,
          leading: Icon(k.count >= kickTarget ? Icons.check_circle_rounded : Icons.timelapse_rounded,
              color: k.count >= kickTarget ? Colors.green : Colors.orange),
          title: Text('${_dm(k.start)} ${_hm(k.start)}  •  ${k.count} hareket'),
          subtitle: Text('Süre ${formatClock(k.end!.difference(k.start).inSeconds)}')))),
      ],
    ]);
  }

  // ---------------- Emzirme ----------------
  Widget _nursingTab() {
    final now = _now();
    final n = _data.nursing;
    Widget sideButton(String side) {
      final active = n.activeSide == side;
      return Expanded(child: Padding(padding: const EdgeInsets.all(6), child: SizedBox(height: 130,
        child: ElevatedButton(
          key: Key('emzirme_${side == 'Sol' ? 'sol' : 'sag'}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: active ? _mor : (side == 'Sol' ? _pembe : _lila),
            foregroundColor: active ? Colors.white : _mor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
          onPressed: () => _update(MomToolsData(_data.contractions, _data.kicks, n.toggle(side, _now()))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(side, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(formatClock(n.secondsFor(side, now)), style: const TextStyle(fontSize: 26)),
            Text(active ? 'durdurmak için dokun' : 'başlatmak için dokun', style: const TextStyle(fontSize: 11)),
          ]),
        ))));
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      _infoCard('Emzirme zamanlayıcısı',
          'Emzirdiğin tarafa dokun; taraf değiştirince diğerine dokunman yeter. Bitirince '
          'kayıt beslenme günlüğüne eklenir.'),
      if (_suggestedSide != null && n.isEmpty) Padding(padding: const EdgeInsets.only(top: 10),
        child: Text('Sıradaki önerilen taraf: $_suggestedSide', key: const Key('emzirme_oneri'),
            textAlign: TextAlign.center, style: const TextStyle(color: _mor, fontWeight: FontWeight.w600))),
      const SizedBox(height: 10),
      Row(children: [sideButton('Sol'), sideButton('Sağ')]),
      Center(child: Text('Toplam ${formatClock(n.totalSeconds(now))}', key: const Key('emzirme_toplam'),
          style: const TextStyle(fontSize: 18, color: _mor, fontWeight: FontWeight.w700))),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        OutlinedButton(onPressed: n.isEmpty ? null : () => _confirmClear('Bu oturum kaydedilmeden silinsin mi?',
            () => _update(MomToolsData(_data.contractions, _data.kicks, const NursingTimer()))),
            child: const Text('Sıfırla')),
        const SizedBox(width: 12),
        FilledButton.icon(key: const Key('emzirme_kaydet'),
          style: FilledButton.styleFrom(backgroundColor: _mor),
          onPressed: n.isEmpty ? null : _saveNursing,
          icon: const Icon(Icons.save_rounded), label: const Text('Bitir ve kaydet')),
      ]),
      const SizedBox(height: 14),
      _warning('Bebeğin günde 6’dan az ıslak bezi varsa, çok uykulu ve emmek istemiyorsa, '
          'sarılığı artıyorsa ya da memende kızarıklık, ateş ve ağrı varsa doktoruna başvur.'),
    ]);
  }

  Future<void> _saveNursing() async {
    final entry = _data.nursing.toJournalEntry(_now());
    if (entry == null) {
      _snack('30 saniyeden kısa oturum kaydedilmedi.');
      return;
    }
    try {
      final journal = decodeJournal(await SecureHealthStore.read(MomToolsPage.feedingKey));
      journal.insert(0, entry);
      journal.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      await SecureHealthStore.write(MomToolsPage.feedingKey, jsonEncode(journal));
    } catch (_) {
      _snack('Kayıt beslenme günlüğüne yazılamadı. Zamanlayıcı korunuyor.');
      return;
    }
    if (!mounted) return;
    setState(() => _suggestedSide = suggestNextSide([entry]));
    await _update(MomToolsData(_data.contractions, _data.kicks, const NursingTimer()));
    _snack('Beslenme günlüğüne eklendi: ${entry['amount']} dk, ${entry['side']}.');
  }

  // ---------------- İsimler ----------------
  Widget _namesTab() {
    var names = searchBabyNames(_nameSearch.text, gender: _gender, initial: _initial);
    if (_onlyFavorites) names = names.where((n) => _favorites.contains(n.name)).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: TextField(
        key: const Key('isim_ara'), controller: _nameSearch,
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'İsim ya da anlam ara',
            border: OutlineInputBorder()),
        onChanged: (_) => setState(() {}))),
      SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          for (final (label, value) in [('Hepsi', null), ('Kız', 'K'), ('Erkek', 'E')])
            Padding(padding: const EdgeInsets.all(4), child: ChoiceChip(label: Text(label),
                selected: _gender == value, onSelected: (_) => setState(() => _gender = value))),
          Padding(padding: const EdgeInsets.all(4), child: FilterChip(
            key: const Key('isim_favoriler'),
            avatar: const Icon(Icons.favorite, size: 16, color: Colors.pink),
            label: Text('Favoriler (${_favorites.length})'), selected: _onlyFavorites,
            onSelected: (v) => setState(() => _onlyFavorites = v))),
        ])),
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12), children: [
          for (final letter in const ['A','B','C','Ç','D','E','F','G','H','I','İ','K','L','M','N','O','Ö','P','R','S','Ş','T','U','Ü','V','Y','Z'])
            Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: ChoiceChip(
              key: Key('isim_harf_$letter'), visualDensity: VisualDensity.compact,
              label: Text(letter), selected: _initial == letter,
              onSelected: (v) => setState(() => _initial = v ? letter : null))),
        ])),
      Padding(padding: const EdgeInsets.only(top: 4), child: Text('${names.length} isim',
          key: const Key('isim_sayisi'), style: const TextStyle(fontSize: 12, color: Colors.black54))),
      Expanded(child: names.isEmpty
          ? const Center(child: Text('Eşleşen isim bulunamadı.'))
          : ListView.builder(itemCount: names.length, itemBuilder: (_, i) {
              final n = names[i];
              final fav = _favorites.contains(n.name);
              return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(
                leading: CircleAvatar(backgroundColor: n.gender == 'K' ? _pembe : n.gender == 'E' ? const Color(0xFFDDEBFF) : _lila,
                    child: Text(n.name.characters.first, style: const TextStyle(color: _mor, fontWeight: FontWeight.w700))),
                title: Text(n.name),
                subtitle: Text('${n.meaning} • ${n.origin}'),
                trailing: IconButton(key: Key('isim_fav_${n.name}'),
                  tooltip: fav ? 'Favorilerden çıkar' : 'Favorilere ekle',
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: Colors.pink),
                  onPressed: () => _toggleFavorite(n.name)),
              ));
            })),
    ]);
  }

  Future<void> _toggleFavorite(String name) async {
    setState(() => _favorites.contains(name) ? _favorites.remove(name) : _favorites.add(name));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(MomToolsPage.nameFavoritesKey, jsonEncode(_favorites.toList()..sort()));
  }

  // ---------------- Ortak ----------------
  Widget _infoCard(String title, String body) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [_pembe, _lila])),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _mor)),
      const SizedBox(height: 4),
      Text(body, style: const TextStyle(color: _mor, fontSize: 13)),
    ]));

  Widget _stat(String label, String value) => Expanded(child: Card(child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _mor)),
      Text(label, style: const TextStyle(fontSize: 11.5)),
    ]))));

  Widget _warning(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.info_outline_rounded, size: 18, color: Colors.redAccent),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87))),
    ]));

  Future<void> _confirmClear(String question, VoidCallback onYes) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(question), content: const Text('Bu işlem geri alınamaz.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (ok == true && mounted) onYes();
  }

  String _hm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  String _dm(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
}
