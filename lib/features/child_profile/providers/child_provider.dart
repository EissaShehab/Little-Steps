import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

// Provider to fetch child profiles in real-time
final childProvider = StreamProvider.autoDispose<List<ChildProfile>>((ref) {
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
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final uniqueChildren = <String, ChildProfile>{};
        for (var doc in snapshot.docs) {
          try {
            final child = ChildProfile.fromFirestore(doc, doc.id);
            uniqueChildren[child.id] = child;
          } catch (e) {
            logger.w("⚠️ Error parsing child profile ${doc.id}: $e");
          }
        }
        final childrenList = uniqueChildren.values.toList();
        logger.i("🔹 Loaded ${childrenList.length} child profiles for user ${user.uid}");
        return childrenList;
      })
      .handleError((error) {
        logger.e("❌ Error fetching child profiles for user ${user.uid}: $error");
        return Stream.value([]); // Graceful fallback
      });
});