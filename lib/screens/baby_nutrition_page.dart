import 'package:flutter/material.dart';
import '../data/baby_nutrition.dart';

class BabyNutritionPage extends StatefulWidget {
  final int initialMonth;
  const BabyNutritionPage({super.key, required this.initialMonth});
  @override
  State<BabyNutritionPage> createState() => _BabyNutritionPageState();
}

class _BabyNutritionPageState extends State<BabyNutritionPage> {
  late int month;
  String query = '';
  String category = 'Tümü';
  @override
  void initState() {
    super.initState();
    month = widget.initialMonth.clamp(0, 72).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final eligible = mealsForMonth(month);
    final categories = <String>['Tümü', ...{for (final meal in eligible) meal.category}];
    final selected = categories.contains(category) ? category : 'Tümü';
    final shown = eligible.where((meal) =>
      (selected == 'Tümü' || meal.category == selected) &&
      (meal.name.toLowerCase().contains(query.toLowerCase()) ||
       meal.ingredients.any((item) => item.toLowerCase().contains(query.toLowerCase())))).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FC),
      appBar: AppBar(title: const Text('Bebek beslenmesi')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD9E9), Color(0xFFEAE1FF)]),
            borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$month. ay beslenme rehberi', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF713B72))),
            const SizedBox(height: 8),
            Text(nutritionNoteForMonth(month)),
            const SizedBox(height: 12),
            Row(children: [
              IconButton(tooltip: 'Önceki ay', onPressed: month > 0 ? () => setState(() => month--) : null, icon: const Icon(Icons.chevron_left)),
              Expanded(child: DropdownButtonFormField<int>(
                key: ValueKey(month), initialValue: month, isExpanded: true,
                decoration: const InputDecoration(labelText: 'Ay seç', filled: true, fillColor: Colors.white),
                items: List.generate(73, (index) => DropdownMenuItem(value: index, child: Text('$index. ay'))),
                onChanged: (value) { if (value != null) setState(() => month = value); },
              )),
              IconButton(tooltip: 'Sonraki ay', onPressed: month < 72 ? () => setState(() => month++): null, icon: const Icon(Icons.chevron_right)),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        if (month < 6) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Bu yaş için ek gıda tarifi listelenmiyor. Beslenme konusunda çocuk doktorunuzun önerilerini izleyin.'))),
        if (month >= 6) ...[
          TextField(onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(hintText: 'Tarif veya malzeme ara', prefixIcon: Icon(Icons.search))),
          const SizedBox(height: 10),
          SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final item in categories) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
              label: Text(item), selected: selected == item,
              onSelected: (_) => setState(() => category = item))),
          ])),
          const SizedBox(height: 8),
          Text('${shown.length} tarif', style: const TextStyle(fontWeight: FontWeight.bold)),
          if (shown.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Aramanıza uygun tarif bulunamadı.')),
          for (final meal in shown) Card(color: Colors.white, child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFFFE4EF), child: Icon(Icons.restaurant_menu, color: Color(0xFFB43B7B))),
            title: Text(meal.name),
            subtitle: Text('${meal.category} • ${meal.minutes} dk • ${meal.minMonth}+ ay'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => _MealDetail(meal: meal))),
          )),
        ],
        const SizedBox(height: 16),
        const Text('Güvenlik: 12 aydan küçük bebeklere bal vermeyin. Bütün kuruyemiş, bütün üzüm ve sert/yuvarlak parçalar boğulma riski taşır. Yeni alerjenler ve özel sağlık durumları için sağlık uzmanına danışın. Tarifler kişisel tıbbi tavsiye değildir.',
          style: TextStyle(fontSize: 12, color: Color(0xFF776B7C))),
      ]),
    );
  }
}

class _MealDetail extends StatelessWidget {
  final BabyMeal meal;
  const _MealDetail({required this.meal});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(meal.name)),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Text('${meal.minMonth}+ ay • ${meal.minutes} dakika • ${meal.category}', style: const TextStyle(color: Color(0xFF8B527E))),
      const SizedBox(height: 18),
      const Text('Malzemeler', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      for (final ingredient in meal.ingredients) Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Text('• $ingredient')),
      const SizedBox(height: 18),
      const Text('Hazırlanışı', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      for (var i = 0; i < meal.steps.length; i++) Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Text('${i + 1}. ${meal.steps[i]}')),
      const SizedBox(height: 18),
      Card(color: const Color(0xFFFFF0F6), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Alerjen bilgisi', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(meal.allergens),
        const SizedBox(height: 10),
        const Text('Güvenli sunum', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(meal.safety),
      ]))),
    ]),
  );
}
