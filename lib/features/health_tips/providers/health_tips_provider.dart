import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:littlesteps/features/health_tips/data/health_tips_service.dart';
import 'package:flutter/material.dart';
import 'package:littlesteps/features/settings/presentation/settings_screen.dart' show localeProvider;

final logger = Logger();

final userIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

final healthTipsServiceProvider = Provider((ref) => HealthTipsService());

final dailyHealthTipProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, childId) async {
  final userId = ref.read(userIdProvider);
  if (userId == null) {
    logger.w("❌ No user ID available.");
    return null;
  }
  final language = ref.watch(localeProvider).languageCode; 
  final service = ref.read(healthTipsServiceProvider);
  return await service.getDailyTipForChild(userId, childId, language);
});

final childTipsStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, childId) {
  final userId = ref.read(userIdProvider);
  if (userId == null) {
    logger.w("❌ No user ID available.");
    return const Stream.empty();
  }
  final language = ref.watch(localeProvider).languageCode; 
  final service = ref.read(healthTipsServiceProvider);
  return service.getTipsForChild(userId, childId, language);
});

int calculateAgeInMonths(DateTime birthDate) {
  final now = DateTime.now();
  final difference = now.difference(birthDate);
  return (difference.inDays / 30).floor();
}