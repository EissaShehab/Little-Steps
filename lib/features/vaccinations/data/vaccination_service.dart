import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:littlesteps/features/notifications/data/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

final logger = Logger();

class VaccinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  VaccinationService() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      tz.initializeTimeZones();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await _localNotificationsPlugin.initialize(initializationSettings);

      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(alert: true, badge: true, sound: true);
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        logger.i("✅ Notifications permission granted.");
      } else {
        logger.w("❌ Notifications permission denied.");
      }

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'vaccination_channel',
        'Vaccination Reminders',
        description: 'Reminders for scheduled vaccinations',
        importance: Importance.high,
      );
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      logger.e("❌ Notification initialization failed: $e");
    }
  }

  Future<void> initializeVaccinationsForChild(
      String childId, DateTime birthDate) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        logger.w("❌ No user logged in to initialize vaccinations.");
        return;
      }

      // جلب جميع المطاعيم من مجموعة 'vaccinations'
      final snapshot = await _firestore.collection('vaccinations').get();
      if (snapshot.docs.isEmpty) {
        logger.w("⚠️ No vaccinations found in Firestore.");
        return;
      }

      // جلب المطاعيم الموجودة مسبقًا للطفل
      final existingVaccinesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .collection('vaccinations')
          .get();

      // إنشاء قائمة بأسماء المطاعيم الموجودة
      final existingVaccineNames = existingVaccinesSnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toSet();

      // حذف المطاعيم المكررة إذا وجدت
      final Map<String, List<DocumentSnapshot>> vaccineDocsByName = {};
      for (var doc in existingVaccinesSnapshot.docs) {
        final vaccineName = doc.data()['name'] as String;
        vaccineDocsByName.putIfAbsent(vaccineName, () => []).add(doc);
      }
      for (var entry in vaccineDocsByName.entries) {
        if (entry.value.length > 1) {
          // الاحتفاظ بأول مستند وحذف الباقي
          for (var i = 1; i < entry.value.length; i++) {
            await entry.value[i].reference.delete();
            logger.i("🗑️ Deleted duplicate vaccine ${entry.key} for child $childId");
          }
        }
      }

      for (var doc in snapshot.docs) {
        final vaccineData = doc.data();
        final vaccineName = vaccineData['name'] ?? '';

        // التحقق مما إذا كان المطعوم موجودًا بالفعل
        if (existingVaccineNames.contains(vaccineName)) {
          logger.i(
              "ℹ️ Vaccine $vaccineName already exists for child $childId, skipping.");
          continue;
        }

        // إضافة المطعوم إذا لم يكن موجودًا
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('children')
            .doc(childId)
            .collection('vaccinations')
            .add({
          'name': vaccineData['name'] ?? '',
          'name_ar': vaccineData['name_ar'] ?? '',
          'age': vaccineData['age'] ?? '',
          'age_ar': vaccineData['age_ar'] ?? '',
          'mandatory': vaccineData['mandatory'] ?? false,
          'status': 'UPCOMING',
          'admin_type': vaccineData['admin_type'] ?? 'injection',
          'conditions': vaccineData['conditions'] ?? [],
          'conditions_ar': vaccineData['conditions_ar'] ?? [],
          'description': vaccineData['description'] ?? '',
          'description_ar': vaccineData['description_ar'] ?? '',
          'ageRequirementInDays': vaccineData['ageRequirementInDays'] ?? 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        logger.i(
            "✅ Added vaccine $vaccineName for child $childId with status UPCOMING");
      }

      // جدولة الإشعارات بعد إضافة المطاعيم
      await scheduleVaccinationNotifications(childId, birthDate);
    } catch (e) {
      logger.e("❌ Error initializing vaccinations for child $childId: $e");
    }
  }

  Future<void> deleteVaccinationsForChild(String childId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .collection('vaccinations')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      logger.i("🗑️ Deleted existing vaccinations for child $childId");
    } catch (e) {
      logger.e("❌ Error deleting vaccinations for child $childId: $e");
    }
  }

  Future<void> updateVaccineStatus(
      String childId, String vaccineName, String status) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        logger.w("❌ No user logged in to update vaccine status.");
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .collection('vaccinations')
          .where('name', isEqualTo: vaccineName)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        logger
            .w("⚠️ No vaccine found with name $vaccineName for child $childId");
        return;
      }

      for (var doc in snapshot.docs) {
        await doc.reference.update(
            {'status': status, 'updatedAt': FieldValue.serverTimestamp()});
      }
      logger.i("✅ Vaccine $vaccineName marked as $status for child $childId");
    } catch (e) {
      logger.e("❌ Error updating vaccine status: $e");
    }
  }

  Future<void> scheduleVaccinationNotifications(
      String childId, DateTime birthDate) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .collection('vaccinations')
          .where('status', isEqualTo: 'UPCOMING')
          .get();

      final now = DateTime.now();
      final childAgeInDays = now.difference(birthDate).inDays;

      for (var doc in snapshot.docs) {
        final vaccine = doc.data();
        final String vaccineName = vaccine['name'];
        final int requirementDays = vaccine['ageRequirementInDays'] ?? 0;
        final DateTime vaccineDate =
            birthDate.add(Duration(days: requirementDays));
        final int daysSinceDue = now.difference(vaccineDate).inDays;

        if (requirementDays > childAgeInDays) {
          logger.i("⏩ $vaccineName is not due yet.");
          continue;
        }

        if (daysSinceDue > 14) {
          logger
              .w("⛔ $vaccineName is overdue by $daysSinceDue days. Skipping.");
          continue;
        }

        if (vaccineDate.isBefore(now)) {
          await NotificationService().showFCMNotification(
            childId: childId,
            vaccineName: vaccineName,
            title: 'Vaccination Reminder',
            body: 'Time for $vaccineName!',
          );
          logger.i("📢 Immediate FCM sent and stored for $vaccineName");
        } else {
          await _scheduleNotification(childId, vaccineName, vaccineDate);
          logger.i("⏰ Scheduled notification for $vaccineName at $vaccineDate");
        }
      }
    } catch (e) {
      logger.e("❌ Error in smart vaccination scheduler: $e");
    }
  }

  DateTime _calculateVaccinationDate(DateTime birthDate, String age) {
    try {
      if (age.toLowerCase() == 'at birth') {
        return birthDate;
      } else if (age.contains('months')) {
        int months = int.parse(age.split(' ')[0]);
        return _addMonths(birthDate, months);
      } else if (age.contains('years')) {
        int years = int.parse(age.split(' ')[0]);
        return _addMonths(birthDate, years * 12);
      } else {
        return birthDate;
      }
    } catch (e) {
      logger.w("⚠️ Error calculating vaccination date: $e");
      return birthDate;
    }
  }

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    final year = date.year + ((date.month + monthsToAdd - 1) ~/ 12);
    final month = (date.month + monthsToAdd - 1) % 12 + 1;
    final day = date.day;
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDayOfMonth ? lastDayOfMonth : day);
  }

  Future<void> _scheduleNotification(
      String childId, String vaccineName, DateTime date) async {
    try {
      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(date, tz.local);
      final userId = FirebaseAuth.instance.currentUser?.uid;

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

  Future<void> _sendFCMNotification(String userId, String childId,
      String vaccineName, DateTime scheduledTime) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        logger.w("⚠️ No FCM token found for user $userId");
        return;
      }

      final String serviceAccountJson =
          await rootBundle.loadString('assets/web2-e85d3-f2220b744a33.json');
      final Map<String, dynamic> serviceAccount =
          jsonDecode(serviceAccountJson);

      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await clientViaServiceAccount(credentials, scopes);

      final String projectId = serviceAccount['project_id'];
      final Uri url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

      final Map<String, dynamic> message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': 'Vaccination Reminder',
            'body': 'Time for $vaccineName!',
          },
          'data': {
            'childId': childId,
            'vaccineName': vaccineName,
            'type': 'vaccination',
          },
        },
      };

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        logger.i("✅ FCM message sent successfully for $vaccineName");
      } else {
        logger.e("❌ Failed to send FCM message: ${response.body}");
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': 'Vaccination Reminder',
        'message': 'Time for $vaccineName!',
        'childId': childId,
        'vaccineName': vaccineName,
        'type': 'vaccination',
        'delivered': true,
        'timestamp': FieldValue.serverTimestamp(),
        'deliveredAt': DateTime.now().toIso8601String(),
        'scheduledTime': Timestamp.fromDate(scheduledTime),
      });
      logger.i("✅ Immediate notification stored for $vaccineName");

      client.close();
    } catch (e) {
      logger.e("❌ Error sending/storing FCM notification: $e");
    }
  }

  Future<void> _updateFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'fcmToken': token});
      logger.i(
          "💡 ✅ Updated FCM token for user ${FirebaseAuth.instance.currentUser?.uid}");
    }
  }
}