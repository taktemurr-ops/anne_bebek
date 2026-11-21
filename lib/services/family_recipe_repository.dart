import 'family_recipes.dart';
import 'secure_health_store.dart';

/// GP-07: Persist personal recipes using platform encrypted storage.
class FamilyRecipeRepository {
  const FamilyRecipeRepository._();
  static const storageKey = 'family_recipes_v1';

  static Future<List<FamilyRecipe>> load() async =>
      decodeFamilyRecipes(await SecureHealthStore.read(storageKey));

  static Future<void> save(List<FamilyRecipe> recipes) async {
    final encoded = encodeFamilyRecipes(recipes);
    decodeFamilyRecipes(encoded);
    await SecureHealthStore.write(storageKey, encoded);
  }

  static Future<void> clear() => SecureHealthStore.delete(storageKey);
}
