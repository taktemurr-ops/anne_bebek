import 'dart:convert';

/// GP-07: Personal recipe records; no nutritional or medical claims.
class FamilyRecipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final int preparationMinutes;
  final String instructions;

  const FamilyRecipe({required this.id, required this.title,
    required this.ingredients, required this.preparationMinutes,
    required this.instructions});

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'ingredients': ingredients,
    'preparationMinutes': preparationMinutes, 'instructions': instructions,
  };

  factory FamilyRecipe.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final ingredients = json['ingredients'];
    final minutes = json['preparationMinutes'];
    final instructions = json['instructions'];
    if (id is! String || id.trim().isEmpty ||
        title is! String || title.trim().isEmpty || title.runes.length > 120 ||
        ingredients is! List || ingredients.isEmpty || ingredients.length > 100 ||
        ingredients.any((e) => e is! String || e.trim().isEmpty || e.runes.length > 120) ||
        minutes is! int || minutes < 1 || minutes > 1440 ||
        instructions is! String || instructions.trim().isEmpty ||
        instructions.runes.length > 5000) {
      throw const FormatException('Geçersiz tarif kaydı');
    }
    return FamilyRecipe(id: id, title: title.trim(),
      ingredients: List<String>.unmodifiable(ingredients.cast<String>()),
      preparationMinutes: minutes, instructions: instructions.trim());
  }
}

String encodeFamilyRecipes(List<FamilyRecipe> recipes) =>
    jsonEncode(recipes.map((recipe) => recipe.toJson()).toList());

List<FamilyRecipe> decodeFamilyRecipes(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) throw const FormatException('Tarif listesi bozuk');
  final ids = <String>{};
  final recipes = <FamilyRecipe>[];
  for (final item in decoded) {
    if (item is! Map) throw const FormatException('Geçersiz tarif');
    final recipe = FamilyRecipe.fromJson(Map<String, dynamic>.from(item));
    if (!ids.add(recipe.id)) throw const FormatException('Yinelenen tarif kimliği');
    recipes.add(recipe);
  }
  return recipes;
}
