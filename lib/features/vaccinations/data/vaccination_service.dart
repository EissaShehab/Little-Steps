import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:http/http.dart' as http;

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

      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
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
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      logger.e("❌ Notification initialization failed: $e");
    }
  }

  Future<void> updateVaccineStatus(String childId, String vaccineName, String status) async {
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
        logger.w("⚠️ No vaccine found with name $vaccineName for child $childId");
        return;
      }

      for (var doc in snapshot.docs) {
        await doc.reference.update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
      }
      logger.i("✅ Vaccine $vaccineName marked as $status for child $childId");
    } catch (e) {
      logger.e("❌ Error updating vaccine status: $e");
    }
  }

  Future<void> scheduleVaccinationNotifications(String childId, DateTime birthDate) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        logger.w("❌ No user logged in to schedule notifications.");
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .collection('vaccinations')
          .where('status', isEqualTo: 'upcoming')
          .get();

      if (snapshot.docs.isEmpty) {
        logger.w("⚠️ No upcoming vaccinations found for child: $childId");
        return;
      }

      for (var doc in snapshot.docs) {
        final vaccine = doc.data();
        final String vaccineName = vaccine['name'];
        final String age = vaccine['age'] ?? '0 months';

        final DateTime vaccinationDate = _calculateVaccinationDate(birthDate, age);
        if (vaccinationDate.isAfter(DateTime.now())) {
          await _scheduleNotification(childId, vaccineName, vaccinationDate);
        }
      }
    } catch (e) {
      logger.e("❌ Error scheduling notifications: $e");
    }
  }

  DateTime _calculateVaccinationDate(DateTime birthDate, String age) {
    try {
      if (age.contains('months')) {
        int months = int.parse(age.split(' ')[0]);
        return birthDate.add(Duration(days: months * 30));
      } else if (age.contains('years')) {
        int years = int.parse(age.split(' ')[0]);
        return birthDate.add(Duration(days: years * 365));
      } else {
        return birthDate;
      }
    } catch (e) {
      logger.w("⚠️ Error calculating vaccination date: $e");
      return birthDate;
    }
  }

  Future<void> _scheduleNotification(String childId, String vaccineName, DateTime date) async {
    try {
      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(date, tz.local);

      // Store in Firestore for FCM triggering
      final userId = FirebaseAuth.instance.currentUser?.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
        'title': 'Vaccination Reminder',
        'message': 'Time for $vaccineName!',
        'childId': childId,
        'vaccineName': vaccineName,
        'scheduledTime': scheduledTime.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
        'delivered': false,
      });

      // For testing: If the scheduled time is within 5 minutes, send an FCM message immediately
      if (scheduledTime.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
        await _sendFCMNotification(userId!, childId, vaccineName, scheduledTime);
        logger.i("✅ FCM notification sent for $vaccineName at $scheduledTime");
      } else {
        logger.i("⏳ FCM notification scheduled for $vaccineName at $scheduledTime (pending server-side trigger)");
      }
    } catch (e) {
      logger.e("❌ Failed to schedule notification for $vaccineName: $e");
    }
  }

  // Method to send FCM notification using V1 API
  Future<void> _sendFCMNotification(String userId, String childId, String vaccineName, DateTime scheduledTime) async {
    try {
      // Retrieve the user's FCM token from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        logger.w("⚠️ No FCM token found for user $userId");
        return;
      }

      // Load the service account JSON
      final String serviceAccountJson = await rootBundle.loadString('assets/web2-e85d3-f2220b744a33.json');
      final Map<String, dynamic> serviceAccount = jsonDecode(serviceAccountJson);

      // Create credentials
      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // Obtain an HTTP client with the credentials
      final client = await clientViaServiceAccount(credentials, scopes);

      // Construct the FCM V1 API endpoint
      final String projectId = serviceAccount['project_id'];
      final Uri url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

      // Construct the FCM message
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
          },
        },
      };

      // Send the message
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

      // Close the client
      client.close();
    } catch (e) {
      logger.e("❌ Error sending FCM notification: $e");
    }
  }

  Future<void> testNotification() async {
    try {
      await _localNotificationsPlugin.show(
        0,
        "Test Notification",
        "This is a manual test notification.",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Channel',
            channelDescription: 'For testing notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
      logger.i("✅ Test notification sent.");
    } catch (e) {
      logger.e("❌ Failed to send test notification: $e");
    }
  }
}