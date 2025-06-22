// ✅ 📂 lib/features/weather/data/weather_alert_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class WeatherAlertService {
  static Future<void> checkAndSendWeatherAlert(ChildProfile child) async {
    try {
      logger.i("\uD83C\uDF27️ Starting weather alert check for ${child.name}");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          logger.w("\u274C Location permission denied.");
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = position.latitude;
      final lon = position.longitude;
      logger.i("\uD83D\uDCCD Location: lat=$lat, lon=$lon");

      final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true',
      ));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final weather = data['current_weather'];
      final temp = weather['temperature'].toDouble();
      logger.i("\uD83C\uDF21️ Current temp: $temp °C");

      final alert = _generateAlert(temp, child.birthDate);
      logger.i(
          "\uD83D\uDC76 Child age: ${DateTime.now().difference(child.birthDate).inDays ~/ 30} months");
      logger.i("\u203C️ Generated alert: '$alert'");

      if (alert.isEmpty) {
        logger.i("\u2705 No alert needed for ${child.name}.");
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final notifRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications');

      final recent = await notifRef
          .where('type', isEqualTo: 'weather')
          .where('childId', isEqualTo: child.id)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (recent.docs.isNotEmpty) {
        final lastTime =
            (recent.docs.first.data()['timestamp'] as Timestamp).toDate();
        if (DateTime.now().difference(lastTime).inHours < 4) {
          logger.i(
              "\uD83D\uDD52 Skipping weather alert for ${child.name}: already sent recently.");
          return;
        }
      }

      await notifRef.add({
        'title': '⚠️ طقس غير مناسب لطفلك',
        'message': alert,
        'timestamp': DateTime.now(),
        'type': 'weather',
        'childId': child.id,
        'delivered': false,
      });

      logger.i("\u2705 Weather alert saved to Firestore for ${child.name}");

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final fcmToken = userDoc.data()?['fcmToken'];
      if (fcmToken != null) {
        await sendFCMDirectly(
          token: fcmToken,
          title: '⚠️ طقس غير مناسب لطفلك',
          body: alert,
          data: {
            'type': 'weather',
            'childId': child.id,
          },
        );
        logger.i("\uD83D\uDCF2 Sent FCM push directly for weather alert.");
      }
    } catch (e) {
      logger.e("\u274C Failed to check/send weather alert: $e");
    }
  }

  static String _generateAlert(double temp, DateTime birthDate) {
    final months = DateTime.now().difference(birthDate).inDays ~/ 30;

    if (temp <= 10) {
      return months <= 24
          ? '❄️ خطر انخفاض حرارة الجسم للرضع والأطفال. يرجى تدفئة الطفل جيدًا.'
          : '❄️ الطقس شديد البرودة. يرجى الحذر عند الخروج.';
    } else if (temp > 10 && temp <= 18) {
      return months <= 12
          ? '⚠️ الطقس بارد للأطفال الرضع. تأكد من تغطية الطفل بشكل مناسب.'
          : '';
    } else if (temp >= 33) {
      return months <= 60
          ? '🔥 حرارة مرتفعة جدًا. تأكد من بقاء الطفل في مكان بارد ورطّب جيدًا.'
          : '🔥 الطقس حار جدًا. قلل من التعرض للشمس.';
    } else if (temp >= 26 && temp <= 32 && months <= 36) {
      return '⚠️ الطقس حار نسبيًا، قد يسبب عدم ارتياح للأطفال الصغار.';
    }

    return '';
  }
}

Future<void> sendFCMDirectly({
  required String token,
  required String title,
  required String body,
  required Map<String, String> data,
}) async {
  const String serverKey = 'AIzaSyDKQSNlhnZuT8WR6DTRx5tMb1Y27oq9Q1o';
  final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

  final message = {
    'to': token,
    'notification': {
      'title': title,
      'body': body,
    },
    'data': data,
  };

  await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode(message),
  );
}
