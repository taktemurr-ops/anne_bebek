import 'package:flutter/material.dart' hide Text;
import '../i18n/text.dart';
import '../data/general_recipe_catalog.dart';
import '../data/recipe_meta.dart';
import 'pastel_design.dart';

/// Tarif başlığının altında gösterilen kişi sayısı, süreler, zorluk ve fırın
/// bilgisi. Hazırlanışı henüz ayrıntılandırılmamış tarifler açıkça belirtilir.
class RecipeSummaryChips extends StatelessWidget {
  const RecipeSummaryChips({super.key, required this.recipe});

  final GeneralRecipe recipe;

  @override
  Widget build(BuildContext context) {
    final oven = RecipeMeta.ovenCelsius(recipe);
    final chips = <(IconData, String)>[
      (Icons.people_alt_outlined, '${recipe.servings} kişilik'),
      (Icons.timer_outlined, 'Hazırlık ${recipe.prepMinutes} dk'),
      (Icons.local_fire_department_outlined, 'Pişirme ${recipe.cookMinutes} dk'),
      (Icons.signal_cellular_alt_rounded, recipe.difficulty),
      if (oven != null) (Icons.microwave_outlined, 'Fırın $oven °C'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final (icon, label) in chips)
          Chip(
            avatar: Icon(icon, size: 18, color: PastelPalette.text),
            label: Text(label),
            backgroundColor: PastelPalette.softPink,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
      ]),
      if (!recipe.detailed)
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, color: Colors.deepOrange),
            SizedBox(width: 8),
            Expanded(child: Text(
              'Bu tarifin adım adım ayrıntılı anlatımı hazırlanıyor. '
              'Şimdilik genel pişirme adımları gösteriliyor.',
              style: TextStyle(fontSize: 13))),
          ]),
        ),
    ]);
  }
}

/// Hazırlanış adımlarından sonra gelen püf noktaları, servis, saklama ve
/// alerjen bölümleri.
class RecipeExtraSections extends StatelessWidget {
  const RecipeExtraSections({super.key, required this.recipe});

  final GeneralRecipe recipe;

  @override
  Widget build(BuildContext context) {
    final tips = RecipeMeta.tips(recipe);
    final allergens = RecipeMeta.allergens(recipe);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (tips.isNotEmpty) ...[
        const _SectionTitle('Püf noktaları', Icons.lightbulb_outline),
        for (final tip in tips)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('•  ', style: TextStyle(color: PastelPalette.primary)),
              Expanded(child: Text(tip)),
            ]),
          ),
      ],
      const _SectionTitle('Servis önerisi', Icons.room_service_outlined),
      Text(RecipeMeta.serving(recipe)),
      const _SectionTitle('Saklama koşulları', Icons.kitchen_outlined),
      Text(RecipeMeta.storage(recipe)),
      const _SectionTitle('Alerjen bilgisi', Icons.warning_amber_rounded),
      if (allergens.isEmpty)
        const Text('Malzemelerde yaygın alerjen tespit edilmedi.')
      else
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final a in allergens)
            Chip(
              label: Text(a),
              backgroundColor: PastelPalette.lavender,
              side: BorderSide.none,
            ),
        ]),
      const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          'Alerjenler malzeme adlarından otomatik belirlenir; paketli ürünlerin etiketini ayrıca kontrol edin.',
          style: TextStyle(fontSize: 11, color: Colors.black54)),
      ),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.icon);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Row(children: [
          Icon(icon, color: PastelPalette.primary, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: PastelPalette.text)),
        ]),
      );
}
