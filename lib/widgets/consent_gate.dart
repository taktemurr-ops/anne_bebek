import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// KVKK m.6: sağlık verileri açık rıza ile işlenir. İlk açılışta (ve metin
/// sürümü değiştiğinde) aydınlatma özeti gösterilir; onay olmadan uygulama
/// kayıt ekranlarına geçmez.
class ConsentGate extends StatefulWidget {
  final Widget child;
  const ConsentGate({super.key, required this.child});

  static const storageKey = 'privacy_consent_v1';

  /// Metin önemli ölçüde değişirse artırın; kullanıcıdan yeniden onay istenir.
  static const currentVersion = 1;

  static Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(storageKey) ?? 0) >= currentVersion;
  }

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  bool? _accepted;
  bool _checked = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    ConsentGate.isAccepted().then((value) {
      if (mounted) setState(() => _accepted = value);
    }).catchError((Object _) {
      if (mounted) setState(() => _accepted = false);
    });
  }

  Future<void> _accept() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setInt(ConsentGate.storageKey, ConsentGate.currentVersion);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) _accepted = true;
    });
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onay kaydedilemedi. Lütfen tekrar deneyin.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_accepted == true) return widget.child;
    if (_accepted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const Icon(Icons.favorite_rounded, size: 48, color: Color(0xFFF0449B)),
            const SizedBox(height: 12),
            Text('Anne & Bebek\'e hoş geldin',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            const PrivacySummary(),
            const SizedBox(height: 12),
            CheckboxListTile(
              key: const ValueKey('consent_checkbox'),
              value: _checked,
              onChanged: _saving ? null : (v) => setState(() => _checked = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Aydınlatma metnini okudum. Sağlık verilerimin ve '
                  'çocuğumun verilerinin bu cihazda işlenmesine açık rıza veriyorum.'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('consent_accept'),
              onPressed: !_checked || _saving ? null : _accept,
              child: const Text('Devam et'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gizlilik özetinin tek kaynağı: onay ekranında ve Profil'de gösterilir.
class PrivacySummary extends StatelessWidget {
  const PrivacySummary({super.key});

  static const items = <(IconData, String)>[
    (Icons.phone_android_rounded,
        'Kayıtların yalnızca bu cihazda tutulur; bize veya üçüncü kişilere gönderilmez. Reklam ve analiz aracı yoktur.'),
    (Icons.lock_rounded,
        'Bebek bakımı, büyüme, adet ve gebelik kayıtları cihazın güvenli deposunda şifrelenir.'),
    (Icons.backup_rounded,
        'Yedek almak senin elindedir; yedeği parolayla şifrelemen önerilir.'),
    (Icons.delete_forever_rounded,
        'Rızanı geri almak için Profil → "Tüm yerel kayıtları sil" ile tüm verilerini silebilirsin.'),
    (Icons.medical_information_rounded,
        'İçerikler bilgilendirme amaçlıdır, tıbbi tavsiye değildir. Döngü tahminleri yaklaşıktır ve doğum kontrolü için kullanılmamalıdır. Acil durumda 112\'yi ara.'),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (icon, text) in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: const Color(0xFF48235F)),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ]),
        ),
    ],
  );
}
