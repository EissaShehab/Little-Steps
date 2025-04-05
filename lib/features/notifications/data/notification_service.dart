import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

final logger = Logger();

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await _notificationsPlugin.initialize(initializationSettings);
      await _createNotificationChannel();

      tz.initializeTimeZones();
      String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      logger.i("✅ Notification Service Initialized Successfully");
    } catch (e) {
      logger.e("❌ Notification initialization failed: $e");
      throw Exception('Failed to initialize notifications: $e');
    }
  }

  static Future<void> _createNotificationChannel() async {
    try {
      final AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'vaccination_channel',
        'Vaccination Reminders',
        description: 'Reminders for scheduled vaccinations',
        importance: Importance.high,
      );
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      logger.i("✅ Notification channel created: vaccination_channel");
    } catch (e) {
      logger.e("❌ Failed to create notification channel: $e");
      throw Exception('Failed to create notification channel: $e');
    }
  }

  Future<void> requestPermission() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt ?? 0;

      if (sdkVersion >= 33) {
        final status = await Permission.notification.request();
        if (status.isGranted) {
          logger.i("✅ Notifications permission granted.");
        } else {
          logger.w("❌ Notifications permission denied.");
        }
      } else {
        logger.i("ℹ️ Notifications permission not required for API < 33.");
      }

      if (sdkVersion >= 31) {
        final alarmStatus = await Permission.scheduleExactAlarm.status;
        if (!alarmStatus.isGranted) {
          logger.w("⚠️ Exact alarm permission not granted; using inexact scheduling.");
        }
      }
    } catch (e) {
      logger.e("❌ Error requesting permission: $e");
      throw Exception('Failed to request permission: $e');
    }
  }

  Future<void> sendTestNotification() async {
    try {
      await _notificationsPlugin.show(
        9999,
        "Immediate Test Notification",
        "If you see this, notifications are working.",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Channel for test notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
      logger.i("✅ Immediate test notification sent.");
    } catch (e) {
      logger.e("❌ Failed to send test notification: $e");
      throw Exception('Failed to send test notification: $e');
    }
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    try {
      final DateTime now = DateTime.now();
      if (scheduledDate.isBefore(now.add(const Duration(seconds: 5)))) {
        logger.w("🚨 Scheduled time too soon! Adjusting to 5 seconds delay.");
        scheduledDate = now.add(const Duration(seconds: 5));
      }

      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt ?? 0;

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'vaccination_channel',
            'Vaccination Reminders',
            channelDescription: 'Reminders for scheduled vaccinations',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: sdkVersion >= 31
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      logger.i("✅ Notification for $title scheduled at $scheduledDate");
    } catch (e) {
      logger.e("❌ Failed to schedule notification for $title: $e");
      throw Exception('Failed to schedule notification: $e');
    }
  }

  Future<void> showFCMNotification({required String title, required String body}) async {
    try {
      await _notificationsPlugin.show(
        0, // Unique ID for FCM notifications
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'vaccination_channel',
            'Vaccination Reminders',
            channelDescription: 'Reminders for scheduled vaccinations',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
      logger.i("✅ FCM notification shown: $title - $body");
    } catch (e) {
      logger.e("❌ Failed to show FCM notification: $e");
      throw Exception('Failed to show FCM notification: $e');
    }
  }
}