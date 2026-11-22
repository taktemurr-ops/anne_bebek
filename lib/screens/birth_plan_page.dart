import 'dart:async';

import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/birth_plan.dart';
import '../services/json_store.dart';
import '../services/text_share.dart';
import '../widgets/module_kit.dart';

/// Doğum planı hazırlayıcı: tercihleri seç, ekiple paylaş.
class BirthPlanPage extends StatefulWidget {
  static const storageKey = 'birth_plan_v1';
  final String motherName;
  const BirthPlanPage({super.key, this.motherName = ''});

  @override
  State<BirthPlanPage> createState() => _BirthPlanPageState();
}

class _BirthPlanPageState extends State<BirthPlanPage> {
  BirthPlan _plan = const BirthPlan();
  final _controllers = <String, TextEditingController>{};
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (!_loading) unawaited(_persist());
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    Map<String, dynamic> raw = {};
    try { raw = await JsonStore.readMap(BirthPlanPage.storageKey); } catch (_) {}
    final plan = BirthPlan.fromJson(raw);
    for (final s in birthPlanSections.where((s) => s.freeText)) {
      _controllers[s.id] = TextEditingController(text: plan.texts[s.id] ?? '')
        ..addListener(() {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 600), () => unawaited(_persist()));
        });
    }
    if (mounted) setState(() { _plan = plan; _loading = false; });
  }

  BirthPlan _current() => BirthPlan(choices: _plan.choices, texts: {
        for (final e in _controllers.entries)
          if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim(),
      });

  Future<void> _persist() async {
    try {
      await JsonStore.writeMap(BirthPlanPage.storageKey, _current().toJson());
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  void _toggle(String section, String option) {
    final choices = {for (final e in _plan.choices.entries) e.key: {...e.value}};
    final set = choices.putIfAbsent(section, () => <String>{});
    set.contains(option) ? set.remove(option) : set.add(option);
    if (set.isEmpty) choices.remove(section);
    setState(() => _plan = BirthPlan(choices: choices, texts: _plan.texts));
    unawaited(_persist());
  }

  Future<void> _share() async {
    final text = _current().render(t, name: widget.motherName);
    try {
      await TextShare.share(text, subject: t('Doğum planım'));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) kitSnack(context, 'Paylaşım açılamadı; plan panoya kopyalandı.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitNote(
        'Doğum planı, ekibine neyin senin için önemli olduğunu anlatır. 32–36. haftalar arasında hazırlayıp doktorun ve ebenle konuş. '
        'Doğum her zaman plana göre gitmeyebilir; esnek olmak seni rahatlatır.'),
      for (final s in birthPlanSections) ...[
        KitHeader(s.title, Icons.checklist_rounded),
        if (s.freeText)
          TextField(key: Key('plan_${s.id}'), controller: _controllers[s.id], minLines: 1, maxLines: 4,
              decoration: InputDecoration(border: const OutlineInputBorder(), hintText: t('Yaz…')))
        else
          Wrap(spacing: 6, runSpacing: 4, children: [
            for (final o in s.options)
              FilterChip(key: Key('plan_${s.id}_${s.options.indexOf(o)}'), label: Text(o, style: const TextStyle(fontSize: 12.5)),
                  selected: _plan.choices[s.id]?.contains(o) ?? false, onSelected: (_) => _toggle(s.id, o)),
          ]),
      ],
      const SizedBox(height: 16),
      FilledButton.icon(key: const Key('plan_paylas'), onPressed: _share, icon: const Icon(Icons.share_outlined), label: Text('Planı paylaş')),
      const SizedBox(height: 6),
      OutlinedButton.icon(onPressed: () async {
        await Clipboard.setData(ClipboardData(text: _current().render(t, name: widget.motherName)));
        if (context.mounted) kitSnack(context, 'Plan panoya kopyalandı.');
      }, icon: const Icon(Icons.copy), label: Text('Kopyala')),
      const KitFootnote('Paylaş düğmesiyle planı WhatsApp, e-posta ya da yazdırma uygulamasına gönderebilirsin. Hastaneye giderken bir çıktısını çantana koy.'),
    ]);
  }
}
