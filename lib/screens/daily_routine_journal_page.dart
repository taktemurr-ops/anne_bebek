import 'package:flutter/material.dart';
import '../services/daily_routines.dart';
import '../services/daily_routine_repository.dart';

/// GP-04: Daily routines are isolated by child ID.
class DailyRoutineJournalPage extends StatefulWidget {
  final String childId;
  const DailyRoutineJournalPage({super.key, required this.childId});

  @override
  State<DailyRoutineJournalPage> createState() => _DailyRoutineJournalPageState();
}

class _DailyRoutineJournalPageState extends State<DailyRoutineJournalPage> {
  List<DailyRoutineEntry> _all = [];
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await DailyRoutineRepository.load();
      if (!mounted) return;
      setState(() { _all = items; _busy = false; _error = null; });
    } catch (_) {
      if (mounted) setState(() {
        _busy = false; _error = 'Kayıtlar okunamadı; veriler korunuyor.';
      });
    }
  }

  Future<void> _save(List<DailyRoutineEntry> updated) async {
    setState(() { _busy = true; _error = null; });
    try {
      await DailyRoutineRepository.save(updated);
      if (mounted) setState(() { _all = updated; });
    } catch (_) {
      if (mounted) setState(() {
        _error = 'Kaydetme başarısız; önceki kayıtlar korundu.';
      });
    } finally {
      if (mounted) setState(() { _busy = false; });
    }
  }

  Future<void> _add(String kind) async {
    final note = TextEditingController();
    final amount = TextEditingController();
    final duration = TextEditingController(text: '60');
    try {
      final entry = await showDialog<DailyRoutineEntry>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_label(kind)),
          content: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kind == 'feeding') TextField(controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Miktar (ml)')),
              if (kind == 'sleep') TextField(controller: duration,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Uyku süresi (dakika)')),
              TextField(controller: note, maxLength: 300, maxLines: 2,
                decoration: const InputDecoration(labelText: 'Not (isteğe bağlı)')),
            ],
          )),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç')),
            FilledButton(onPressed: () {
              final ml = kind == 'feeding'
                ? double.tryParse(amount.text.trim().replaceAll(',', '.')) : null;
              final minutes = kind == 'sleep'
                ? int.tryParse(duration.text.trim()) : null;
              if ((kind == 'feeding' && (ml == null || !ml.isFinite ||
                    ml <= 0 || ml > 2000)) ||
                  (kind == 'sleep' && (minutes == null ||
                    minutes < 1 || minutes > 1440))) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Miktar veya süre geçersiz.')));
                return;
              }
              final now = DateTime.now();
              Navigator.pop(dialogContext, DailyRoutineEntry(
                id: now.microsecondsSinceEpoch.toString(),
                childId: widget.childId, kind: kind,
                startedAt: kind == 'sleep'
                  ? now.subtract(Duration(minutes: minutes!)) : now,
                endedAt: kind == 'sleep' ? now : null,
                amountMl: ml, note: note.text.trim()));
            }, child: const Text('Kaydet')),
          ],
        ),
      );
      if (entry != null && mounted) await _save([..._all, entry]);
    } finally {
      note.dispose(); amount.dispose(); duration.dispose();
    }
  }

  String _label(String kind) => switch (kind) {
    'sleep' => 'Uyku', 'feeding' => 'Beslenme',
    'diaper' => 'Bez', _ => 'Not',
  };

  @override
  Widget build(BuildContext context) {
    final items = _all.where((e) => e.childId == widget.childId).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük yaşam kayıtları')),
      body: _busy ? const Center(child: CircularProgressIndicator()) :
        Column(children: [
          if (_error != null) Padding(padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text(_error!, style: TextStyle(
                color: Theme.of(context).colorScheme.error)),
              TextButton(onPressed: _load, child: const Text('Tekrar dene')),
            ])),
          Wrap(spacing: 8, children: [
            for (final kind in ['sleep', 'feeding', 'diaper', 'note'])
              ActionChip(label: Text('+ ${_label(kind)}'),
                onPressed: _busy || _error != null ? null : () => _add(kind)),
          ]),
          Expanded(child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                key: ValueKey(item.id),
                title: Text(_label(item.kind)),
                subtitle: Text([
                  item.startedAt.toLocal().toString().substring(0, 16),
                  if (item.amountMl != null) '${item.amountMl} ml',
                  if (item.note.isNotEmpty) item.note,
                ].join(' · ')),
                trailing: IconButton(
                  tooltip: 'Kaydı sil',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _error != null ? null : () =>
                    _save([..._all]..removeWhere((e) => e.id == item.id &&
                      e.childId == widget.childId))),
              );
            },
          )),
        ]),
    );
  }
}
