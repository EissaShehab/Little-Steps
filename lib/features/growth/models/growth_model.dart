import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class GrowthMeasurement extends Equatable {
  final String? id;
  final DateTime date;
  final double weight;
  final double height;
  final double headCircumference;
  final int ageInMonths;
  final double weightZ;
  final double heightZ;
  final double headZ;
  final String? photoUrl;

  const GrowthMeasurement({
    this.id,
    required this.date,
    required this.weight,
    required this.height,
    required this.headCircumference,
    required this.ageInMonths,
    required this.weightZ,
    required this.heightZ,
    required this.headZ,
    this.photoUrl,
  });

  factory GrowthMeasurement.fromMap(Map<String, dynamic> map) {
    DateTime date;
    if (map['date'] is Timestamp) {
      date = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is DateTime) {
      date = map['date'] as DateTime;
    } else if (map['date'] is String) {
      date = DateTime.parse(map['date'] as String);
    } else {
      date = DateTime.now();
    }

    return GrowthMeasurement(
      id: map['id'] as String?,
      date: date,
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      headCircumference: (map['headCircumference'] as num).toDouble(),
      ageInMonths: (map['ageInMonths'] as num).toInt(),
      weightZ: (map['weightZ'] as num).toDouble(),
      heightZ: (map['heightZ'] as num).toDouble(),
      headZ: (map['headZ'] as num).toDouble(),
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date), 
      'weight': weight,
      'height': height,
      'headCircumference': headCircumference,
      'ageInMonths': ageInMonths,
      'weightZ': weightZ,
      'heightZ': heightZ,
      'headZ': headZ,
      'photoUrl': photoUrl,
    };
  }

  GrowthMeasurement copyWith({
    String? id,
    DateTime? date,
    double? weight,
    double? height,
    double? headCircumference,
    int? ageInMonths,
    double? weightZ,
    double? heightZ,
    double? headZ,
    String? photoUrl,
  }) {
    return GrowthMeasurement(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      headCircumference: headCircumference ?? this.headCircumference,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      weightZ: weightZ ?? this.weightZ,
      heightZ: heightZ ?? this.heightZ,
      headZ: headZ ?? this.headZ,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        weight,
        height,
        headCircumference,
        ageInMonths,
        weightZ,
        heightZ,
        headZ,
        photoUrl,
      ];
}