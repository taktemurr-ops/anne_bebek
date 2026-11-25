import 'dart:convert';
import 'i18n/i18n.dart' show t;
import 'i18n/text.dart';
import 'package:flutter/material.dart' hide Text;
import 'services/secure_health_store.dart';
import 'services/cycle_statistics.dart';

/// Keeps a private, local log. It does not predict ovulation or diagnose illness.
class CycleTrackerPage extends StatefulWidget {
  const CycleTrackerPage({super.key});

  @override
  State<CycleTrackerPage> createState() => _CycleTrackerPageState();
}

class _CycleTrackerPageState extends State<CycleTrackerPage> {
  static const _key = 'cycle_history_v1';
  final List<DateTime> _dates = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final decoded = decodeCycleDates(await SecureHealthStore.read(_key));
      if (!mounted) return;
      setState(() { _dates.addAll(decoded); _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Kayıtlar açılamadı; mevcut veriler silinmedi.'; _loading = false; });
    }
  }

  Future<void> _save() async {
    await SecureHealthStore.write(_key, jsonEncode(_dates.map((d) => d.toIso8601String()).toList()));
  }

  Future<void> _commit(List<DateTime> previous) async {
    try { await _save(); }
    catch (_) {
      if (!mounted) return;
      setState(() { _dates..clear()..addAll(previous); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt saklanamadı; işlem geri alındı.')));
    }
  }

  Future<void> _edit(DateTime old) async {
    final chosen = await showDatePicker(context: context, initialDate: old,
      firstDate: DateTime(2000), lastDate: DateTime.now(), helpText: t('Başlangıç tarihini düzenle'));
    if (chosen == null || !mounted) return;
    final next = DateTime(chosen.year, chosen.month, chosen.day);
    if (next != old && _dates.contains(next)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu tarih zaten kayıtlı.')));
      return;
    }
    final previous = List<DateTime>.from(_dates);
    setState(() { _dates.remove(old); _dates.add(next); _dates.sort((a,b)=>b.compareTo(a)); });
    await _commit(previous);
  }

  Future<void> _add() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: t('Adet başlangıç tarihini seç'),
    );
    if (date == null || !mounted) return;
    final normalized = DateTime(date.year, date.month, date.day);
    if (_dates.any((d) => d == normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu tarih zaten kayıtlı.')),
      );
      return;
    }
    final previous = List<DateTime>.from(_dates);
    setState(() {
      _dates.add(normalized);
      _dates.sort((a, b) => b.compareTo(a));
    });
    await _commit(previous);
  }

  Future<void> _remove(DateTime date) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Kaydı sil?'), content: Text(_format(date)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil'))]));
    if (confirmed != true || !mounted) return;
    final previous = List<DateTime>.from(_dates);
    setState(() => _dates.remove(date));
    await _commit(previous);
  }

  String _format(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  @override
  Widget build(BuildContext context) {
    final stats = summarizeCycleStarts(_dates);
    return Scaffold(
        appBar: AppBar(title: const Text('Adet döngüsü geçmişim')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null ? Center(child: Text(_error!)) : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Adet başlangıç tarihlerini kişisel günlüğüne kaydet. '
                        'Bu kayıtlar cihazın korumalı yerel depolamasında saklanır; '
                        'otomatik bulut yedeklemesi yapılmaz. '
                        'Döngü tahmini, doğurganlık hesabı ya da tıbbi değerlendirme yapılmaz.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add),
                    label: const Text('Başlangıç tarihi ekle'),
                  ),
                  const SizedBox(height: 16),
                  Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Geçmiş döngü özeti', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(stats.count == 0 ? 'Ortalama için en az iki başlangıç tarihi ekleyin.'
                        : 'Ölçülen aralık: ${stats.count} • Ortalama: ${stats.averageDays!.toStringAsFixed(1)} gün\n'
                          'En kısa: ${stats.shortestDays} gün • En uzun: ${stats.longestDays} gün'),
                      const SizedBox(height: 6),
                      const Text('Yalnızca girilen tarihler arasındaki geçmiş aralıkları özetler. Tahmin veya doğum kontrolü amacıyla kullanmayın.'),
                    ]))),
                  const SizedBox(height: 12),
                  Text('Kayıtlar (${_dates.length})',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (_dates.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Henüz başlangıç tarihi eklenmedi.'),
                    ),
                  for (final date in _dates)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(_format(date)),
                        subtitle: const Text('Adet başlangıcı'),
                        onTap: () => _edit(date),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(tooltip: t('Düzenle'), icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(date)),
                          IconButton(tooltip: t('Kaydı sil'), icon: const Icon(Icons.delete_outline), onPressed: () => _remove(date)),
                        ]),
                      ),
                    ),
                ],
              ),
      );
  }
}

/// Ignores damaged or malformed entries rather than crashing the screen.
List<DateTime> decodeCycleDates(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    final dates = <DateTime>{};
    for (final entry in decoded) {
      if (entry is! String) continue;
      final date = DateTime.tryParse(entry);
      if (date == null || date.isAfter(DateTime.now())) continue;
      dates.add(DateTime(date.year, date.month, date.day));
    }
    return dates.toList()..sort((a, b) => b.compareTo(a));
  } catch (_) {
    return [];
  }
}
