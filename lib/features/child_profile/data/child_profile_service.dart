import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/vaccinations/data/vaccination_service.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ChildProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final VaccinationService _vaccinationService = VaccinationService();

  /// Save child profile, initialize vaccinations, and schedule notifications
  Future<void> saveChildProfile({
    required String userId,
    required ChildProfile profile,
    required String childId,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        logger.i('Uploading profile image for child $childId of user $userId...');
        imageUrl = await _uploadProfileImage(userId, childId, imageFile);
        logger.i('Image URL for child $childId: $imageUrl');
      }

      final profileData = profile.toFirestore()
        ..addAll({
          'photoUrl': imageUrl ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'birthdate': profile.birthDate != null
              ? Timestamp.fromDate(profile.birthDate)
              : Timestamp.now(),
        });

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .set(profileData, SetOptions(merge: true));

      logger.i("✅ Child profile saved: ${profile.name} for user $userId");

      // Initialize default vaccinations
      await _initializeChildVaccinations(userId, childId);

      // Schedule vaccination notifications
      await _vaccinationService.scheduleVaccinationNotifications(childId, profile.birthDate);
      logger.i("✅ Scheduled notifications for child $childId of user $userId");
    } on FirebaseException catch (e) {
      logger.e("❌ Firestore error saving child profile for user $userId: ${e.message}");
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      logger.e("❌ Unexpected error saving child profile for user $userId: $e");
      throw Exception('Failed to save child profile: $e');
    }
  }

  /// Initialize default vaccinations for a child using batch write
  Future<void> _initializeChildVaccinations(String userId, String childId) async {
    try {
      // Define default vaccinations if not using a Firestore collection
      final defaultVaccinations = [
        {'name': 'BCG (Bacillus Calmette–Guérin)', 'age': '0 months', 'status': 'upcoming'},
        {'name': 'Hexavalent Vaccine (DTP-HepB-Hib-IPV) - 1st dose', 'age': '2 months', 'status': 'upcoming'},
        {'name': 'Hexavalent Vaccine (DTP-HepB-Hib-IPV) - 2nd dose', 'age': '4 months', 'status': 'upcoming'},
        {'name': 'Hexavalent Vaccine (DTP-HepB-Hib-IPV) - 3rd dose', 'age': '6 months', 'status': 'upcoming'},
        {'name': 'Oral Polio Vaccine (OPV) - 1st dose', 'age': '2 months', 'status': 'upcoming'},
        {'name': 'Oral Polio Vaccine (OPV) - Booster dose', 'age': '4 years', 'status': 'upcoming'},
        {'name': 'MMR (Measles, Mumps, Rubella) - 1st dose', 'age': '12 months', 'status': 'upcoming'},
        {'name': 'Measles Vaccine - 1st dose', 'age': '9 months', 'status': 'upcoming'},
        {'name': 'DPT Booster - 1st booster', 'age': '5 years', 'status': 'upcoming'},
      ];

      WriteBatch batch = _firestore.batch();

      for (var vaccine in defaultVaccinations) {
        final vaccineRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('children')
            .doc(childId)
            .collection('vaccinations')
            .doc();
        batch.set(vaccineRef, {
          ...vaccine,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        logger.i("✅ Prepared vaccination for child $childId: ${vaccine['name']}");
      }

      await batch.commit();
      logger.i("✅ All default vaccinations added for child $childId of user $userId");
    } on FirebaseException catch (e) {
      logger.e("❌ Error initializing vaccinations for child $childId: ${e.message}");
      throw Exception('Firestore error initializing vaccinations: ${e.message}');
    } catch (e) {
      logger.e("❌ Unexpected error initializing vaccinations for child $childId: $e");
      throw Exception('Failed to initialize vaccinations: $e');
    }
  }

  /// Upload profile image with compression and progress monitoring
  Future<String> _uploadProfileImage(String userId, String childId, File image) async {
    try {
      final compressedImage = await _compressImage(image);
      final ref = _storage
          .ref()
          .child('child_profiles/$userId/$childId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(compressedImage);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen(
        (snapshot) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          logger.i('Upload progress for child $childId: ${progress.toStringAsFixed(1)}%');
        },
        onError: (e) => logger.e('❌ Upload progress error for child $childId: $e'),
      );

      final snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        final downloadURL = await ref.getDownloadURL();
        logger.i("✅ Profile image uploaded for child $childId: $downloadURL");
        return downloadURL;
      } else {
        throw Exception('Image upload failed for child $childId: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      logger.e("❌ Firebase Storage error uploading image for child $childId: ${e.message}");
      throw Exception('Image upload failed: ${e.message}');
    } catch (e) {
      logger.e("❌ Unexpected image upload error for child $childId: $e");
      throw Exception('Unexpected error during image upload for child $childId: $e');
    }
  }

  /// Compress image before upload for better performance
  Future<File> _compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        file.path.replaceAll('.jpg', '_compressed.jpg'),
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );

      if (result != null) {
        return File(result.path);
      } else {
        logger.w("⚠️ Image compression failed for file ${file.path}, returning original file");
        return file;
      }
    } catch (e) {
      logger.w("⚠️ Image compression failed for file ${file.path}: $e");
      return file;
    }
  }
}