import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Bildirishnomalarni sozlash
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Bildirishnomaga bosilganda
      },
    );

    _initialized = true;
  }

  // Mavsumiy eslatgichni yoqish/o'chirish
  static Future<void> toggleSeasonalReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seasonal_reminders', enabled);

    if (enabled) {
      await _scheduleSeasonalReminders();
    } else {
      await cancelAllNotifications();
    }
  }

  // Mavsumiy eslatgichlar holatini olish
  static Future<bool> getSeasonalRemindersStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seasonal_reminders') ?? false;
  }

  // Mavsumiy eslatgichlarni rejalashtirish
  static Future<void> _scheduleSeasonalReminders() async {
    // Har oyning 1-kuni soat 9:00 da eslatma
    await _scheduleMonthlyReminder(
      id: 1,
      title: '🌱 Mavsumiy eslatma',
      body:
          'Yangi oy boshlandi! Bog\'ingiz uchun mavsumiy maslahatlarni ko\'ring.',
      hour: 9,
      minute: 0,
    );

    // Har haftaning dushanba kuni soat 8:00 da
    await _scheduleWeeklyReminder(
      id: 2,
      title: '🌿 Haftalik eslatma',
      body: 'Bog\'ingizni tekshiring va kerakli ishlarni bajaring.',
      dayOfWeek: 1, // Dushanba
      hour: 8,
      minute: 0,
    );
  }

  // Oylik eslatma
  static Future<void> _scheduleMonthlyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfMonthly(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'seasonal_reminders',
          'Mavsumiy eslatmalar',
          channelDescription: 'Bog\'bonchilik uchun mavsumiy eslatmalar',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  // Haftalik eslatma
  static Future<void> _scheduleWeeklyReminder({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeekly(dayOfWeek, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_reminders',
          'Haftalik eslatmalar',
          channelDescription: 'Bog\'bonchilik uchun haftalik eslatmalar',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Keyingi oylik vaqtni hisoblash
  static TZDateTime _nextInstanceOfMonthly(int hour, int minute) {
    final now = TZDateTime.now(local);
    var scheduledDate = TZDateTime(local, now.year, now.month, 1, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = TZDateTime(
        local,
        now.year,
        now.month + 1,
        1,
        hour,
        minute,
      );
    }

    return scheduledDate;
  }

  // Keyingi haftalik vaqtni hisoblash
  static TZDateTime _nextInstanceOfWeekly(int dayOfWeek, int hour, int minute) {
    final now = TZDateTime.now(local);
    var scheduledDate = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Darhol bildirishnoma ko'rsatish
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notifications',
          'Darhol bildirishnomalar',
          channelDescription: 'Darhol ko\'rsatiladigan bildirishnomalar',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Barcha bildirishnomalarni bekor qilish
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Muayyan bildirishnomani bekor qilish
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}

// Timezone uchun
final tz.Location local = tz.getLocation('Asia/Tashkent');

typedef TZDateTime = tz.TZDateTime;

// Timezone ni sozlash
Future<void> initializeTimezone() async {
  tz.initializeTimeZones();
}
