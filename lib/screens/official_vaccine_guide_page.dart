import 'package:flutter/material.dart' hide Text;
import '../i18n/text.dart';
import '../services/child_profiles.dart';
import '../services/turkey_vaccine_schedule.dart';

class OfficialVaccineGuidePage extends StatelessWidget {
  final ChildProfile child;
  const OfficialVaccineGuidePage({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text('${child.name} • Aşı takvimi')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
          'Bu liste doğum tarihinden hesaplanan bilgilendirme planıdır; aşı yapıldığını göstermez. '
          '1 Eylül 2026 suçiçeği ikinci doz güncellemesi dikkate alınmıştır. '
          'Erken doğum, eksik doz ve özel risk durumlarında kişisel plan gerekir.'))),
        for (final vaccine in routineVaccinesForBirth(child.birthDate))
          Builder(builder: (context) {
            final due = vaccine.dueDate(child.birthDate);
            final past = DateTime(due.year, due.month, due.day).isBefore(DateTime(now.year, now.month, now.day));
            return Card(child: ListTile(
              leading: Icon(past ? Icons.history : Icons.event_outlined),
              title: Text(vaccine.title),
              subtitle: Text('${due.day.toString().padLeft(2,'0')}.${due.month.toString().padLeft(2,'0')}.${due.year} • ${vaccine.month}. ay'),
              trailing: Text(past ? 'Tarih geçti' : 'Planlandı', style: TextStyle(color: past ? Colors.orange : null)),
            ));
          }),
        if (mayNeedVaricellaCatchup(child.birthDate, now))
          const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
            'DİKKAT: Çocuk 49–72 aylık yakalama aşılaması yaş grubunda olabilir. '
            'İkinci suçiçeği dozu için aile hekiminizle görüşün. '
            'Bu uyarı aşı yapılmadığı anlamına gelmez.'))),
        const Padding(padding: EdgeInsets.all(16), child: Text(
          'Kaynak: T.C. Sağlık Bakanlığı 2025 Ulusal Aşı Takvimi ve '
          '03.09.2026 tarihli suçiçeği ikinci doz duyurusu. '
          'Liste çevrimdışıdır, otomatik güncellenmez; kişisel aşı kartı yerine geçmez.')),
      ]),
    );
  }
}
