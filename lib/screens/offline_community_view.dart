import 'package:flutter/material.dart' hide Text;

import '../data/encyclopedia/encyclopedia.dart';
import '../i18n/text.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';
import 'ai_assistant_page.dart';
import 'backup_page.dart';
import 'encyclopedia_page.dart';
import 'questions_page.dart';

/// Çevrim içi hizmet henüz açık değilken boş ekran yerine çalışan
/// çevrimdışı karşılıklar: sık merak edilen konular, bilgi asistanı,
/// soru defteri ve (gerekirse) şifreli yedekleme.
class OfflineCommunityView extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<String> categories;
  final bool showBackup;
  const OfflineCommunityView({super.key, required this.title, required this.icon,
      required this.description, this.categories = const [], this.showBackup = false});

  @override
  Widget build(BuildContext context) {
    final topics = encyclopediaTopics.where((e) => categories.contains(e.category)).take(14).toList();
    void push(Widget w) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        PastelCard(color: const Color(0xFFFFF4FA), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: kitMor, size: 32),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(description, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Bu bölümün çevrim içi kısmı hesaplar etkinleştirildiğinde açılır. O zamana kadar aşağıdaki içerik ve araçlar internetsiz çalışır.',
                style: const TextStyle(fontSize: 12.5)),
          ])),
        ])),
        PastelCard(onTap: () => push(const AiAssistantPage()), child: ListTile(contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.auto_awesome_outlined, color: kitMor),
            title: Text('Bilgi asistanına sor', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('Bebek, gebelik, aşı ve tarif soruların · çevrimdışı'),
            trailing: const Icon(Icons.chevron_right))),
        PastelCard(onTap: () => push(const QuestionsPage()), child: ListTile(contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.question_answer_outlined, color: kitMor),
            title: Text('Soru defterim ve sık sorulanlar', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('Doktoruna soracaklarını yaz; sık sorulan soruların yanıtları'),
            trailing: const Icon(Icons.chevron_right))),
        if (showBackup)
          PastelCard(onTap: () => push(const BackupPage()), child: ListTile(contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.backup_outlined, color: kitMor),
              title: Text('Şifreli yedekleme ve geri yükleme', style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('Kayıtlarını dosyaya yedekle, başka cihaza taşı'),
              trailing: const Icon(Icons.chevron_right))),
        if (topics.isNotEmpty) ...[
          const KitHeader('En çok merak edilenler', Icons.menu_book_outlined),
          for (final e in topics)
            PastelCard(onTap: () => push(EncyclopediaPage(initialQuery: e.title)), padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.title, style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor)),
                  Text(e.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5)),
                ])),
        ],
      ])),
    );
  }
}
