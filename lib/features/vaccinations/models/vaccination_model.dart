import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccination {
  final String _name;
  final String _nameAr;
  final String _age;
  final String _ageAr;
  final bool _mandatory;
  final String _status;
  final String _adminType;
  final List<String> _conditions;
  final List<String> _conditionsAr;
  final String _description;
  final String _descriptionAr;

  Vaccination({
    required String name,
    required String nameAr,
    required String age,
    required String ageAr,
    required bool mandatory,
    required String status,
    required String adminType,
    required List<String> conditions,
    required List<String> conditionsAr,
    required String description,
    required String descriptionAr,
  })  : _name = name,
        _nameAr = nameAr,
        _age = age,
        _ageAr = ageAr,
        _mandatory = mandatory,
        _status = status,
        _adminType = adminType,
        _conditions = conditions,
        _conditionsAr = conditionsAr,
        _description = description,
        _descriptionAr = descriptionAr;

  // Getters
  String get name => _name;
  String get nameAr => _nameAr;
  String get age => _age;
  String get ageAr => _ageAr;
  bool get mandatory => _mandatory;
  String get status => _status;
  String get adminType => _adminType;
  List<String> get conditions => _conditions;
  List<String> get conditionsAr => _conditionsAr;
  String get description => _description;
  String get descriptionAr => _descriptionAr;

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
      'name': _name,
      'name_ar': _nameAr,
      'age': _age,
      'age_ar': _ageAr,
      'mandatory': _mandatory,
      'status': _status,
      'admin_type': _adminType,
      'conditions': _conditions,
      'conditions_ar': _conditionsAr,
      'description': _description,
      'description_ar': _descriptionAr,
    };
  }
}
