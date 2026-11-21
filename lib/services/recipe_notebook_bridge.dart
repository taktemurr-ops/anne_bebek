import '../data/baby_recipe_catalog.dart';
import '../data/general_recipe_catalog.dart';
import 'family_recipes.dart';

/// GP-07: Katalog tariflerini kişisel aile tarif defterine kopyalar.
/// Kopya bağımsızdır; kullanıcı defterde düzenleyebilir, katalog değişmez.
/// Kimlikler önekli olduğundan aynı tarif iki kez eklenmez.
class RecipeNotebookBridge {
  const RecipeNotebookBridge._();

  static const _maxIngredients = 100;
  static const _maxItemRunes = 120;
  static const _maxInstructionRunes = 5000;

  static String idForGeneral(GeneralRecipe r) => 'katalog_${r.id}';
  static String idForBaby(BabyRecipe r) => 'bebek_${r.id}';

  static FamilyRecipe fromGeneral(GeneralRecipe r) => _build(
    id: idForGeneral(r),
    title: r.title,
    ingredients: r.ingredients,
    minutes: r.minutes,
    sections: [
      _numbered(r.steps),
      if (r.tips.isNotEmpty) 'Püf noktaları:\n${r.tips.map((t) => '• $t').join('\n')}',
      if ((r.storage ?? '').trim().isNotEmpty) 'Saklama: ${r.storage!.trim()}',
    ],
  );

  static FamilyRecipe fromBaby(BabyRecipe r) => _build(
    id: idForBaby(r),
    title: '${r.title} (${r.minMonths}+ ay)',
    ingredients: r.ingredients,
    // Bebek kataloğunda süre alanı yok; düzenlenebilir başlangıç değeri.
    minutes: 30,
    sections: [
      _numbered(r.steps),
      if (r.tips.isNotEmpty) 'İpuçları:\n${r.tips.map((t) => '• $t').join('\n')}',
      if ((r.storage ?? '').trim().isNotEmpty) 'Saklama: ${r.storage!.trim()}',
      'Süre tahminidir; kendi deneyiminize göre düzenleyebilirsiniz.',
    ],
  );

  /// Tarif yoksa ekler. (yeni liste, eklendi mi)
  static (List<FamilyRecipe>, bool) add(List<FamilyRecipe> notebook, FamilyRecipe recipe) {
    if (notebook.any((e) => e.id == recipe.id)) return (notebook, false);
    return ([...notebook, recipe], true);
  }

  static String _numbered(List<String> steps) => [
    for (var i = 0; i < steps.length; i++) '${i + 1}. ${steps[i].trim()}',
  ].join('\n');

  static String _clip(String text, int max) {
    final runes = text.runes.toList();
    if (runes.length <= max) return text;
    return '${String.fromCharCodes(runes.take(max - 1))}…';
  }

  static FamilyRecipe _build({
    required String id,
    required String title,
    required List<String> ingredients,
    required int minutes,
    required List<String> sections,
  }) {
    final cleaned = ingredients
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(_maxIngredients)
        .map((e) => _clip(e, _maxItemRunes))
        .toList();
    final instructions = _clip(
        sections.where((s) => s.trim().isNotEmpty).join('\n\n'), _maxInstructionRunes);
    final recipe = FamilyRecipe(
      id: id,
      title: _clip(title.trim(), 120),
      ingredients: cleaned.isEmpty ? const ['Malzeme listesi tarifte'] : cleaned,
      preparationMinutes: minutes.clamp(1, 1440),
      instructions: instructions.isEmpty ? 'Tarif adımları katalogda.' : instructions,
    );
    // Defter modelinin kurallarından geçtiğini garanti et.
    return FamilyRecipe.fromJson(recipe.toJson());
  }
}
