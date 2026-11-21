import 'package:flutter/material.dart' hide Text;
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/reproductive_calendar_repository.dart';
import '../services/reproductive_calendar_settings.dart';
import '../utils/reproductive_calendar.dart';

/// GP-05: Private pregnancy and cycle calendar. Estimates are informational.
class ReproductiveCalendarPage extends StatefulWidget {
  const ReproductiveCalendarPage({super.key});

  @override
  State<ReproductiveCalendarPage> createState() => _ReproductiveCalendarPageState();
}

class _ReproductiveCalendarPageState extends State<ReproductiveCalendarPage> {
  DateTime? _periodStart;
  int _cycleDays = 28;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await ReproductiveCalendarRepository.load();
      if (!mounted) return;
      setState(() {
        _periodStart = settings?.lastMenstrualPeriod;
        _cycleDays = settings?.cycleDays ?? 28;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _busy = false; _error = 'Kayıtlar okunamadı. Veriler değiştirilmedi.'; });
    }
  }

  Future<void> _save() async {
    setState(() { _busy = true; _error = null; });
    try {
      await ReproductiveCalendarRepository.save(ReproductiveCalendarSettings(
        lastMenstrualPeriod: _periodStart, cycleDays: _cycleDays));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgiler güvenli şekilde kaydedildi.')));
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Kaydetme başarısız. Lütfen tekrar deneyin.'; });
    } finally {
      if (mounted) { setState(() { _busy = false; }); }
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(context: context,
      initialDate: _periodStart != null && !_periodStart!.isAfter(today)
        ? _periodStart! : today,
      firstDate: DateTime(1900), lastDate: today);
    if (selected != null && mounted) setState(() => _periodStart = selected);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final age = _periodStart == null ? null : ReproductiveCalendar.gestationalAge(
      lastMenstrualPeriod: _periodStart!, asOf: today);
    final due = _periodStart == null ? null : ReproductiveCalendar.estimatedDueDate(
      _periodStart!, asOf: today);
    return Scaffold(
      appBar: AppBar(title: const Text('Gebelik ve Döngü Takvimi')),
      body: _busy ? const Center(child: CircularProgressIndicator()) :
      ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Bu hesaplamalar tahminidir; tıbbi değerlendirme yerine geçmez.'),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: _pickDate,
          child: Text(_periodStart == null ? 'Son adet tarihini seç' :
            'Son adet: ${_periodStart!.day}.${_periodStart!.month}.${_periodStart!.year}')),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(initialValue: _cycleDays,
          decoration: InputDecoration(labelText: t('Döngü uzunluğu (gün)')),
          items: [for (var days = 21; days <= 35; days++)
            DropdownMenuItem(value: days, child: Text('$days gün'))],
          onChanged: (value) { if (value != null) setState(() => _cycleDays = value); }),
        const SizedBox(height: 16),
        if (age != null) Text('Tahmini gebelik haftası: ${age.weeks} hafta ${age.days} gün'),
        if (due != null) Text('Tahmini doğum tarihi: ${due.day}.${due.month}.${due.year}'),
        if (_periodStart != null) Text('Tahmini sonraki adet: ${_formatNextPeriod()}'),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: const Text('Güvenli kaydet')),
      ]),
    );
  }

  String _formatNextPeriod() {
    final next = ReproductiveCalendar.nextPeriodStart(_periodStart!, _cycleDays);
    return next == null ? 'Hesaplanamadı' : '${next.day}.${next.month}.${next.year}';
  }
}
