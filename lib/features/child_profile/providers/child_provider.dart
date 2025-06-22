import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

// Provider to fetch child profiles in real-time
final childProfilesProvider = StreamProvider.autoDispose<List<ChildProfile>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    logger.w("❌ User not logged in, returning empty stream.");
    return Stream.value([]);
  }

  logger.i("🔍 Fetching child profiles for user ${user.uid}...");

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('children')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final uniqueChildren = <String, ChildProfile>{};
        int successCount = 0;
        int errorCount = 0;

        for (var doc in snapshot.docs) {
          try {
            final child = ChildProfile.fromFirestore(doc, doc.id);
            uniqueChildren[child.id] = child;
            successCount++;
          } catch (e) {
            logger.w("⚠️ Error parsing child profile ${doc.id}: $e");
            errorCount++;
          }
        }
        final childrenList = uniqueChildren.values.toList();
        logger.i("🔹 Loaded $successCount child profiles successfully and skipped $errorCount errors for user ${user.uid}");
        return childrenList;
      })
      .handleError((error, stackTrace) {
        logger.e("❌ Error fetching child profiles for user ${user.uid}: $error, StackTrace: $stackTrace");
        return Stream.value([]); // Graceful fallback
      });
});