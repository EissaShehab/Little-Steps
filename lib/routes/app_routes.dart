import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/features/auth/presentation/login_screen.dart';
import 'package:littlesteps/features/auth/presentation/registration_screen.dart';
import 'package:littlesteps/features/child_profile/presentation/childprofile_screen.dart';
import 'package:littlesteps/features/growth/presentation/growth_chart_screen.dart';
import 'package:littlesteps/features/growth/presentation/growth_entry_screen.dart';
import 'package:littlesteps/features/health_records/presentation/health_records_screen.dart';
import 'package:littlesteps/features/health_tips/presentation/healthTips_screen.dart';
import 'package:littlesteps/features/vaccinations/presentation/vaccination_screen.dart';
import 'package:littlesteps/features/authorities/presentation/authorities_screen.dart';
import 'package:littlesteps/features/home/presentation/home_screen.dart';
import 'package:littlesteps/features/notifications/presentation/notifications_screen.dart';
import 'package:littlesteps/features/settings/presentation/about_screen.dart';
import 'package:littlesteps/features/settings/presentation/change_password_screen.dart';
import 'package:littlesteps/features/settings/presentation/privacy_policy_screen.dart';
import 'package:littlesteps/features/splash/presentation/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';

final logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
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

 static Future<String> determineInitialRoute() async {
 final prefs = await SharedPreferences.getInstance();
 final isFirstTime = prefs.getBool('isFirstTime') ?? true;
 final user = FirebaseAuth.instance.currentUser;

 logger.i("Checking auth status for user: ${user?.uid ?? 'null'}");

 if (isFirstTime) {
 await prefs.setBool('isFirstTime', false);
 return onboarding;
 }

 if (user == null) {
 return login;
 }

 try {
 final snapshot = await FirebaseFirestore.instance
 .collection('users')
 .doc(user.uid)
 .collection('children')
 .limit(1)
 .get(GetOptions(source: Source.serverAndCache));
 final hasChildProfile = snapshot.docs.isNotEmpty;
 logger
 .i("✅ Checked child profile for user ${user.uid}: $hasChildProfile");
 return hasChildProfile ? home : childProfile;
 } catch (e) {
 logger.e("❌ Error checking child profile for user ${user.uid}: $e");
 return childProfile;
 }
 }

 static final GoRouter router = GoRouter(
 navigatorKey: navigatorKey,
 initialLocation: splash,
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
 builder: (context, state) {
 logger.i("Navigating to HomeScreen");
 return const HomeScreen();
 },
 ),
 GoRoute(
 path: notifications,
 builder: (context, state) => const NotificationsScreen(),
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
 logger.i("Navigating to GrowthChartScreen for child ${state.pathParameters['childId']}");
 final childId = state.pathParameters['childId']!;
 final extra = state.extra as Map<String, dynamic>?;
 final gender = extra?['gender'] as String? ?? 'male';
 final birthDate = extra?['birthDate'] as DateTime? ?? DateTime.now();
 return GrowthChartScreen(
 childId: childId,
 gender: gender,
 birthDate: birthDate,
 );
 },
 ),
 GoRoute(
 path: '$growthEntry/:childId',
 builder: (context, state) {
 logger.i("Navigating to GrowthEntryScreen for child ${state.pathParameters['childId']}");
 final childId = state.pathParameters['childId']!;
 final extra = state.extra as Map<String, dynamic>?;
 final gender = extra?['gender'] as String? ?? 'male';
 final birthDate = extra?['birthDate'] as DateTime? ?? DateTime.now();
 return GrowthEntryScreen(
 childId: childId,
 gender: gender,
 birthDate: birthDate,
 );
 },
 ),
 GoRoute(
 path: vaccinations,
 builder: (context, state) {
 logger.i("Navigating to VaccinationScreen");
 final extra = state.extra as Map<String, dynamic>?;
 final childId = extra?['childId'] as String? ?? '';
 final birthDate = extra?['birthDate'] as DateTime? ?? DateTime.now();
 final child = extra?['child'] as ChildProfile?;
 if (child == null) {
 logger.w("No child provided for VaccinationScreen, redirecting to home");
 return const HomeScreen();
 }
 return VaccinationScreen(
 childId: childId,
 birthDate: birthDate,
 child: child,
 );
 },
 ),
 GoRoute(
 path: healthTips,
 builder: (context, state) {
 logger.i("Navigating to HealthTipsScreen");
 return const HealthTipsScreen();
 },
 ),
 GoRoute(
 path: healthRecords,
 builder: (context, state) {
 logger.i("Navigating to HealthRecordsScreen");
 final extra = state.extra as Map<String, dynamic>?;
 final child = extra?['child'] as ChildProfile?;
 if (child == null) {
 logger.w("No child provided for HealthRecordsScreen, redirecting to home");
 return const HomeScreen();
 }
 return HealthRecordsScreen(child: child);
 },
 ),
 GoRoute(
 path: authorities,
 builder: (context, state) {
 logger.i("Navigating to AuthoritiesScreen");
 return const AuthoritiesScreen();
 },
 ),
 ],
 redirect: (context, state) async {
 final user = FirebaseAuth.instance.currentUser;
 final isOnAuthRoute = state.matchedLocation == login || state.matchedLocation == register;

 logger.i("Redirect check: current location = ${state.matchedLocation}, user = ${user?.uid ?? 'null'}");

 if (user == null && !isOnAuthRoute) {
 logger.i("Redirecting to /login because user is not logged in");
 return login;
 }

 if (user != null && isOnAuthRoute) {
 logger.i("Redirecting to /home because user is logged in");
 return home;
 }

 logger.i("No redirect needed for location ${state.matchedLocation}");
 return null;
 },
 );
}