import 'package:flutter/material.dart';
import '../services/family_notification_preferences.dart';
import '../services/family_notification_repository.dart';

/// GP-09: Opt-in preferences only. Delivery integrations must honor these flags.
class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  FamilyNotificationPreferences _prefs = const FamilyNotificationPreferences();
  bool _busy = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final prefs = await FamilyNotificationRepository.load();
      if (!mounted) return;
      setState(() { _prefs = prefs; _error = null; _busy = false; });
    } catch (_) {
      if (mounted) setState(() {
        _busy = false; _error = 'Bildirim tercihleri okunamadı. Eski veriler korunuyor.';
      });
    }
  }

  Future<void> _save(FamilyNotificationPreferences updated) async {
    setState(() { _busy = true; _error = null; });
    try {
      await FamilyNotificationRepository.save(updated);
      if (mounted) setState(() => _prefs = updated);
    } catch (_) {
      if (mounted) setState(() {
        _error = 'Tercihler kaydedilemedi. Önceki tercihler korunuyor.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  FamilyNotificationPreferences _copy({
    bool? reminders, bool? community, bool? marketing,
    int? start, int? end,
  }) => FamilyNotificationPreferences(
    remindersEnabled: reminders ?? _prefs.remindersEnabled,
    communityEnabled: community ?? _prefs.communityEnabled,
    marketingEnabled: marketing ?? _prefs.marketingEnabled,
    quietStartHour: start ?? _prefs.quietStartHour,
    quietEndHour: end ?? _prefs.quietEndHour,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bildirim tercihlerim')),
    body: _busy ? const Center(child: CircularProgressIndicator()) :
      ListView(padding: const EdgeInsets.all(16), children: [
        const Card(child: Padding(padding: EdgeInsets.all(16),
          child: Text('Tüm bildirim kategorileri varsayılan olarak kapalıdır. '
            'Bu tercihler yalnızca kaydedilir; gönderim servislerinin ayrıca '
            'bu izinleri uygulaması gerekir.'))),
        if (_error != null) Card(child: ListTile(
          title: Text(_error!),
          trailing: TextButton(onPressed: _load, child: const Text('Tekrar dene')))),
        SwitchListTile(
          title: const Text('Aile hatırlatıcıları'),
          subtitle: const Text('Hatırlatıcı bildirimlerine izin ver'),
          value: _prefs.remindersEnabled,
          onChanged: _error != null ? null : (v) => _save(_copy(reminders: v))),
        SwitchListTile(
          title: const Text('Topluluk bildirimleri'),
          value: _prefs.communityEnabled,
          onChanged: _error != null ? null : (v) => _save(_copy(community: v))),
        SwitchListTile(
          title: const Text('Tanıtım ve kampanya bildirimleri'),
          value: _prefs.marketingEnabled,
          onChanged: _error != null ? null : (v) => _save(_copy(marketing: v))),
        const SizedBox(height: 16),
        const Text('Sessiz saatler', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<int>(
          value: _prefs.quietStartHour,
          decoration: const InputDecoration(labelText: 'Başlangıç'),
          items: [for (var h = 0; h < 24; h++)
            DropdownMenuItem(value: h, child: Text('${h.toString().padLeft(2, '0')}:00'))],
          onChanged: _error != null ? null : (v) {
            if (v != null) _save(_copy(start: v));
          }),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _prefs.quietEndHour,
          decoration: const InputDecoration(labelText: 'Bitiş'),
          items: [for (var h = 0; h < 24; h++)
            DropdownMenuItem(value: h, child: Text('${h.toString().padLeft(2, '0')}:00'))],
          onChanged: _error != null ? null : (v) {
            if (v != null) _save(_copy(end: v));
          }),
        const SizedBox(height: 12),
        const Text('Başlangıç ve bitiş aynıysa sessiz saat uygulanmaz.'),
      ]),
  );
}
