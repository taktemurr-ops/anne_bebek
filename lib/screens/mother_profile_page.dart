import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/secure_health_store.dart';

const _mor = Color(0xFF764A72);

/// Annenin kendi profili ve acil durum bilgileri (kan grubu, alerji, doktor, yakınlar).
class MotherProfile {
  static const storageKey = 'mother_profile_v1';
  static const fields = <(String, String, TextInputType)>[
    ('name', 'Adım', TextInputType.name),
    ('blood', 'Kan grubum (ör. A Rh+)', TextInputType.text),
    ('allergies', 'Alerjilerim', TextInputType.text),
    ('conditions', 'Kronik hastalıklarım', TextInputType.text),
    ('meds', 'Düzenli kullandığım ilaçlar', TextInputType.text),
    ('doctor', 'Doktorum', TextInputType.name),
    ('doctorPhone', 'Doktor telefonu', TextInputType.phone),
    ('hospital', 'Hastanem / doğum yapacağım yer', TextInputType.text),
    ('contact1', 'Acil durumda aranacak kişi', TextInputType.name),
    ('contact1Phone', 'Telefonu', TextInputType.phone),
    ('contact2', 'İkinci kişi', TextInputType.name),
    ('contact2Phone', 'Telefonu', TextInputType.phone),
    ('notes', 'Diğer notlar (sigorta, özel durum)', TextInputType.multiline),
  ];

  final Map<String, String> values;
  final DateTime? birth;
  const MotherProfile(this.values, this.birth);

  int? ageAt(DateTime now) {
    final b = birth;
    if (b == null) return null;
    var a = now.year - b.year;
    if (now.month < b.month || (now.month == b.month && now.day < b.day)) a--;
    return a;
  }

  String encode() => jsonEncode({...values, if (birth != null) 'birth': birth!.toIso8601String()});

  static MotherProfile decode(String? raw) {
    if (raw == null || raw.isEmpty) return const MotherProfile({}, null);
    try {
      final d = jsonDecode(raw);
      if (d is! Map) return const MotherProfile({}, null);
      final v = <String, String>{};
      for (final f in fields) {
        final x = d[f.$1];
        if (x is String && x.trim().isNotEmpty) v[f.$1] = x.trim();
      }
      final b = DateTime.tryParse('${d['birth']}');
      return MotherProfile(v, b != null && b.year > 1900 ? b : null);
    } catch (_) {
      return const MotherProfile({}, null);
    }
  }

  static Future<MotherProfile> load() async {
    try {
      return decode(await SecureHealthStore.read(storageKey));
    } catch (_) {
      return const MotherProfile({}, null);
    }
  }
}

class MotherProfilePage extends StatefulWidget {
  const MotherProfilePage({super.key});
  @override
  State<MotherProfilePage> createState() => _MotherProfilePageState();
}

class _MotherProfilePageState extends State<MotherProfilePage> {
  final _c = {for (final f in MotherProfile.fields) f.$1: TextEditingController()};
  DateTime? _birth;
  bool _loading = true;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final p = await MotherProfile.load();
    if (!mounted) return;
    setState(() {
      for (final e in p.values.entries) {
        _c[e.key]!.text = e.value;
      }
      _birth = p.birth;
      _loading = false;
      _editing = p.values.isEmpty;
    });
  }

  Future<void> _save() async {
    final p = MotherProfile({for (final e in _c.entries) if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim()}, _birth);
    try {
      await SecureHealthStore.write(MotherProfile.storageKey, p.encode());
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil kaydedildi.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydedilemedi. Tekrar deneyin.')));
    }
  }

  String _f(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return _editing ? _form() : _card();
  }

  Widget _form() => ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Bu bilgiler yalnızca bu telefonda, şifreli olarak saklanır. Acil durumda yakınların ya da sağlık '
            'personeli için hızlıca gösterebilirsin.', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
        const SizedBox(height: 8),
        for (final f in MotherProfile.fields) ...[
          TextField(key: Key('profil_${f.$1}'), controller: _c[f.$1], keyboardType: f.$3,
              maxLines: f.$3 == TextInputType.multiline ? 3 : 1, maxLength: f.$3 == TextInputType.multiline ? 500 : 80,
              decoration: InputDecoration(labelText: f.$2, counterText: '')),
          if (f.$1 == 'name') ListTile(contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cake_outlined, color: _mor),
            title: Text(_birth == null ? 'Doğum tarihim (yaşa uygun kontroller için)' : 'Doğum tarihim: ${_f(_birth!)}'),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _birth ?? DateTime(1995),
                  firstDate: DateTime(1930), lastDate: DateTime.now());
              if (d != null) setState(() => _birth = d);
            }),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(key: const Key('profil_kaydet'), style: FilledButton.styleFrom(backgroundColor: _mor),
            onPressed: _save, icon: const Icon(Icons.save_rounded), label: const Text('Kaydet')),
      ]);

  Widget _card() {
    final rows = <(String, String)>[
      for (final f in MotherProfile.fields)
        if (_c[f.$1]!.text.trim().isNotEmpty && f.$1 != 'name') (f.$2, _c[f.$1]!.text.trim()),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: const Color(0xFFFFE0E0),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.emergency_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(child: Text(_c['name']!.text.isEmpty ? 'Acil durum kartım' : _c['name']!.text,
                key: const Key('profil_kart_ad'),
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
          ]),
          if (_birth != null) Text('Doğum tarihi: ${_f(_birth!)}'),
          const Divider(),
          for (final (label, value) in rows) Padding(padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54))),
              Expanded(child: SelectableText(value, style: const TextStyle(fontWeight: FontWeight.w600))),
              if (label.contains('elefon')) IconButton(visualDensity: VisualDensity.compact, tooltip: 'Kopyala',
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () => Clipboard.setData(ClipboardData(text: value))),
            ])),
        ])),
      const SizedBox(height: 10),
      const Card(child: ListTile(leading: Icon(Icons.local_hospital_rounded, color: Colors.redAccent),
          title: Text('Acil durumda 112’yi ara'),
          subtitle: Text('Bu kartı sağlık personeline gösterebilirsin.'))),
      OutlinedButton.icon(key: const Key('profil_duzenle'), onPressed: () => setState(() => _editing = true),
          icon: const Icon(Icons.edit_outlined), label: const Text('Düzenle')),
    ]);
  }
}
