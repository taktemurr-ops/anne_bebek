import '../i18n/i18n.dart';
import 'family_notification_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'reminder_repository.dart';

/// Only opt-in reminders are scheduled. OS permissions and battery policies
/// can prevent delivery; these alerts must not be used for critical care.
class LocalReminderNotifications {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static int notificationId(String id) {
    // Stable positive 31-bit FNV-1a hash (same ID across restarts).
    var hash = 0x811c9dc5;
    for (final code in id.codeUnits) {
      hash = ((hash ^ code) * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  static Future<void> initialize() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(requestAlertPermission: false,
        requestBadgePermission: false, requestSoundPermission: false),
    ));
    _ready = true;
  }

  static Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    if (ios != null) return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    return false;
  }

  static Future<void> cancel(String id) async {
    await initialize();
    await _plugin.cancel(notificationId(id));
  }

  /// "Tüm yerel kayıtları sil" sonrasında planlanmış hiçbir hatırlatıcı
  /// kalmamalı; silinen kayda ait bildirim teslim edilmemeli.
  static Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  static Future<void> schedule(FamilyReminder reminder) async {
    await initialize();
    await cancel(reminder.id);
    if (!reminder.notify || reminder.completed || !reminder.due.isAfter(DateTime.now())) { return; }
    // Fail closed: no OS notification without persisted opt-in.
    final preferences = await FamilyNotificationRepository.load();
    if (!preferences.remindersEnabled ||
        preferences.isQuietHour(reminder.due.hour)) {
      return;
    }
    // Convert local instant to UTC for correct scheduling without device-zone lookup.
    final utcTime = tz.TZDateTime.from(reminder.due.toUtc(), tz.UTC);
    await _plugin.zonedSchedule(notificationId(reminder.id), t('Anne & Bebek'),
      reminder.title, utcTime,
      NotificationDetails(android: AndroidNotificationDetails(
        'family_reminders', t('Aile hatırlatıcıları'),
        channelDescription: t('İsteğe bağlı aile takvimi hatırlatıcıları'),
        importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  /// Her gün aynı saatte tekrarlanan hatırlatma (ilaç/vitamin). Kullanıcı
  /// bildirimleri açmadıysa planlanmaz.
  static Future<void> scheduleDaily(String id, String title, int hour, int minute) async {
    await initialize();
    await cancel(id);
    final preferences = await FamilyNotificationRepository.load();
    if (!preferences.remindersEnabled) return;
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    final utcTime = tz.TZDateTime.from(next.toUtc(), tz.UTC);
    await _plugin.zonedSchedule(notificationId(id), t('Anne & Bebek'), title, utcTime,
      NotificationDetails(android: AndroidNotificationDetails(
        'daily_medicine', t('İlaç ve vitamin'),
        channelDescription: t('Her gün tekrarlanan ilaç ve vitamin hatırlatmaları'),
        importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  static Future<void> sync(List<FamilyReminder> previous, List<FamilyReminder> next) async {
    final preferences = await FamilyNotificationRepository.load();
    if (!preferences.remindersEnabled) {
      for (final item in [...previous, ...next]) {
        await cancel(item.id);
      }
      return;
    }
    for (final item in previous) {
      if (!next.any((n) => n.id == item.id)) await cancel(item.id);
    }
    for (final item in next) {
      await schedule(item);
    }
  }
}
