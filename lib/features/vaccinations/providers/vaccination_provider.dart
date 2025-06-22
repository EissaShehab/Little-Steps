import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:littlesteps/features/vaccinations/models/vaccination_model.dart';
import 'package:logger/logger.dart';

final logger = Logger();

final vaccinationProvider = StreamProvider.autoDispose
    .family<List<Vaccination>, String>((ref, childId) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return const Stream.empty();

  logger.i("🔍 Fetching vaccinations for child $childId...");

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('vaccinations')
      .snapshots()
      .handleError((error) {
    logger.e("❌ Error fetching vaccinations for child $childId: $error");
    return []; // Graceful fallback
  }).map((snapshot) =>
          snapshot.docs.map((doc) => Vaccination.fromFirestore(doc)).toList());
});
