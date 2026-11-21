import '../utils/dialog_helpers.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';

import 'package:flutter/material.dart' hide Text;

import '../services/family_recipes.dart';
import '../services/family_recipe_repository.dart';

/// GP-07: Local recipes stored in platform encrypted storage.
class FamilyRecipeNotebookPage extends StatefulWidget {
  const FamilyRecipeNotebookPage({super.key});

  @override
  State<FamilyRecipeNotebookPage> createState() =>
      _FamilyRecipeNotebookPageState();
}

class _FamilyRecipeNotebookPageState extends State<FamilyRecipeNotebookPage> {
  List<FamilyRecipe> _recipes = [];
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final records = await FamilyRecipeRepository.load();
      if (!mounted) return;
      setState(() {
        _recipes = records;
        _error = null;
        _busy = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Tarifler okunamadı; kayıtlar değiştirilmedi.';
        });
      }
    }
  }

  Future<void> _save(List<FamilyRecipe> updated) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FamilyRecipeRepository.save(updated);
      if (mounted) {
        setState(() {
          _recipes = updated;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Tarif kaydedilemedi; eski kayıtlar korundu.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _add() async {
    final title = TextEditingController();
    final ingredients = TextEditingController();
    final instructions = TextEditingController();
    final minutes = TextEditingController(text: '20');
    {
      final result = await showDialogAndDispose<FamilyRecipe>(
        disposables: [title, ingredients, instructions, minutes],
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Yeni tarif'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  maxLength: 120,
                  decoration: InputDecoration(labelText: t('Tarif adı')),
                ),
                TextField(
                  controller: ingredients,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: t('Malzemeler (her satıra bir tane)'),
                  ),
                ),
                TextField(
                  controller: minutes,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: t('Hazırlama süresi (dk)'),
                  ),
                ),
                TextField(
                  controller: instructions,
                  maxLines: 4,
                  maxLength: 5000,
                  decoration: InputDecoration(labelText: t('Hazırlanışı')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                final list = ingredients.text
                    .split('\n')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                final duration = int.tryParse(minutes.text.trim());
                if (title.text.trim().isEmpty ||
                    title.text.runes.length > 120 ||
                    list.isEmpty ||
                    list.length > 100 ||
                    list.any((e) => e.runes.length > 120) ||
                    duration == null ||
                    duration < 1 ||
                    duration > 1440 ||
                    instructions.text.trim().isEmpty ||
                    instructions.text.runes.length > 5000) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Tarif alanlarını kontrol edin.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(
                  dialogContext,
                  FamilyRecipe(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    title: title.text.trim(),
                    ingredients: list,
                    preparationMinutes: duration,
                    instructions: instructions.text.trim(),
                  ),
                );
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      );
      if (result != null && mounted) await _save([..._recipes, result]);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aile tarif defterim')),
    floatingActionButton: _busy || _error != null
        ? null
        : FloatingActionButton.extended(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('Tarif ekle'),
          ),
    body: _busy
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Tekrar dene'),
                      ),
                    ],
                  ),
                ),
              if (_recipes.isEmpty && _error == null)
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Column(children: [
                    Text('📖', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 8),
                    Text('Aile tarif defterin henüz boş',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text('Annenden, kayınvalidenden öğrendiğin tarifleri “Tarif ekle” ile yaz. '
                        'Tarif detaylarındaki “Aile tarif defterime ekle” ile hazır tarifleri de buraya kaydedebilirsin.',
                        textAlign: TextAlign.center),
                  ]),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return Card(
                      child: ExpansionTile(
                        key: ValueKey(recipe.id),
                        title: Text(recipe.title),
                        subtitle: Text('${recipe.preparationMinutes} dakika'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Malzemeler',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                for (final ingredient in recipe.ingredients)
                                  Text('• $ingredient'),
                                const SizedBox(height: 12),
                                const Text(
                                  'Hazırlanışı',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(recipe.instructions),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: _error != null
                                        ? null
                                        : () => _save(
                                            [..._recipes]..removeAt(index),
                                          ),
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Tarifi sil'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
  );
}
