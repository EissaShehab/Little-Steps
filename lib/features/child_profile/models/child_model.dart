import 'package:cloud_firestore/cloud_firestore.dart';

class ChildProfile {
  final String id;
  final String name;
  final String identifier;
  final String identifierType;
  final DateTime birthDate;
  final String gender;
  final String relationship;
  final String? photoUrl;
  final DateTime updatedAt;

  ChildProfile({
    required this.id,
    required this.name,
    required this.identifier,
    required this.identifierType,
    required this.birthDate,
    required this.gender,
    required this.relationship,
    this.photoUrl,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory ChildProfile.fromFirestore(DocumentSnapshot doc, String id) {
    final data = doc.data() as Map<String, dynamic>;
    return ChildProfile(
      id: doc.id,
      name: data['name'] ?? '',
      identifier: data['identifier'] ?? data['nationalID'] ?? '',
      identifierType: data['identifierType'] ?? 'national_id',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      gender: data['gender'] ?? 'Male',
      relationship: data['relationship'] ?? 'Parent',
      photoUrl: data['photoUrl'],
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'identifier': identifier,
        'identifierType': identifierType,
        'birthDate': Timestamp.fromDate(birthDate),
        'gender': gender,
        'relationship': relationship,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  ChildProfile copyWith({
    String? id,
    String? name,
    String? identifier,
    String? identifierType,
    DateTime? birthDate,
    String? gender,
    String? relationship,
    String? photoUrl,
    DateTime? updatedAt,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      identifier: identifier ?? this.identifier,
      identifierType: identifierType ?? this.identifierType,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      relationship: relationship ?? this.relationship,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}