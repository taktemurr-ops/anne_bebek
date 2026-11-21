import 'package:flutter/material.dart';
import '../services/family_recipe_repository.dart';
import '../services/family_recipes.dart';
import '../services/recipe_notebook_bridge.dart';

/// Katalog tarifini aile tarif defterine kopyalayan satır.
class AddToNotebookTile extends StatefulWidget {
  final FamilyRecipe Function() build;
  const AddToNotebookTile({super.key, required this.build});
  @override
  State<AddToNotebookTile> createState() => _AddToNotebookTileState();
}

class _AddToNotebookTileState extends State<AddToNotebookTile> {
  bool _busy = false;

  Future<void> _add() async {
    setState(() => _busy = true);
    String message;
    try {
      final notebook = await FamilyRecipeRepository.load();
      final (next, added) = RecipeNotebookBridge.add(notebook, widget.build());
      if (added) await FamilyRecipeRepository.save(next);
      message = added
          ? 'Tarif aile tarif defterine eklendi. Defterden düzenleyebilirsin.'
          : 'Bu tarif zaten aile tarif defterinde.';
    } catch (_) {
      message = 'Tarif defterine eklenemedi. Mevcut tarifler korunuyor.';
    }
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFF3E8FF),
    elevation: 0,
    child: ListTile(
      key: const ValueKey('add_to_notebook'),
      leading: const Icon(Icons.menu_book_outlined, color: Color(0xFF48235F)),
      title: const Text('Aile tarif defterime ekle'),
      subtitle: const Text('Kendi notlarınla düzenleyebileceğin bir kopya oluşturur.'),
      trailing: _busy
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.add),
      onTap: _busy ? null : _add,
    ),
  );
}
