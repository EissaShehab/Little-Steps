import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:collection/collection.dart';

import '../data/growth_service.dart';
import '../models/growth_model.dart';

final logger = Logger();

/// Provider لـ GrowthService
final growthServiceProvider = Provider<GrowthService>((ref) => GrowthService());

/// StreamProvider لمتابعة القياسات من Firestore مباشرة بدون compute()
final growthMeasurementsProvider = StreamProvider.family<List<GrowthMeasurement>, String>((ref, childId) {
  return ref.watch(growthServiceProvider).getMeasurements(childId, null);
});

class GrowthNotifier extends StateNotifier<List<GrowthMeasurement>> {
  final GrowthService _growthService;

  GrowthNotifier(this._growthService) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      logger.i("✅ GrowthNotifier initialized");
    } catch (e) {
      logger.e("❌ Error initializing GrowthNotifier: $e");
    }
  }

  Future<void> addMeasurement(String childId, GrowthMeasurement measurement) async {
    try {
      final updatedMeasurement = await _growthService.addMeasurement(childId, measurement);
      if (!mounted) return;
      state = [...state, updatedMeasurement]
          .where((m) => m.ageInMonths <= 60)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      logger.i("✅ Added measurement for child $childId");
    } catch (e) {
      logger.e("❌ Error adding measurement: $e");
      rethrow;
    }
  }

  Future<void> deleteMeasurement(String childId, String measurementId) async {
    try {
      await _growthService.deleteMeasurement(childId, measurementId);
      if (!mounted) return;
      state = state.where((m) => m.id != measurementId).toList();
      logger.i("✅ Deleted measurement $measurementId for child $childId");
    } catch (e) {
      logger.e("❌ Error deleting measurement: $e");
      rethrow;
    }
  }

  void updateFromStream(List<GrowthMeasurement> measurements) {
    if (!mounted) return;
    final newMeasurements = measurements
        .where((m) => m.ageInMonths <= 60)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (!const ListEquality().equals(state, newMeasurements)) {
      state = newMeasurements;
      logger.i("✅ State updated from stream with ${measurements.length} measurements");
    }
  }
}

/// StateNotifierProvider بيربط الـ GrowthNotifier بالـ stream ويراقبه
final growthProvider = StateNotifierProvider.family<GrowthNotifier, List<GrowthMeasurement>, String>((ref, childId) {
  final notifier = GrowthNotifier(ref.read(growthServiceProvider));

  // مراقبة التحديثات القادمة من stream
  ref.listen<AsyncValue<List<GrowthMeasurement>>>(
    growthMeasurementsProvider(childId),
    (previous, next) {
      next.when(
        data: (measurements) => notifier.updateFromStream(measurements),
        loading: () => logger.i("⏳ Loading measurements for child $childId"),
        error: (error, stack) => logger.e("❌ Error in stream: $error"),
      );
    },
  );

  return notifier;
});
