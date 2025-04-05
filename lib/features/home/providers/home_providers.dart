// // lib/providers/home_providers.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:littlesteps/models/child_model.dart';
// import 'package:littlesteps/models/growth_model.dart';
// // Add Growth Service Provider
// final growthServiceProvider = Provider<GrowthService>((ref) => GrowthService());

// // Existing providers
// final selectedChildProvider = StateProvider<ChildProfile?>((ref) => null);
// final growthHistoryProvider = StreamProvider.autoDispose<List<GrowthData>>((ref) {
//   final childId = ref.watch(selectedChildProvider)?.id;
//   if (childId == null) return const Stream.empty();
//   return ref.read(growthServiceProvider).getGrowthHistory(childId);
// });