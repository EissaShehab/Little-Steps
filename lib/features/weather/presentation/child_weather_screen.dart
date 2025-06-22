import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildWeatherScreen extends ConsumerStatefulWidget {
  final ChildProfile selectedChild;

  const ChildWeatherScreen({super.key, required this.selectedChild});

  @override
  ConsumerState<ChildWeatherScreen> createState() => _ChildWeatherScreenState();
}

class _ChildWeatherScreenState extends ConsumerState<ChildWeatherScreen> {
  String? weatherDescription;
  double? temperature;
  bool loading = true;
  String? errorMessage;

  @override
  @override
  void initState() {
    super.initState();
    _requestLocationAndFetch();
  }

  Future<void> _requestLocationAndFetch() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      final newPermission = await Geolocator.requestPermission();
      if (newPermission != LocationPermission.whileInUse &&
          newPermission != LocationPermission.always) {
        setState(() {
          loading = false;
          errorMessage = AppLocalizations.of(context)!.locationPermissionDenied;
        });
        return;
      }
    }

    await fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = position.latitude;
      final lon = position.longitude;

      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = data['current_weather'];

        setState(() {
          weatherDescription = _mapWeatherCode(weather['weathercode'], context);
          temperature = weather['temperature'].toDouble();
          loading = false;
        });

        checkWeatherAlertWithAge(
            temperature!, widget.selectedChild.birthDate, context);
      } else {
        setState(() {
          errorMessage = AppLocalizations.of(context)!.weatherFetchError;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '${AppLocalizations.of(context)!.error}: $e';
        loading = false;
      });
    }
  }

  Future<void> sendWeatherAlertToFirestore(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    final child = widget.selectedChild;
    if (user == null) return;

    final doc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications');

    // تأكد من عدم تكرار الإشعار خلال 4 ساعات
    final recent = await doc
        .where('type', isEqualTo: 'weather')
        .where('childId', isEqualTo: child.id)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (recent.docs.isNotEmpty) {
      final lastTimestamp =
          (recent.docs.first.data()['timestamp'] as Timestamp).toDate();
      final diff = DateTime.now().difference(lastTimestamp);
      if (diff.inHours < 4) return; // لا ترسل إشعار مكرر كل أقل من 4 ساعات
    }

    await doc.add({
      'title': '⚠️ طقس غير مناسب لطفلك',
      'message': message,
      'timestamp': DateTime.now(),
      'type': 'weather',
      'childId': child.id,
      'delivered': false,
    });
  }

  void checkWeatherAlertWithAge(
      double temp, DateTime birthDate, BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    String alert = '';
    final now = DateTime.now();
    final ageInMonths = (now.difference(birthDate).inDays / 30).floor();

    if (temp <= 10) {
      alert = ageInMonths <= 12
          ? tr.weatherAlertColdInfant
          : tr.weatherAlertColdGeneral;
    } else if (temp >= 35) {
      alert = ageInMonths <= 36
          ? tr.weatherAlertHotToddler
          : tr.weatherAlertHotGeneral;
    } else if (temp >= 26 && temp <= 32 && ageInMonths <= 6) {
      alert = tr.weatherAlertWarmForInfant;
    }

    if (alert.isNotEmpty) {
      // داخل التطبيق
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(alert),
            backgroundColor: Colors.orangeAccent,
            duration: const Duration(seconds: 6),
          ),
        );
      });

      // أضف إلى Firestore لإرساله كـ Push
      sendWeatherAlertToFirestore(alert);
    }
  }

  String _mapWeatherCode(dynamic code, BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    switch (code) {
      case 0:
        return tr.weatherClear;
      case 1:
      case 2:
      case 3:
        return tr.weatherPartlyCloudy;
      case 45:
      case 48:
        return tr.weatherFog;
      case 51:
      case 53:
      case 55:
        return tr.weatherDrizzle;
      case 61:
      case 63:
      case 65:
        return tr.weatherRain;
      case 71:
      case 73:
      case 75:
        return tr.weatherSnow;
      case 95:
        return tr.weatherThunder;
      default:
        return tr.weatherUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.childWeather),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchWeather,
            tooltip: tr.refresh,
          ),
        ],
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : errorMessage != null
                ? Text(errorMessage!)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wb_sunny,
                          size: 80, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(
                        "${tr.temperatureNow}: ${temperature?.toStringAsFixed(1)}°C",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${tr.weatherCondition}: $weatherDescription",
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
