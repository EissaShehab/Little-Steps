import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String id;
  final String childId;
  final String title;
  final DateTime date;
  final String description;
  final String? attachmentUrl;
  final String? fileName; // Store the original file name for display

  HealthRecord({
    required this.id,
    required this.childId,
    required this.title,
    required this.date,
    required this.description,
    this.attachmentUrl,
    this.fileName,
  });

  factory HealthRecord.fromFirestore(Map<String, dynamic> data, String id) {
    return HealthRecord(
      id: id,
      childId: data['childId'] as String,
      title: data['title'] as String,
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] as String,
      attachmentUrl: data['attachmentUrl'] as String?,
      fileName: data['fileName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'childId': childId,
      'title': title,
      'date': Timestamp.fromDate(date),
      'description': description,
      'attachmentUrl': attachmentUrl,
      'fileName': fileName,
    };
  }
}