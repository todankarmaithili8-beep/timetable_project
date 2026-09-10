import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int paccakhanNotificationId = 100;

  /// Initialize notifications
  static Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    // India Standard Time
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: initializationSettings);

    // Android 13+ notification permission
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  /// Schedule notification 15 minutes before Paccakhan
  static Future<void> schedulePaccakhanNotification({
    required String paccakhanName,
    required DateTime paccakhanTime,
  }) async {
    // 15 minutes before Paccakhan
    final notificationTime = paccakhanTime.subtract(
      const Duration(minutes: 15),
    );

    final now = DateTime.now();

    print('==========================================');
    print('Paccakhan Name  : $paccakhanName');
    print('Paccakhan Time  : $paccakhanTime');
    print('Current Time    : $now');
    print('Notification At : $notificationTime');
    print('==========================================');

    // If notification time has already passed, don't schedule
    if (!notificationTime.isAfter(now)) {
      print('❌ Notification time already passed.');
      return;
    }

    // Cancel previous Paccakhan notification
    await _notifications.cancel(id: paccakhanNotificationId);

    // Convert to India timezone
    final scheduledDate = tz.TZDateTime(
      tz.local,
      notificationTime.year,
      notificationTime.month,
      notificationTime.day,
      notificationTime.hour,
      notificationTime.minute,
      notificationTime.second,
    );

    const androidDetails = AndroidNotificationDetails(
      'paccakhan_channel',
      'Paccakhan Notifications',
      channelDescription: 'Notifications for upcoming Paccakhan timings',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id: paccakhanNotificationId,
      title: 'Upcoming Paccakhan',
      body: '$paccakhanName is coming in 15 minutes.',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    print('✅ Notification scheduled successfully!');
    print('🔔 Notification At : $scheduledDate');
    print('🕐 Paccakhan Time   : $paccakhanTime');
    print('==========================================');
  }

  /// Cancel Paccakhan notification
  static Future<void> cancelPaccakhanNotification() async {
    await _notifications.cancel(id: paccakhanNotificationId);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
