import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String?>((ref, childId) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return const Stream.empty();

  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('notifications');

  if (childId != null && childId.isNotEmpty) {
    query = query.where('childId', isEqualTo: childId);
  }

  return query
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
});
