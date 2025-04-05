import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../data/growth_service.dart';
import '../models/growth_model.dart';

final logger = Logger();

// مزود GrowthService
final growthServiceProvider = Provider<GrowthService>((ref) => GrowthService());

// StreamProvider لاسترجاع القياسات في الوقت الفعلي
final growthMeasurementsProvider =
    StreamProvider.autoDispose.family<List<GrowthMeasurement>, String>((ref, childId) {
  return ref.watch(growthServiceProvider).getMeasurements(childId);
});

// StateNotifier لإدارة الحالة المحلية
class GrowthNotifier extends StateNotifier<List<GrowthMeasurement>> {
  final GrowthService _growthService;

  GrowthNotifier(this._growthService) : super([]) {
    _initialize();
  }

  // تهيئة الحالة من التخزين المحلي أو Firestore
  Future<void> _initialize() async {
    try {
      logger.i("✅ GrowthNotifier initialized");
    } catch (e) {
      logger.e("❌ Error initializing GrowthNotifier: $e");
    }
  }

  // إضافة قياس جديد
  Future<void> addMeasurement(String childId, GrowthMeasurement measurement) async {
    try {
      final updatedMeasurement = await _growthService.addMeasurement(childId, measurement);
      if (!mounted) return;
      state = [...state, updatedMeasurement].where((m) => m.ageInMonths <= 60).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      logger.i("✅ Added measurement for child $childId");
    } catch (e) {
      logger.e("❌ Error adding measurement: $e");
      rethrow;
    }
  }

  // حذف قياس
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

  // تحديث الحالة من الـ Stream
  void updateFromStream(List<GrowthMeasurement> measurements) {
    if (!mounted) return;
    state = measurements.where((m) => m.ageInMonths <= 60).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    logger.i("✅ State updated from stream with ${measurements.length} measurements");
  }
}

// مزود GrowthNotifier
final growthProvider =
    StateNotifierProvider.autoDispose.family<GrowthNotifier, List<GrowthMeasurement>, String>(
        (ref, childId) {
  final notifier = GrowthNotifier(ref.read(growthServiceProvider));

  // الاستماع إلى الـ Stream وتحديث الحالة
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