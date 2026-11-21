import '../services/offline_assistant.dart';
import '../services/secure_health_store.dart';
import '../utils/ai_request_guard.dart';
import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});
  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final _question = TextEditingController();
  bool _consent = false;
  bool _busy = false;
  String? _answer;
  String? _error;

  @override
  void dispose() { _question.dispose(); super.dispose(); }

  Future<void> _ask() async {
    if (_busy) return;
    final validation = AiRequestGuard.validate(
      prompt: _question.text,
      consentToExternalProcessing: _consent,
      maxCharacters: 1200,
    );
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
    setState(() { _busy = true; _answer = null; _error = null; });
    try {
      final result = await AiAssistantService.ask(AiRequestGuard.maskContactDetails(_question.text.trim()));
      if (mounted) setState(() => _answer = result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Bad state: ', '').replaceFirst('Invalid argument(s): ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AiAssistantService.configured) return const OfflineAssistantView();
    return Scaffold(
    appBar: AppBar(title: const Text('AI Bilgi Asistanı')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(color: Color(0xFFFFE6F3), child: Padding(padding: EdgeInsets.all(16), child: Text(
        'AI yanıtları hatalı olabilir. Tanı, ilaç, tedavi veya acil sağlık kararları için kullanılmaz. Acil durumda 112’yi arayın.'))),
      const SizedBox(height: 12),
      const Text('Bebek bakımı, gebelik, yemek planlama veya uygulamanın kullanımı hakkında genel bir soru sorabilirsiniz.'),
      const SizedBox(height: 12),
      TextField(controller: _question, minLines: 3, maxLines: 6, maxLength: 1200,
        decoration: const InputDecoration(labelText: 'Sorunuz', hintText: 'Örn. 8 aylık bebek için güvenli oyun önerileri nelerdir?')),
      CheckboxListTile(value: _consent, onChanged: _busy ? null : (v) => setState(() => _consent = v ?? false),
        title: const Text('Sorumu AI hizmetine göndermeyi kabul ediyorum.'),
        subtitle: const Text('Yazdığınız soru gönderilir. E-posta ve telefon numaraları otomatik maskelenir; bu tam anonimleştirme değildir. Ad, adres, tahlil veya başka hassas kişisel bilgi yazmayın.'),
        controlAffinity: ListTileControlAffinity.leading),
      FilledButton.icon(onPressed: _busy || !_consent ? null : _ask,
        icon: const Icon(Icons.auto_awesome), label: Text(_busy ? 'Yanıt bekleniyor…' : 'Soruyu gönder')),
      if (_busy) const Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator())),
      if (_error != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!, style: const TextStyle(color: Colors.red)))),
      if (_answer != null) Card(child: Padding(padding: const EdgeInsets.all(18), child: SelectableText(_answer!))),
      const SizedBox(height: 12),
      Text(AiAssistantService.configured
        ? 'AI yanıtı için giriş yapılmış hesap ve yapılandırılmış sunucu gerekir. Sorular bu ekranda kalıcı olarak kaydedilmez.'
        : 'AI sunucusu henüz yapılandırılmadı. Bu ekran gerçek AI yanıtı üretmez.',
        style: const TextStyle(color: Colors.black54)),
    ]),
  );
  }
}


/// Sunucusuz bilgi asistanı ekranı. Sorular cihazdan çıkmaz ve kaydedilmez.
class OfflineAssistantView extends StatefulWidget {
  const OfflineAssistantView({super.key});
  @override
  State<OfflineAssistantView> createState() => _OfflineAssistantViewState();
}

class _OfflineAssistantViewState extends State<OfflineAssistantView> {
  static const _pink = Color(0xFFF0449B);
  static const _purple = Color(0xFF48235F);
  static const _suggestions = <String>[
    '8 aylık bebek için tarif önerisi',
    'Bebeğim için oyun önerileri',
    'Sıradaki aşılar hangileri?',
    'Gebeliğin 20. haftası',
    'Bebeğim gece sık uyanıyor',
    'Emzirme ve anne sütü',
  ];
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _thread = <(String, AssistantAnswer)>[];
  DateTime? _birth;
  String _babyName = '';

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  @override
  void dispose() { _input.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _loadChild() async {
    try {
      // Ana ekran profilinden yaş; bulunamazsa soru içindeki yaş kullanılır.
      final birth = DateTime.tryParse(await SecureHealthStore.read('dogum') ?? '');
      final name = await SecureHealthStore.read('bebekAdi') ?? '';
      if (mounted) setState(() { _birth = birth; _babyName = name; });
    } catch (_) {/* yaş bilgisi olmadan da çalışır */}
  }

  int? get _months {
    final b = _birth;
    if (b == null) return null;
    final n = DateTime.now();
    final m = (n.year - b.year) * 12 + n.month - b.month - (n.day < b.day ? 1 : 0);
    return m < 0 ? null : m;
  }

  void _ask([String? text]) {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty) return;
    final answer = OfflineAssistant.answer(question, childMonths: _months, childBirth: _birth);
    setState(() {
      _thread.add((question, answer));
      _input.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bilgi Asistanı')),
    body: Column(children: [
      Expanded(child: ListView(controller: _scroll, padding: const EdgeInsets.all(16), children: [
        Card(color: const Color(0xFFFFE6F3), elevation: 0, child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            'Yanıtlar uygulamadaki rehber, gebelik haftaları, aşı takvimi, etkinlik ve tarif içeriklerinden derlenir. '
            'Sorun cihazından çıkmaz ve kaydedilmez. Tanı ve tedavi yerine geçmez; acil durumda 112\'yi ara.'
            '${_months == null ? '' : '\n\n${_babyName.isEmpty ? 'Bebeğin' : _babyName} $_months aylık; yaşa göre öneriler buna göre seçilir.'}',
          ))),
        if (_thread.isEmpty) ...[
          const SizedBox(height: 12),
          const Text('Örnek sorular', style: TextStyle(fontWeight: FontWeight.bold, color: _purple)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in _suggestions)
              ActionChip(label: Text(s), onPressed: () => _ask(s)),
          ]),
        ],
        for (final (question, answer) in _thread) ...[
          const SizedBox(height: 14),
          Align(alignment: Alignment.centerRight, child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: _pink, borderRadius: BorderRadius.circular(18)),
            child: Text(question, style: const TextStyle(color: Colors.white)))),
          const SizedBox(height: 8),
          if (answer.urgent != null) Card(color: const Color(0xFFFFE0E0), elevation: 0, child: ListTile(
            leading: const Icon(Icons.emergency_outlined, color: Colors.red),
            title: Text(answer.urgent!, style: const TextStyle(fontWeight: FontWeight.w600)))),
          if (answer.sections.isEmpty && answer.urgent == null) const Card(elevation: 0, child: Padding(
            padding: EdgeInsets.all(14),
            child: Text('Bu konuda uygulamada bilgi bulamadım. Soruyu farklı kelimelerle (ör. "uyku", "ek gıda", "aşı") '
                'deneyebilir veya sağlık profesyoneline danışabilirsin.'))),
          for (final section in answer.sections) Card(elevation: 0, child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold, color: _purple)),
              const SizedBox(height: 6),
              for (final line in section.lines) Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('•  '), Expanded(child: Text(line))])),
              const SizedBox(height: 6),
              Text('Kaynak: ${section.source}', style: Theme.of(context).textTheme.bodySmall),
            ]))),
        ],
      ])),
      SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(children: [
          Expanded(child: TextField(
            key: const ValueKey('assistant_input'),
            controller: _input, maxLength: 300, minLines: 1, maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _ask(),
            decoration: const InputDecoration(hintText: 'Sorunu yaz…', counterText: ''))),
          const SizedBox(width: 8),
          IconButton.filled(key: const ValueKey('assistant_send'), onPressed: _ask,
            icon: const Icon(Icons.send_rounded)),
        ]))),
    ]),
  );
}
