import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/vaccinations/data/vaccination_service.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ChildProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> isIdentifierTaken(String identifier) async {
    try {
      final query = await _firestore
          .collection('child_profiles')
          .where('identifier', isEqualTo: identifier)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      logger.e("❌ Error checking identifier uniqueness: $e");
      rethrow;
    }
  }

  Future<void> saveChildProfile({
    required String userId,
    required ChildProfile profile,
    required String childId,
    File? imageFile,
  }) async {
    try {
      final isIdentifierUsed = await isIdentifierTaken(profile.identifier);
      if (isIdentifierUsed) {
        throw Exception('❌ المعرّف مستخدم لطفل آخر بالفعل.');
      }

      String? photoUrl;

      if (imageFile != null) {
        final ref =
            _storage.ref().child('child_profiles/$userId/$childId/profile.jpg');
        await ref.putFile(imageFile);
        photoUrl = await ref.getDownloadURL();
        logger.i(
            "✅ Uploaded profile image for child $childId to Firebase Storage.");
      } else {
        logger.i("ℹ️ No profile image provided for child $childId.");
      }

      final updatedProfile = profile.copyWith(photoUrl: photoUrl);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .set(updatedProfile.toFirestore());

      await _firestore.collection('child_profiles').doc(childId).set({
        'identifier': profile.identifier,
        'identifierType': profile.identifierType,
        'userId': userId,
        'childId': childId,
      });

      logger.i("✅ Saved child profile data for child $childId in Firestore.");

      final vaccinationService = VaccinationService();
      await vaccinationService.deleteVaccinationsForChild(childId);
      await vaccinationService.initializeVaccinationsForChild(
          childId, profile.birthDate);
    } catch (e) {
      logger.e("❌ Error saving child profile for child $childId: $e");
      rethrow;
    }
  }

  Future<void> updateChildProfile({
    required String userId,
    required String childId,
    required ChildProfile profile,
    File? imageFile,
  }) async {
    try {
      final query = await _firestore
          .collection('child_profiles')
          .where('identifier', isEqualTo: profile.identifier)
          .get();
      final isIdentifierUsed = query.docs.any((doc) => doc.id != childId);
      if (isIdentifierUsed) {
        throw Exception('❌ المعرّف مستخدم لطفل آخر بالفعل.');
      }

      String? photoUrl = profile.photoUrl;

      if (imageFile != null) {
        final ref =
            _storage.ref().child('child_profiles/$userId/$childId/profile.jpg');
        await ref.putFile(imageFile);
        photoUrl = await ref.getDownloadURL();
        logger.i(
            "✅ Updated profile image for child $childId in Firebase Storage.");
      }

      final updatedProfile = profile.copyWith(photoUrl: photoUrl);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .update(updatedProfile.toFirestore());

      await _firestore.collection('child_profiles').doc(childId).update({
        'identifier': profile.identifier,
        'identifierType': profile.identifierType,
        'userId': userId,
        'childId': childId,
      });

      logger.i("✅ Updated child profile data for child $childId in Firestore.");
    } catch (e) {
      logger.e("❌ Error updating child profile for child $childId: $e");
      rethrow;
    }
  }

  Future<void> deleteChildProfile(String userId, String childId) async {
    try {
      final batch = _firestore.batch();

      final childRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId);
      batch.delete(childRef);

      final globalChildRef =
          _firestore.collection('child_profiles').doc(childId);
      batch.delete(globalChildRef);

      final notificationsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('childId', isEqualTo: childId)
          .get();

      for (var doc in notificationsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      logger.i(
          "✅ Deleted child profile data and notifications for child $childId from Firestore.");

      final ref =
          _storage.ref().child('child_profiles/$userId/$childId/profile.jpg');
      try {
        await ref.getDownloadURL();
        await ref.delete();
        logger.i(
            "✅ Deleted child profile image from Firebase Storage for child $childId.");
      } catch (e) {
        if (e.toString().contains('object-not-found')) {
          logger.w(
              "⚠️ Profile image not found in Firebase Storage for child $childId, skipping deletion.");
        } else {
          logger.e("❌ Error deleting profile image for child $childId: $e");
          rethrow;
        }
      }
    } catch (e) {
      logger.e("❌ Error deleting child profile for child $childId: $e");
      rethrow;
    }
  }
}