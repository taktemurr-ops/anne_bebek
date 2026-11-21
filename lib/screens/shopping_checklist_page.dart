import '../utils/dialog_helpers.dart';
import 'package:flutter/material.dart';
import '../services/shopping_list.dart';
import '../services/shopping_list_repository.dart';

/// GP-06: Local, encrypted shopping checklist.
class ShoppingChecklistPage extends StatefulWidget {
  const ShoppingChecklistPage({super.key});
  @override
  State<ShoppingChecklistPage> createState() => _ShoppingChecklistPageState();
}

class _ShoppingChecklistPageState extends State<ShoppingChecklistPage> {
  List<ShoppingListItem> _items = [];
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await ShoppingListRepository.load();
      if (!mounted) return;
      setState(() { _items = items; _busy = false; _error = null; });
    } catch (_) {
      if (mounted) { setState(() {
        _busy = false;
        _error = 'Liste okunamadı. Kayıtlar korunuyor.';
      }); }
    }
  }

  Future<void> _persist(List<ShoppingListItem> updated) async {
    setState(() { _busy = true; _error = null; });
    try {
      await ShoppingListRepository.save(updated);
      if (mounted) { setState(() { _items = updated; }); }
    } catch (_) {
      if (mounted) { setState(() {
        _error = 'Değişiklik kaydedilemedi. Önceki liste korunuyor.';
      }); }
    } finally {
      if (mounted) { setState(() { _busy = false; }); }
    }
  }

  Future<void> _add() async {
    final controller = TextEditingController();
    final title = await showDialogAndDispose<String>(disposables: [controller], context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ürün ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          decoration: const InputDecoration(labelText: 'Ürün adı')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Ekle')),
        ],
      ));
    if (!mounted || title == null || title.isEmpty) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _persist([..._items, ShoppingListItem(id: id, title: title)]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Alışveriş listem')),
    floatingActionButton: _busy || _error != null ? null :
      FloatingActionButton.extended(onPressed: _add,
        icon: const Icon(Icons.add), label: const Text('Ürün ekle')),
    body: _busy ? const Center(child: CircularProgressIndicator()) :
      Column(children: [
        if (_error != null) Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text(_error!, style: TextStyle(
              color: Theme.of(context).colorScheme.error)),
            TextButton(onPressed: _load, child: const Text('Yeniden dene')),
          ])),
        Expanded(child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return CheckboxListTile(
              key: ValueKey(item.id),
              title: Text(item.title),
              subtitle: Text('Adet: ${item.quantity}'),
              value: item.completed,
              onChanged: _error != null ? null : (checked) {
                if (checked == null) return;
                final updated = [..._items];
                updated[index] = ShoppingListItem(id: item.id,
                  title: item.title, quantity: item.quantity,
                  completed: checked);
                _persist(updated);
              },
              secondary: IconButton(
                tooltip: 'Ürünü sil',
                onPressed: _error != null ? null : () {
                  _persist([..._items]..removeAt(index));
                },
                icon: const Icon(Icons.delete_outline)),
            );
          },
        )),
      ]),
  );
}
