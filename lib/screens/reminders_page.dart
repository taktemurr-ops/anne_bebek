import '../utils/dialog_helpers.dart';
import '../services/family_notification_repository.dart';
import 'package:flutter/material.dart';
import '../services/reminder_repository.dart';
import '../services/local_reminder_notifications.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<FamilyReminder> reminders = [];
  bool busy = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { busy = true; error = null; });
    try {
      final items = await ReminderRepository.load();
      if (mounted) { setState(() { reminders = items; busy = false; }); }
    } catch (_) {
      if (mounted) { setState(() {
        busy = false;
        error = 'Hatırlatıcılar okunamadı. Kayıtlar değiştirilmedi.';
      }); }
    }
  }

  Future<void> _save(List<FamilyReminder> next) async {
    setState(() { busy = true; error = null; });
    try {
      await ReminderRepository.save(next);
      try {
        await LocalReminderNotifications.sync(reminders, next);
      } catch (_) {
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kayıt saklandı, ancak telefon bildirimi ayarlanamadı.'))); }
      }
      if (mounted) { setState(() { reminders = ReminderRepository.decode(
        ReminderRepository.encode(next)); busy = false; }); }
    } catch (_) {
      if (mounted) { setState(() {
        busy = false;
        error = 'Değişiklik kaydedilemedi. Önceki kayıtlar korundu.';
      }); }
    }
  }

  Future<void> _add() async {
    final controller = TextEditingController();
    DateTime selected = DateTime.now().add(const Duration(days: 1));
    bool notify = false;
    final result = await showDialogAndDispose<FamilyReminder>(disposables: [controller], context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, update) => AlertDialog(
          title: const Text('Hatırlatıcı ekle'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: controller, maxLength: 120,
              decoration: const InputDecoration(labelText: 'Başlık')),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(context: dialogContext,
                  initialDate: selected, firstDate: DateTime(2020),
                  lastDate: DateTime(2100));
                if (date != null) { update(() => selected = DateTime(
                  date.year, date.month, date.day, selected.hour, selected.minute)); }
              },
              icon: const Icon(Icons.calendar_month),
              label: Text('${selected.day}.${selected.month}.${selected.year}'),
            ),
            OutlinedButton.icon(onPressed: () async {
              final time = await showTimePicker(context: dialogContext,
                initialTime: TimeOfDay.fromDateTime(selected));
              if (time != null) { update(() => selected = DateTime(selected.year,
                selected.month, selected.day, time.hour, time.minute)); }
            }, icon: const Icon(Icons.access_time),
              label: Text('${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}')),
            CheckboxListTile(
              title: const Text('Telefon bildirimi gönder'),
              value: notify,
              onChanged: (value) => update(() => notify = value ?? false),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç')),
            FilledButton(onPressed: () {
              final title = controller.text.trim();
              if (title.isEmpty) return;
              Navigator.pop(dialogContext, FamilyReminder(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: title, due: selected, notify: notify));
            }, child: const Text('Ekle')),
          ],
        )));
    if (result != null && mounted) {
      if (result.notify) {
        bool allowed = false;
        try {
          final preferences = await FamilyNotificationRepository.load();
          if (preferences.remindersEnabled) {
            allowed = await LocalReminderNotifications.requestPermission();
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Önce Bildirim tercihlerim ekranından aile hatırlatıcılarına izin verin.')));
          }
        } catch (_) {
          if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Bildirim tercihleri doğrulanamadı. Telefon bildirimi kapalı tutuldu.'))); }
        }
        if (!allowed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Bildirim izni verilmedi. Hatırlatıcı uygulama içinde saklandı.')));
        }
        final effective = FamilyReminder(id: result.id, title: result.title,
          due: result.due, notify: allowed);
        await _save([...reminders, effective]);
      } else {
        await _save([...reminders, result]);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aile hatırlatıcıları')),
    floatingActionButton: busy || error != null ? null : FloatingActionButton.extended(
      onPressed: _add, icon: const Icon(Icons.add), label: const Text('Ekle')),
    body: busy ? const Center(child: CircularProgressIndicator()) :
      error != null ? Center(child: Column(mainAxisSize: MainAxisSize.min,
        children: [Text(error!), TextButton(onPressed: _load,
          child: const Text('Tekrar dene'))])) :
      ListView(padding: const EdgeInsets.all(16), children: [
        const Card(child: Padding(padding: EdgeInsets.all(14),
          child: Text('Telefon bildirimi isteğe bağlıdır ve izin gerektirir. '
            'Pil kısıtlamaları nedeniyle bildirim gecikebilir. Acil sağlık durumları veya '
            'ilaç takibi için tek başına kullanılmamalıdır.'))),
        if (reminders.isEmpty) const Padding(padding: EdgeInsets.all(24),
          child: Center(child: Text('Henüz hatırlatıcı eklenmedi.'))),
        for (final item in reminders) Card(child: CheckboxListTile(
          key: ValueKey('reminder_${item.id}'),
          value: item.completed,
          title: Text(item.title),
          subtitle: Text('${item.due.day}.${item.due.month}.${item.due.year} ${item.due.hour.toString().padLeft(2, '0')}:${item.due.minute.toString().padLeft(2, '0')}${item.notify ? ' • Bildirim açık' : ''}'
            '${!item.completed && item.due.isBefore(DateTime.now()) ? ' • Tarihi geçti' : ''}'),
          secondary: IconButton(tooltip: 'Sil', icon: const Icon(Icons.delete_outline),
            onPressed: () => _save(reminders.where((e) => e.id != item.id).toList())),
          onChanged: (checked) => _save([
            for (final e in reminders)
              if (e.id == item.id) FamilyReminder(id: e.id, title: e.title,
                due: e.due, completed: checked ?? false, notify: e.notify) else e,
          ]),
        )),
        const SizedBox(height: 80),
      ]),
  );
}
