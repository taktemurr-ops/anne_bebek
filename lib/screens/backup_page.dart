import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/backup_service.dart';
import '../services/encrypted_backup.dart';
import '../services/backup_inspection.dart';
import '../services/local_reminder_notifications.dart';
import '../services/reminder_repository.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool busy = false;

  final input = TextEditingController();
  final password = TextEditingController();

  bool showPassword = false;

  @override
  void dispose() {
    input.dispose();
    password.dispose();
    super.dispose();
  }

  void message(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  Future<void> backup() async {
    setState(() {
      busy = true;
    });

    try {
      final text = await EncryptedBackup.encrypt(
        await BackupService.export(),
        password.text,
      );

      await Clipboard.setData(
        ClipboardData(text: text),
      );

      password.clear();

      message(
        'Şifreli yedek panoya kopyalandı. '
        'Parolanızı ayrı ve güvenli bir yerde saklayın.',
      );
    } catch (e) {
      message('Yedek oluşturulamadı: $e');
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> restore() async {
    String plain;

    try {
      plain = await EncryptedBackup.decrypt(
        input.text.trim(),
        password.text,
      );
    } catch (e) {
      message('Yedek doğrulanamadı: $e');
      return;
    }

    BackupInspection inspection;

    try {
      inspection = BackupInspection.inspect(plain);
    } catch (e) {
      message('Yedek içeriği geçersiz: $e');
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kayıtları geri yükle?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yedekte ${inspection.fieldCount} veri alanı ve '
                'yaklaşık ${inspection.recordCount} kayıt var.',
              ),
              const SizedBox(height: 8),
              const Text(
                'DİKKAT: Yedekte bulunan alanlardaki mevcut kayıtlar '
                'yedekteki değerlerle değiştirilecek. Yedekte olmayan '
                'alanlardaki kayıtlar korunur. İşlem öncesi yine de '
                'mevcut verilerinizi ayrıca yedekleyin.',
              ),
              for (final warning in inspection.warnings) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠ $warning',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'Geri yüklemeden sonra uygulamayı yeniden başlatın.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Riskleri anladım, geri yükle',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      busy = true;
    });

    try {
      final count = await BackupService.restore(plain);
      // Geri yüklenen hatırlatıcıları, bildirim tercihine göre yeniden planla.
      try {
        final reminders = await ReminderRepository.load();
        await LocalReminderNotifications.sync(reminders, reminders);
      } catch (_) {
        // Bildirim desteği olmayan platformlarda kayıtlar yine geri yüklenir.
      }

      password.clear();
      input.clear();

      message(
        '$count kayıt alanı geri yüklendi. '
        'Uygulamayı tamamen kapatıp yeniden açın.',
      );
    } catch (e) {
      message('Geri yükleme başarısız: $e');
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yedekleme ve geri yükleme'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Yedekler AES-256-GCM ile parola kullanılarak '
                'şifrelenir. Parolanızı unutursanız yedeği açamazsınız. '
                'Panoya kopyalanan yedek metnini yine de güvenle saklayın. '
                'ÖNEMLİ: Bu işlem cihazdaki canlı kayıtları şifrelemez; '
                'bulut yedekleme değildir.',
              ),
            ),
          ),

          const SizedBox(height: 12),

          // YEDEK PAROLASI
          TextField(
            controller: password,
            obscureText: !showPassword,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Yedek parolası (en az 12 karakter)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
                icon: Icon(
                  showPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // YEDEK OLUŞTUR
          FilledButton.icon(
            onPressed: busy ? null : backup,
            icon: const Icon(Icons.copy),
            label: const Text(
              'Şifreli yedeği panoya kopyala',
            ),
          ),

          const SizedBox(height: 8),

          // PANO TEMİZLE
          TextButton.icon(
            onPressed: busy
                ? null
                : () async {
                    await Clipboard.setData(
                      const ClipboardData(text: ''),
                    );

                    message('Pano temizlendi.');
                  },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Panoyu temizle'),
          ),

          const SizedBox(height: 24),

          const Text(
            'Geri yükleme',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Şifreli yedeği aşağıya yapıştırın ve oluştururken '
            'kullandığınız parolayı girin. Eski şifresiz yedekler '
            'bu ekrandan içe aktarılamaz.',
          ),

          const SizedBox(height: 12),

          // YEDEK METNİ
          TextField(
            controller: input,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Şifreli yedek metni',
            ),
          ),

          const SizedBox(height: 12),

          // GERİ YÜKLE
          OutlinedButton.icon(
            onPressed: busy ? null : restore,
            icon: const Icon(Icons.restore),
            label: const Text(
              'Yedeği doğrula ve geri yükle',
            ),
          ),

          if (busy)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}