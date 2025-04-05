import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart'; // إضافة استيراد Hive
import 'package:littlesteps/core/firebase_options.dart';
import 'package:littlesteps/routes/app_routes.dart';
import 'package:littlesteps/features/notifications/data/notification_service.dart';
import 'package:littlesteps/features/growth/data/who_data_service.dart';
import 'package:littlesteps/providers/theme_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

final logger = Logger();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logger.i("💬 Background Message: ${message.notification?.title} - ${message.notification?.body}");
}

Future<void> _initializeNonCriticalServices() async {
  await Future.wait([
    Future(() async {
      try {
        await WHOService.initialize(); // تصحيح: استدعاء الدالة بشكل صحيح
        logger.i("✅ WHO Growth Data Loaded Successfully!");
      } catch (e) {
        logger.e("❌ Error loading WHO data: $e");
      }
    }),
    Future(() async {
      try {
        await NotificationService.initialize();
        await NotificationService().requestPermission();
        Future.delayed(Duration.zero, () => NotificationService().sendTestNotification());
        logger.i("✅ Notification Service Initialized Successfully!");
      } catch (e) {
        logger.e("❌ Notification initialization failed: $e");
      }
    }),
  ]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Hive
  try {
    await Hive.initFlutter();
    await Hive.openBox('growth'); // فتح الصندوق المسمى 'growth'
    logger.i("✅ Hive Initialized and 'growth' Box Opened Successfully!");
  } catch (e) {
    logger.e("❌ Hive initialization failed: $e");
  }

  bool error = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    logger.i("✅ Firebase Initialized Successfully!");
  } catch (e) {
    logger.e("❌ Firebase initialization failed: $e");
    error = true;
  }

  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Amman'));
    logger.i("✅ Timezone Initialized (Asia/Amman)");
  } catch (e) {
    logger.e("❌ Timezone initialization failed: $e");
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final fcmToken = await FirebaseMessaging.instance.getToken();
  logger.i("🔑 FCM Token: $fcmToken");

  final user = FirebaseAuth.instance.currentUser;
  if (fcmToken != null && user != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'fcmToken': fcmToken}, SetOptions(merge: true));
    logger.i("✅ FCM Token stored in Firestore for user: ${user.uid}");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    logger.i("💬 Foreground Message: ${message.notification?.title} - ${message.notification?.body}");
    if (message.notification != null) {
      NotificationService().showFCMNotification(
        title: message.notification!.title ?? "Notification",
        body: message.notification!.body ?? "You have a new message",
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    logger.i("💬 Opened from Notification (Background): ${message.notification?.title}");
    navigatorKey.currentContext?.go(AppRoutes.notifications);
  });

  final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    logger.i("💬 Opened from Notification (Terminated): ${initialMessage.notification?.title}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentContext?.go(AppRoutes.notifications);
    });
  }

  Future.delayed(Duration.zero, _initializeNonCriticalServices);

  runApp(
    ProviderScope(
      child: MyApp(error: error),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool error;

  const MyApp({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeDataProvider);
    logger.i('Building MyApp with theme: isDarkMode = ${ref.watch(themeProvider)}');

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'LittleSteps',
      theme: theme,
      routerConfig: AppRoutes.router,
    );
  }
}