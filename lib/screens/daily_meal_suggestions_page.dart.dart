import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/general_recipe_catalog.dart';

/// Paket 39 / Aşama 27. Mevcut haftalık plan ve alışveriş anahtarlarını kullanır.
class DailyMealSuggestionsPage extends StatefulWidget {
  const DailyMealSuggestionsPage({super.key});

  @override
  State<DailyMealSuggestionsPage> createState() => _DailyMealSuggestionsPageState();
}

class _DailyMealSuggestionsPageState extends State<DailyMealSuggestionsPage> {
  static const _purple = Color(0xFF48235F);
  static const _planKey = 'paket39_weekly_meal_plan_v1';
  String get _datedPlanKey {
    final monday = DateTime(_date.year, _date.month, _date.day).subtract(Duration(days: _date.weekday - 1));
    return 'paket39_weekly_meal_plan_v2_${monday.year.toString().padLeft(4,'0')}-${monday.month.toString().padLeft(2,'0')}-${monday.day.toString().padLeft(2,'0')}';
  }
  static const _days = <String>['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
  static const _meals = <String>['Kahvaltı', 'Öğle', 'Akşam'];
  int _shift = 0;
  DateTime _date = DateTime.now();
  bool _busy = false;

  String _dateLabel(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  List<GeneralRecipe> _candidates(String meal) {
    final matches = generalRecipes.where((r) {
      final cat = r.category.toLowerCase();
      final name = r.title.toLowerCase();
      if (meal == 'Kahvaltı') {
        return cat.contains('kahvalt') || name.contains('omlet') || name.contains('menemen') || name.contains('pankek');
      }
      if (meal == 'Öğle') {
        return cat.contains('çorba') || cat.contains('salata') || cat.contains('sebze') || cat.contains('bakliyat');
      }
      return cat.contains('tavuk') || cat.contains('balık') || cat.contains('et') || cat.contains('fırın') || cat.contains('makarna') || cat.contains('pilav');
    }).toList();
    return matches.isEmpty ? generalRecipes.toList() : matches;
  }

  GeneralRecipe? _suggest(String meal, {int offset = 0}) {
    final pool = _candidates(meal);
    if (pool.isEmpty) return null;
    final dayNumber = DateTime(_date.year, _date.month, _date.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    final index = (dayNumber * 7 + _meals.indexOf(meal) * 37 + _shift * 13 + offset * 19) % pool.length;
    return pool[index];
  }

  void _details(GeneralRecipe r) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * .75,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Text(r.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _purple)),
            const SizedBox(height: 6),
            Text('${r.category} • ${r.minutes} dakika'),
            const SizedBox(height: 16),
            const Text('Malzemeler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...r.ingredients.map((v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('• $v'))),
            const SizedBox(height: 14),
            const Text('Hazırlanışı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...r.steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text('${e.key + 1}. ${e.value}'),
            )),
          ]),
        ),
      ),
    );
  }

  Future<void> _saveToWeeklyPlan(String meal, GeneralRecipe r) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentMonday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final selectedMonday = DateTime(_date.year, _date.month, _date.day).subtract(Duration(days: _date.weekday - 1));
      final isCurrentWeek = currentMonday.year == selectedMonday.year && currentMonday.month == selectedMonday.month && currentMonday.day == selectedMonday.day;
      final raw = prefs.getString(_datedPlanKey) ?? (isCurrentWeek ? prefs.getString(_planKey) : null);
      final decoded = raw == null ? <String, dynamic>{} : jsonDecode(raw);
      if (decoded is! Map) throw const FormatException('Plan formatı geçersiz');
      final plan = <String, String>{};
      for (final entry in decoded.entries) {
        if (entry.key is String && entry.value is String) plan[entry.key as String] = entry.value as String;
      }
      final day = _days[_date.weekday - 1];
      final slot = '$day|$meal';
      if (plan.containsKey(slot) && mounted) {
        final replace = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Mevcut plan değiştirilsin mi?'),
            content: Text('$day $meal için kayıtlı tarifin üzerine yazılacak.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Değiştir')),
            ],
          ),
        );
        if (replace != true) return;
      }
      plan[slot] = r.id;
      final saved = await prefs.setString(_datedPlanKey, jsonEncode(plan));
      if (saved && isCurrentWeek) await prefs.setString(_planKey, jsonEncode(plan));
      if (!saved) throw StateError('Kayıt başarısız');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$day $meal planına eklendi.')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan kaydedilemedi; mevcut kayıtlar korunuyor.')),
      );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük Yemek Önerileri'), backgroundColor: const Color(0xFFF5E7FA)),
      body: generalRecipes.isEmpty
          ? const Center(child: Text('Henüz tarif bulunmuyor.'))
          : ListView(padding: const EdgeInsets.all(16), children: [
              Card(color: const Color(0xFFFFEAF5), child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  const Text('Bugün ne pişirsem?', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: _purple)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(tooltip: 'Önceki gün', onPressed: () => setState(() { _date = _date.subtract(const Duration(days: 1)); _shift = 0; }), icon: const Icon(Icons.chevron_left)),
                    Text(_dateLabel(_date), style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(tooltip: 'Sonraki gün', onPressed: () => setState(() { _date = _date.add(const Duration(days: 1)); _shift = 0; }), icon: const Icon(Icons.chevron_right)),
                  ]),
                  OutlinedButton.icon(onPressed: () => setState(() => _shift++), icon: const Icon(Icons.refresh), label: const Text('Başka öneriler göster')),
                ]),
              )),
              const SizedBox(height: 12),
              for (final meal in _meals) _mealCard(meal),
              const Padding(padding: EdgeInsets.all(8), child: Text(
                'Öneriler tarif kategorilerine göre hazırlanır; kişisel beslenme veya sağlık önerisi değildir. '
                'Haftalık plana aktarma, seçilen haftanın aynı gününü günceller.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              )),
            ]),
    );
  }

  Widget _mealCard(String meal) {
    final recipe = _suggest(meal);
    if (recipe == null) return const SizedBox.shrink();
    final alternative = _suggest(meal, offset: 1);
    return Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 12), child: Padding(
      padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(meal, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _purple)),
        const SizedBox(height: 8),
        Text(recipe.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Text('${recipe.category} • ${recipe.minutes} dk'),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton(onPressed: () => _details(recipe), child: const Text('Tarifi gör')),
          FilledButton.icon(onPressed: _busy ? null : () => _saveToWeeklyPlan(meal, recipe),
            icon: const Icon(Icons.calendar_month, size: 17), label: const Text('Haftalık plana ekle')),
        ]),
        if (alternative != null && alternative.id != recipe.id)
          TextButton(onPressed: () => _details(alternative), child: Text('Alternatif: ${alternative.title}')),
      ]),
    ));
  }
}
