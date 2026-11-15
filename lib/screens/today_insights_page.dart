import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/today_insights.dart';
import 'reminders_page.dart';

class TodayInsightsPage extends StatelessWidget {
  final String babyName;
  final DateTime? birth;
  final List<Map<String, String>> events;
  final List<Map<String, String>> measurements;
  const TodayInsightsPage({super.key, required this.babyName, required this.birth, required this.events, required this.measurements});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final latest = TodayInsights.latestMeasurement(measurements);
    final ageDays = birth == null ? null : now.difference(birth!).inDays;
    final ageText = ageDays == null ? 'Doğum tarihi eklenmedi' : ageDays < 0 ? 'Doğum bekleniyor' : 'Yaklaşık ${(ageDays / 30.44).floor()} aylık';
    final report = TodayInsights.report(babyName: babyName, birth: birth, events: events, measurements: measurements, now: now);
    Widget info(String title, String subtitle, IconData icon) => Card(child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(subtitle)));
    return Scaffold(
      appBar: AppBar(title: const Text('Bugün ve analizler')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(babyName.isEmpty ? 'Bebek takibim' : babyName, style: Theme.of(context).textTheme.headlineSmall),
        Text(ageText), const SizedBox(height: 12),
        info('Bugünkü beslenme kayıtları', '${TodayInsights.countToday(events, 'Beslenme', now)} kayıt', Icons.restaurant),
        info('Bugünkü uyku kayıtları', '${TodayInsights.countToday(events, 'Uyku', now)} kayıt', Icons.bedtime),
        info('Son 7 gün – beslenme', '${TodayInsights.countLastDays(events, 'Beslenme', now, 7)} kayıt', Icons.analytics_outlined),
        info('Son 7 gün – uyku', '${TodayInsights.countLastDays(events, 'Uyku', now, 7)} kayıt', Icons.insights),
        info('Son büyüme ölçümü', latest == null ? 'Henüz ölçüm yok' : 'Boy: ${latest['boy'] ?? '-'} cm • Kilo: ${latest['kilo'] ?? '-'} kg • Baş: ${latest['basCevresi'] ?? '-'} cm', Icons.monitor_weight_outlined),
        Card(child: ListTile(leading: const Icon(Icons.notifications_active_outlined), title: const Text('Aile hatırlatıcıları'), subtitle: const Text('Kontrol ve randevu hatırlatıcılarını yönet'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const RemindersPage())))),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: () async { await Clipboard.setData(ClipboardData(text: report)); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doktor görüşmesi özeti panoya kopyalandı.'))); }, icon: const Icon(Icons.copy), label: const Text('Doktor özeti kopyala')),
        const SizedBox(height: 12), const Text('Bu bilgiler yalnızca uygulamaya girilen kayıtların özetidir. Eksik kayıtlar gerçek günlük toplamları yansıtmayabilir. Sağlık tavsiyesi veya tanı değildir.'),
      ]),
    );
  }
}
