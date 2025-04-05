import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:littlesteps/features/auth/data/auth_service.dart';
import 'package:littlesteps/features/child_profile/data/child_profile_service.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:logger/logger.dart';
final logger = Logger();

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider.autoDispose<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final childProfileServiceProvider = Provider<ChildProfileService>((ref) => ChildProfileService());

final childProfilesProvider = StreamProvider.autoDispose<List<ChildProfile>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  logger.i("🔍 Fetching child profiles for user ${user.uid}...");

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('children')
      .snapshots()
      .handleError((error) {
        logger.e("❌ Error fetching child profiles: $error");
        return []; // Graceful fallback
      })
      .map((snapshot) => snapshot.docs
          .map((doc) => ChildProfile.fromFirestore(doc, doc.id))
          .toList());
});

final selectedChildProvider = StateProvider.autoDispose<ChildProfile?>((ref) => null);