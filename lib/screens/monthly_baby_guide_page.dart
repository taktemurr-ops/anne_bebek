import 'package:flutter/material.dart';
import '../data/monthly_baby_guide.dart';
import 'baby_nutrition_page.dart';

/// 0–72 ay rehberi; içerik seçilen aya göre değişir.
class MonthlyBabyGuidePage extends StatefulWidget {
  final int initialMonth;
  const MonthlyBabyGuidePage({super.key, required this.initialMonth});

  @override
  State<MonthlyBabyGuidePage> createState() => _MonthlyBabyGuidePageState();
}

class _MonthlyBabyGuidePageState extends State<MonthlyBabyGuidePage> {
  late int month;
  @override
  void initState() {
    super.initState();
    month = widget.initialMonth.clamp(0, 72).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final guide = babyGuideForMonth(month);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FC),
      appBar: AppBar(title: const Text('Aylık bebek rehberi'), backgroundColor: const Color(0xFFFFF8FC)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD9E9), Color(0xFFEAE1FF)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bebeğinizin yolculuğu', style: TextStyle(color: Color(0xFF755675))),
            const SizedBox(height: 6),
            Text('$month. ay', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF713B72))),
            const SizedBox(height: 12),
            Row(children: [
              IconButton(tooltip: 'Önceki ay', onPressed: month > 0 ? () => setState(() => month--) : null, icon: const Icon(Icons.chevron_left)),
              Expanded(child: DropdownButtonFormField<int>(
                key: ValueKey(month), initialValue: month, isExpanded: true,
                decoration: const InputDecoration(labelText: 'Ay seçin', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                items: List.generate(73, (i) => DropdownMenuItem(value: i, child: Text('$i. ay'))),
                onChanged: (v) { if (v != null) setState(() => month = v); },
              )),
              IconButton(tooltip: 'Sonraki ay', onPressed: month < 72 ? () => setState(() => month++) : null, icon: const Icon(Icons.chevron_right)),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        Card(color: Colors.white, child: ListTile(
          leading: const Icon(Icons.restaurant_menu, color: Color(0xFFC64D8E)),
          title: const Text('Bu ay ne yedirebilirim?'),
          subtitle: const Text('Yaşa uygun beslenme rehberi ve tarifler'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => BabyNutritionPage(initialMonth: month))),
        )),
        const SizedBox(height: 14),
        const Text('Bu ay neler önemli?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        for (final category in babyGuideCategories)
          Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: Icon(_icon(category), color: const Color(0xFFC64D8E)),
              title: Text(category, style: const TextStyle(fontWeight: FontWeight.w600)),
              children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(alignment: Alignment.centerLeft, child: Text(guide.sections[category] ?? '')))],
            ),
          ),
        const SizedBox(height: 12),
        const Text('Bu rehber genel bilgi sunar; çocuğunuzun bireysel gelişimi ve sağlık ihtiyaçları için hekiminize danışın. Aylar arasında bazı öneriler benzer olabilir.', style: TextStyle(color: Color(0xFF776B7C), fontSize: 12)),
      ]),
    );
  }

  IconData _icon(String category) {
    switch (category) {
      case 'Beslenme': return Icons.restaurant_outlined;
      case 'Gelişim': return Icons.trending_up;
      case 'Uyku': return Icons.bedtime_outlined;
      case 'Oyun': return Icons.toys_outlined;
      case 'Sağlık': return Icons.favorite_outline;
      default: return Icons.health_and_safety_outlined;
    }
  }
}
