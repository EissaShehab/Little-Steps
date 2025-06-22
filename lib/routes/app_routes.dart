import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:littlesteps/features/symptom_checker_api/symptoms_screen.dart';
import 'package:littlesteps/providers/providers.dart' as child_provider;
import 'package:littlesteps/features/auth/presentation/login_screen.dart';
import 'package:littlesteps/features/auth/presentation/registration_screen.dart';
import 'package:littlesteps/features/child_profile/presentation/childprofile_screen.dart';
import 'package:littlesteps/features/health_records/presentation/health_records_screen.dart';
import 'package:littlesteps/features/health_tips/presentation/health_tips_screen.dart';
import 'package:littlesteps/features/vaccinations/presentation/vaccination_screen.dart';
import 'package:littlesteps/features/authorities/presentation/authorities_screen.dart';
import 'package:littlesteps/features/home/presentation/home_screen.dart';
import 'package:littlesteps/features/notifications/presentation/notifications_screen.dart';
import 'package:littlesteps/features/settings/presentation/about_screen.dart';
import 'package:littlesteps/features/settings/presentation/change_password_screen.dart';
import 'package:littlesteps/features/settings/presentation/privacy_policy_screen.dart';
import 'package:littlesteps/features/splash/presentation/splash_screen.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/emergency/presentation/nearest_hospitals_screen.dart';
import 'package:littlesteps/features/emergency/presentation/nearest_pharmacies_screen.dart';
import 'package:littlesteps/features/weather/presentation/child_weather_screen.dart';
import 'package:littlesteps/features/symptom_checker_api/Prediction-result-screen.dart';
import 'package:littlesteps/features/growth/presentation/growth_chart_screen.dart'
    as chart;
import 'package:littlesteps/features/growth/presentation/growth_entry_screen.dart'
    as entry;

import 'package:logger/logger.dart';

final logger = Logger();

class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String childProfile = '/child-profile';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String onboarding = '/onboarding';
  static const String changePassword = '/change-password';
  static const String privacyPolicy = '/privacy-policy';
  static const String about = '/about';
  static const String growthChart = '/growthChart';
  static const String growthEntry = '/growthEntry';
  static const String vaccinations = '/vaccinations';
  static const String healthTips = '/healthTips';
  static const String healthRecords = '/healthRecords';
  static const String authorities = '/authorities';
  static const String nearestHospitals = '/nearest-hospitals';

  static Future<String> determineInitialRoute() async {
    final user = FirebaseAuth.instance.currentUser;
    logger.i("Checking auth status for user: \${user?.uid ?? 'null'}");

    if (user == null) return login;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .limit(1)
          .get(GetOptions(source: Source.cache));
      final hasChildProfile = snapshot.docs.isNotEmpty;
      logger.i(
          "✅ Checked child profile for user \${user.uid}: \$hasChildProfile");
      return hasChildProfile ? home : childProfile;
    } catch (e) {
      logger.e("❌ Error checking child profile for user \${user.uid}: \$e");
      return childProfile;
    }
  }

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.matchedLocation;
      final isAuthRoute = [login, register].contains(location);
      final ref = ProviderScope.containerOf(context, listen: false);

      if (user == null) {
        if (!isAuthRoute) {
          logger.w("Redirecting to login due to no authenticated user.");
          return login;
        }
        return null;
      }

      if (isAuthRoute) {
        logger.i("Authenticated user, redirecting from auth route to home.");
        return home;
      }

      final childProfilesAsync = ref.read(child_provider.childProfilesProvider);
      if (childProfilesAsync.asData?.value != null) {
        final children = childProfilesAsync.asData!.value;
        if (children.isEmpty && location != childProfile) {
          logger.i("No children found, redirecting to child-profile.");
          return childProfile;
        }
        if (children.isNotEmpty && location == childProfile) {
          logger.i("Children exist, redirecting to home.");
          return home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: childProfile,
        builder: (context, state) => const ChildProfileScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) {
          final childId = state.uri.queryParameters['childId'] ?? '';
          return NotificationsScreen(childId: childId);
        },
      ),
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '$growthChart/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final gender = extra?['gender'] as String? ?? 'male';
          final birthDate = extra?['birthDate'] as DateTime? ?? DateTime.now();
          return chart.GrowthChartScreen(
            childId: childId,
            gender: gender,
            birthDate: birthDate,
          );
        },
      ),
      GoRoute(
        path: '$growthEntry/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final gender = extra?['gender'] as String? ?? 'male';
          final birthDate = extra?['birthDate'] as DateTime? ?? DateTime.now();
          final cameFromChartScreen =
              extra?['cameFromChartScreen'] as bool? ?? false;
          return entry.GrowthEntryScreen(
            childId: childId,
            gender: gender,
            birthDate: birthDate,
            cameFromChartScreen: cameFromChartScreen,
          );
        },
      ),
      GoRoute(
        path: healthTips,
        builder: (context, state) => const HealthTipsScreen(),
      ),
      GoRoute(
        path: AppRoutes.vaccinations,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          final child = extra?['child'] as ChildProfile?;
          final gender = extra?['gender'] as String? ?? 'male';
          final birthDate = extra?['birthDate'] as DateTime? ?? DateTime.now();

          if (child == null) return const HomeScreen();

          return VaccinationScreen(
            child: child,
            childId: child.id,
            birthDate: birthDate,
          );
        },
      ),
      GoRoute(
        path: authorities,
        builder: (context, state) => const AuthoritiesScreen(),
      ),
      GoRoute(
        path: nearestHospitals,
        builder: (context, state) => const NearestHospitalsScreen(),
      ),
      GoRoute(
        path: '/nearest-pharmacies',
        builder: (context, state) => const NearestPharmaciesScreen(),
      ),
      GoRoute(
        path: '/child-weather',
        builder: (context, state) {
          final child = state.extra as ChildProfile?;
          return child == null
              ? const HomeScreen()
              : ChildWeatherScreen(selectedChild: child);
        },
      ),
      GoRoute(
        path: healthRecords,
        builder: (context, state) {
          return const HealthRecordsScreen(); // بدون تمرير أي شيء
        },
      ),
      GoRoute(
        path: '/prediction-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final predicted = extra?['predictedDisease'] as String? ?? 'Unknown';
          final probs = extra?['probabilities'] as Map<String, double>? ?? {};
          final child = extra?['child'] as ChildProfile?;
          final selectedSymptoms =
              extra?['selectedSymptoms'] as Map<String, int>?;

          if (child == null) return const HomeScreen();
          return PredictionResultScreen(
            predictedDisease: predicted,
            probabilities: probs,
            child: child,
            selectedSymptoms: selectedSymptoms,
          );
        },
      ),
      GoRoute(
        path: '/symptoms',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final child = extra?['child'] as ChildProfile?;
          final cameFromResultScreen =
              extra?['cameFromResultScreen'] as bool? ?? false;
          if (child == null) return const HomeScreen();
          return SymptomsScreen(
            child: child,
            cameFromResultScreen: cameFromResultScreen,
          );
        },
      ),
    ],
  );
}
