/* // ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationAPI {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<NotificationDetails> _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "channel id",
        "channel name",
        channelDescription: "channel description",
        importance: Importance.max,
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime sheduledDate,
  }) async {
    return _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        sheduledDate,
        tz.local,
      ),
      await _notificationDetails(),
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<List<PendingNotificationRequest>> pendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _notifications.pendingNotificationRequests();

    return pendingNotificationRequests;
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> init() async {
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iOS = IOSInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _notifications.initialize(settings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Europe/Berlin"));
  }
}
 */