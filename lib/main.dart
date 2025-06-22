import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/Upload/upload_healthTips.dart';
import 'package:littlesteps/core/firebase_options.dart';
import 'package:littlesteps/features/growth/data/who_data_service.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:littlesteps/features/notifications/data/notification_service.dart';
import 'package:littlesteps/providers/theme_provider.dart';
import 'package:littlesteps/features/settings/presentation/settings_screen.dart'
    show localeProvider;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/Upload/upload_vaccinations.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _updateFCMToken() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      logger.w("⚠️ No user logged in, skipping FCM token update.");
      return;
    }

    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'fcmToken': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      logger.i("✅ Created user document for ${user.uid}");
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await userDoc.update({
        'fcmToken': token,
      });
      logger.i("💡 ✅ Updated FCM token for user ${user.uid}: $token");
    } else {
      logger.w("⚠️ Failed to retrieve FCM token.");
    }
  } catch (e) {
    logger.e("❌ Error updating FCM token: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    logger.i("✅ Firebase initialized");

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug, // استخدم playIntegrity في الإنتاج
    );
    logger.i("✅ Firebase App Check initialized");

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    logger.i("✅ Firestore offline persistence enabled");
    await uploadHealthTips();
    final uploader = VaccinationUploader();
    await uploader.uploadIfEmpty();
  } catch (e) {
    logger.e("❌ Error initializing Firebase or uploading vaccinations: $e");
    rethrow;
  }

  try {
    await WHOService.initialize();
    logger.i("✅ WHOService initialized");
  } catch (e) {
    logger.e("❌ Error initializing WHOService: $e");
  }

  await FirebaseMessaging.instance.requestPermission();
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null) {
      await _updateFCMToken();
    }
  });

  FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
      logger.i("💡 ✅ FCM token refreshed for user ${user.uid}: $token");
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        NotificationService().showLocalNotificationOnly(
          title: notification.title ?? "Notification",
          body: notification.body ?? "You have a new message",
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _handleNotificationNavigation(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationNavigation(message);
        });
      }
    });
  }

  Future<void> _handleNotificationNavigation(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];
    final childId = data['childId'];

    if (childId == null) {
      logger.w("❌ Notification missing childId");
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .get();

      if (!doc.exists) return;

      final child = ChildProfile.fromFirestore(doc, doc.id);

      if (type == 'vaccination') {
        navigatorKey.currentContext?.go(
          AppRoutes.vaccinations,
          extra: {
            'childId': child.id,
            'birthDate': child.birthDate,
            'child': child,
          },
        );
      } else if (type == 'weather') {
        navigatorKey.currentContext?.go(
          '/child-weather',
          extra: child,
        );
      } else {
        navigatorKey.currentContext?.go(
          '${AppRoutes.notifications}?childId=$childId',
        );
      }
    } catch (e) {
      logger.e("❌ Error handling notification navigation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeDataProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: AppRoutes.router,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
