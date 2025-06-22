import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: androidInitializationSettings);
      await _notificationsPlugin.initialize(initializationSettings);
      await _createNotificationChannels();

      tz.initializeTimeZones();
      String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      logger.i("✅ Notification Service Initialized Successfully");
    } catch (e) {
      logger.e("❌ Notification initialization failed: $e");
    }
  }

  static Future<void> _createNotificationChannels() async {
    try {
      const AndroidNotificationChannel vaccinationChannel = AndroidNotificationChannel(
        'vaccination_channel',
        'Vaccination Reminders',
        description: 'Reminders for scheduled vaccinations',
        importance: Importance.high,
      );
      const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
        'test_channel',
        'Test Notifications',
        description: 'Channel for test notifications',
        importance: Importance.max,
      );
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(vaccinationChannel);
      await androidPlugin?.createNotificationChannel(testChannel);
      logger.i("✅ Notification channels created");
    } catch (e) {
      logger.e("❌ Failed to create notification channels: $e");
    }
  }

  Future<bool> requestPermission() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt ?? 0;

      if (sdkVersion >= 33) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          logger.w("❌ Notifications permission denied.");
          return false;
        }
      }
      if (sdkVersion >= 31) {
        final alarmStatus = await Permission.scheduleExactAlarm.request();
        if (!alarmStatus.isGranted) {
          logger.w("⚠️ Exact alarm permission not granted.");
          return false;
        }
      }
      logger.i("✅ Notification permissions granted");
      return true;
    } catch (e) {
      logger.e("❌ Error requesting permissions: $e");
      return false;
    }
  }

  Future<void> showFCMNotification({
    required String childId,
    required String vaccineName,
    required String title,
    required String body,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        logger.w("⚠️ No user logged in, skipping notification.");
        return;
      }

      // عرض الإشعار محليًا
      await _notificationsPlugin.show(
        0,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'vaccination_channel',
            'Vaccination Reminders',
            channelDescription: 'Reminders for scheduled vaccinations',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );

      // حفظ الإشعار في Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': title,
        'message': body,
        'childId': childId,
        'vaccineName': vaccineName,
        'type': 'vaccination',
        'delivered': true,
        'timestamp': FieldValue.serverTimestamp(),
        'deliveredAt': DateTime.now().toIso8601String(),
        'scheduledTime': Timestamp.fromDate(DateTime.now()),
      });

      logger.i("✅ Immediate notification stored for $vaccineName");
    } catch (e) {
      logger.e("❌ Error showing/storing FCM notification: $e");
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
          ),
        ),
      );
      logger.i("✅ Test notification sent");
    } catch (e) {
      logger.e("❌ Error sending test notification: $e");
    }
  }

  Future<void> showLocalNotificationOnly({
    required String title,
    required String body,
  }) async {
    try {
      await _notificationsPlugin.show(
        0,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'vaccination_channel',
            'Vaccination Reminders',
            channelDescription: 'Reminders for scheduled vaccinations',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
      logger.i("🔔 Local-only notification shown");
    } catch (e) {
      logger.e("❌ Error showing local notification: $e");
    }
  }

  Future<void> scheduleNotification(
      String childId, String vaccineName, DateTime date) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        logger.w("⚠️ No user logged in, skipping notification scheduling.");
        return;
      }

      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(date, tz.local);

      // التحقق من وجود إشعار مكرر
      final existingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('vaccineName', isEqualTo: vaccineName)
          .where('childId', isEqualTo: childId)
          .where('scheduledTime', isEqualTo: Timestamp.fromDate(scheduledTime))
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        logger.i(
            "ℹ️ Notification for $vaccineName at $scheduledTime already exists, skipping.");
        return;
      }

      // حفظ الإشعار المجدول في Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': 'Vaccination Reminder',
        'message': 'Time for $vaccineName!',
        'childId': childId,
        'vaccineName': vaccineName,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'timestamp': FieldValue.serverTimestamp(),
        'delivered': false,
        'type': 'vaccination',
      });

      logger.i("⏰ Notification scheduled for $vaccineName at $scheduledTime");
    } catch (e) {
      logger.e("❌ Failed to schedule notification for $vaccineName: $e");
    }
  }
}