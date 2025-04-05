import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Fetch notifications for the logged-in user
final notificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());
});
