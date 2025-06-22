import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:littlesteps/features/emergency/data/emergency_service.dart';

final emergencyHospitalsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, (double lat, double lon)>((ref, coords) async {
  return await EmergencyService.getNearbyHospitals(
    lat: coords.$1,
    lon: coords.$2,
  );
});

final emergencyPharmaciesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, (double lat, double lon)>((ref, coords) async {
  return await EmergencyService.getNearbyPharmacies(
    lat: coords.$1,
    lon: coords.$2,
  );
});
