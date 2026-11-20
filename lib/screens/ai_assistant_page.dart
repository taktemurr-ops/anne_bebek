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
  Widget build(BuildContext context) => Scaffold(
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
