import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:littlesteps/features/health_records/models/health_record_model.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HealthRecordsService {
  final CollectionReference _recordsCollection =
      FirebaseFirestore.instance.collection('healthRecords');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch records for a specific child
  Future<List<HealthRecord>> getRecordsForChild(String childId) async {
    try {
      final querySnapshot = await _recordsCollection
          .where('childId', isEqualTo: childId)
          .orderBy('date', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      logger.e('Error fetching health records: $e');
      rethrow;
    }
  }

  // Add a new record (with optional file)
  Future<void> addRecord(HealthRecord record, {File? file}) async {
    try {
      String? attachmentUrl;
      String? fileName;
      if (file != null) {
        // Validate file size (10MB limit)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          throw Exception('File size exceeds 10MB limit');
        }

        // Upload file to Firebase Storage
        fileName = file.path.split('/').last;
        final storageRef = _storage.ref().child('healthRecords/${record.childId}/${record.id}/$fileName');
        await storageRef.putFile(file);
        attachmentUrl = await storageRef.getDownloadURL();
      }

      // Save record with attachment URL
      final updatedRecord = HealthRecord(
        id: record.id,
        childId: record.childId,
        title: record.title,
        date: record.date,
        description: record.description,
        attachmentUrl: attachmentUrl,
        fileName: fileName,
      );
      await _recordsCollection.doc(record.id).set(updatedRecord.toFirestore());
    } catch (e) {
      logger.e('Error adding health record: $e');
      rethrow;
    }
  }

  // Update an existing record
  Future<void> updateRecord(HealthRecord record) async {
    try {
      await _recordsCollection.doc(record.id).update(record.toFirestore());
    } catch (e) {
      logger.e('Error updating health record: $e');
      rethrow;
    }
  }

  // Delete a record (and its file if exists)
  Future<void> deleteRecord(String recordId, String? attachmentUrl) async {
    try {
      if (attachmentUrl != null) {
        await _storage.refFromURL(attachmentUrl).delete();
      }
      await _recordsCollection.doc(recordId).delete();
    } catch (e) {
      logger.e('Error deleting health record: $e');
      rethrow;
    }
  }

  // Download a file
  Future<String> getDownloadUrl(String attachmentUrl) async {
    return attachmentUrl; // Already a downloadable URL from Firebase Storage
  }
}