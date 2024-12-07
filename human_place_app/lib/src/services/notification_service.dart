import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleDailyNotification(TimeOfDay time) async {
    final now = DateTime.now();
    final scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Convertir a tz.TZDateTime
    final tz.TZDateTime adjustedTime = scheduleTime.isBefore(now)
        ? tz.TZDateTime.from(scheduleTime.add(Duration(days: 1)), tz.local)
        : tz.TZDateTime.from(scheduleTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      0,
      '¡Hora de regar tu planta!',
      'No olvides regar tu planta para que siga creciendo 🌱',
      adjustedTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Recordatorios diarios',
          channelDescription: 'Notificaciones para regar tu planta',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      //androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
