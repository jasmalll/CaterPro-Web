import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/catering_models.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Local notifications are currently implemented for Android only.
    // Skip the native plugin on Web so it cannot interrupt app startup.
    if (kIsWeb) return;
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  // തലേദിവസം രാത്രി 8 മണിക്ക് അലാറം ഷെഡ്യൂൾ ചെയ്യുന്നു
  static Future<void> scheduleWorkReminder(WorkItem work) async {
    if (kIsWeb) return;
    final eventDate = work.date;
    final dayBefore = eventDate.subtract(const Duration(days: 1));
    final scheduledDateTime = DateTime(
      dayBefore.year,
      dayBefore.month,
      dayBefore.day,
      20, // 8:00 PM
      0,
    );

    // സമയം കഴിഞ്ഞുപോയ തീയതിയാണെങ്കിൽ ഷെഡ്യൂൾ ചെയ്യേണ്ടതില്ല
    if (scheduledDateTime.isBefore(DateTime.now())) {
      return;
    }

    final int notificationId = work.id.hashCode.abs() % 100000;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'caterpro_work_reminders',
      'Work Reminders',
      channelDescription: 'Catering work reminders scheduled the previous night at 8 PM',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      '🔔 Naalathe Catering Work Reminder!',
      '${work.venue} (${work.location})\nReporting Time: ${work.reportingTime}',
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // വർക്ക് ഡിലീറ്റ് ചെയ്യുമ്പോൾ നോട്ടിഫിക്കേഷൻ റദ്ദാക്കുന്നു
  static Future<void> cancelWorkReminder(String workId) async {
    if (kIsWeb) return;
    final int notificationId = workId.hashCode.abs() % 100000;
    await _notificationsPlugin.cancel(notificationId);
  }
}