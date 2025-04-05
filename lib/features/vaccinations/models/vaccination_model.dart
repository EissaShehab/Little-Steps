import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccination {
  final String name;
  final String nameAr;
  final String age;
  final String ageAr;
  final bool mandatory;
  final String status;
  final String adminType;
  final List<String> conditions;
  final List<String> conditionsAr;
  final String description;
  final String descriptionAr;

  Vaccination({
    required this.name,
    required this.nameAr,
    required this.age,
    required this.ageAr,
    required this.mandatory,
    required this.status,
    required this.adminType,
    required this.conditions,
    required this.conditionsAr,
    required this.description,
    required this.descriptionAr,
  });

  /// 🔹 **Convert `age` to days for scheduling vaccinations**
  int get ageInDays {
    final RegExp regex = RegExp(r'(\d+)'); // Extract numbers
    final match = regex.firstMatch(age);
    if (match != null) {
      final int value = int.parse(match.group(1)!);
      if (age.contains('month')) return value * 30; // Convert months to days
      if (age.contains('year')) return value * 365; // Convert years to days
      return value; // Return days as is
    }
    return 0;
  }

  /// 🔹 **Convert Firestore Data to `Vaccination` Model**
  factory Vaccination.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vaccination(
      name: data['name'] ?? '',
      nameAr: data['name_ar'] ?? '',
      age: data['age'] ?? '',
      ageAr: data['age_ar'] ?? '',
      mandatory: data['mandatory'] ?? false,
      status: data['status'] ?? 'upcoming',
      adminType: data['admin_type'] ?? 'injection',
      conditions: List<String>.from(data['conditions'] ?? []),
      conditionsAr: List<String>.from(data['conditions_ar'] ?? []),
      description: data['description'] ?? '',
      descriptionAr: data['description_ar'] ?? '',
    );
  }

  /// 🔹 **Convert `Vaccination` Model to Firestore Data**
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'name_ar': nameAr,
      'age': age,
      'age_ar': ageAr,
      'mandatory': mandatory,
      'status': status,
      'admin_type': adminType,
      'conditions': conditions,
      'conditions_ar': conditionsAr,
      'description': description,
      'description_ar': descriptionAr,
    };
  }
}
