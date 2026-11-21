import '../widgets/coming_soon.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import '../services/cloud_auth_service.dart';

class CloudAccountPage extends StatefulWidget {
  const CloudAccountPage({super.key});
  @override
  State<CloudAccountPage> createState() => _CloudAccountPageState();
}

class _CloudAccountPageState extends State<CloudAccountPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  bool hidePassword = true;
  String? signedInEmail;
  String? feedback;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final session = await CloudAuthService.currentSession();
      if (!mounted) return;
      setState(() => signedInEmail = (session?['user'] is Map ? session!['user']['email'] : null)?.toString());
    } catch (e) {
      if (mounted) setState(() => feedback = 'Oturum okunamadı: $e');
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() { busy = true; feedback = null; });
    try {
      await action();
      if (mounted) await _load();
    } catch (e) {
      if (mounted) setState(() => feedback = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  bool _validate({bool needPassword = true}) {
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim())) {
      setState(() => feedback = 'Geçerli bir e-posta adresi girin.');
      return false;
    }
    if (needPassword && password.text.length < 6) {
      setState(() => feedback = 'Şifre en az 6 karakter olmalı.');
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!CloudAuthService.configured) {
      return const ComingSoonView(title: 'Bulut hesabım', icon: Icons.cloud_outlined,
        description: 'Hesap oluşturup kayıtlarını cihazlar arasında güvenle eşitleme.');
    }
    return Scaffold(
    appBar: AppBar(title: const Text('Bulut hesabım')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Üyelik için Supabase projesi gerekir. Sağlık kayıtları ve bebek verileri bu aşamada buluta gönderilmez; yalnızca hesap oturumu yönetilir.'))),
      if (!CloudAuthService.configured) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('⚠️ Çevrim içi hesaplar henüz etkin değil. Uygulama SUPABASE_URL ve SUPABASE_ANON_KEY yapılandırmasıyla derlenmelidir. Sahte hesap oluşturulmaz.'))),
      if (signedInEmail != null) ...[
        ListTile(leading: const Icon(Icons.verified_user_outlined), title: Text(signedInEmail!), subtitle: const Text('Bu cihazda kayıtlı oturum')),
        FilledButton.icon(onPressed: busy ? null : () => _run(() async { await CloudAuthService.logout(); setState(() { signedInEmail = null; feedback = 'Oturum kapatıldı.'; }); }), icon: const Icon(Icons.logout), label: const Text('Çıkış yap')),
        OutlinedButton(onPressed: busy || !CloudAuthService.configured ? null : () => _run(() async { await CloudAuthService.refreshSession(); setState(() => feedback = 'Oturum yenilendi.'); }), child: const Text('Oturumu yenile')),
      ] else ...[
        TextField(controller: email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], decoration: InputDecoration(labelText: t('E-posta adresi'))),
        const SizedBox(height: 12),
        TextField(controller: password, obscureText: hidePassword, autofillHints: const [AutofillHints.password], decoration: InputDecoration(labelText: t('Şifre'), suffixIcon: IconButton(onPressed: () => setState(() => hidePassword = !hidePassword), icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off)))),
        const SizedBox(height: 16),
        FilledButton(onPressed: busy || !CloudAuthService.configured ? null : () { if (_validate()) _run(() async { final result = await CloudAuthService.login(email.text, password.text); setState(() => feedback = result['access_token'] != null ? 'Giriş başarılı.' : 'E-posta doğrulaması gerekebilir.'); }); }, child: const Text('Giriş yap')),
        OutlinedButton(onPressed: busy || !CloudAuthService.configured ? null : () { if (_validate()) _run(() async { final result = await CloudAuthService.register(email.text, password.text); setState(() => feedback = result['access_token'] != null ? 'Hesap oluşturuldu ve oturum açıldı.' : 'Kayıt talebi alındı. E-postanızı doğrulayın.'); }); }, child: const Text('Yeni hesap oluştur')),
        TextButton(onPressed: busy || !CloudAuthService.configured ? null : () { if (_validate(needPassword: false)) _run(() async { await CloudAuthService.resetPassword(email.text); setState(() => feedback = 'E-posta adresi kayıtlıysa şifre sıfırlama bağlantısı gönderilir.'); }); }, child: const Text('Şifremi unuttum')),
      ],
      if (busy) const Center(child: CircularProgressIndicator()),
      if (feedback != null) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(feedback!, style: const TextStyle(color: Color(0xFF48235F)))),
    ]),
  );
  }
}
