import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:littlesteps/features/growth/models/growth_model.dart';

final logger = Logger();

class GrowthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _localBox = Hive.box('growth');

  Future<GrowthMeasurement> addMeasurement(String childId, GrowthMeasurement measurement) async {
    try {
      final docRef = await _firestore
          .collection('children')
          .doc(childId)
          .collection('growthMeasurements')
          .add(measurement.toMap()..remove('id'));

      final updatedMeasurement = measurement.copyWith(id: docRef.id);

      await _localBox.put('$childId-${measurement.date.millisecondsSinceEpoch}', updatedMeasurement.toMap());
      logger.i("✅ Measurement added for child $childId");
      return updatedMeasurement;
    } catch (e) {
      logger.e("❌ Unexpected error adding measurement: $e");
      rethrow;
    }
  }

  Future<void> deleteMeasurement(String childId, String measurementId) async {
    try {
      await _firestore
          .collection('children')
          .doc(childId)
          .collection('growthMeasurements')
          .doc(measurementId)
          .delete();

      final keyToDelete = _localBox.keys.firstWhere(
        (key) {
          final rawData = _localBox.get(key);
          if (rawData is Map) {
            final measurement = GrowthMeasurement.fromMap(
              Map<String, dynamic>.from(rawData as Map),
            );
            return measurement.id == measurementId;
          }
          return false;
        },
        orElse: () => null,
      );

      if (keyToDelete != null) {
        await _localBox.delete(keyToDelete);
        logger.i("✅ Measurement $measurementId deleted from local storage for child $childId");
      } else {
        logger.w("No local measurement found with ID $measurementId for child $childId");
      }

      logger.i("✅ Measurement $measurementId deleted from Firestore for child $childId");
    } catch (e) {
      logger.e("❌ Error deleting measurement: $e");
      rethrow;
    }
  }

  Stream<List<GrowthMeasurement>> getMeasurements(String childId) {
    try {
      return _firestore
          .collection('children')
          .doc(childId)
          .collection('growthMeasurements')
          .orderBy('date', descending: true)
          .limit(100)
          .snapshots()
          .asyncMap((snapshot) async {
            final data = snapshot.docs.map((doc) {
              final docData = doc.data();
              if (docData['date'] is Timestamp) {
                docData['date'] = (docData['date'] as Timestamp).toDate();
              }
              return {...docData, 'id': doc.id};
            }).toList();
            final measurements = await compute(parseMeasurements, data);
            for (var m in measurements) {
              await _localBox.put('$childId-${m.date.millisecondsSinceEpoch}', m.toMap());
            }
            return measurements;
          }).handleError((error) {
            logger.e("❌ Error fetching measurements: $error");
            return _getLocalMeasurements(childId);
          });
    } catch (e) {
      logger.e("❌ Unexpected error setting up stream: $e");
      return Stream.value(_getLocalMeasurements(childId));
    }
  }

  List<GrowthMeasurement> _getLocalMeasurements(String childId) {
    try {
      final localData = _localBox.keys
          .where((key) => key.toString().startsWith(childId))
          .map((key) {
            final rawData = _localBox.get(key);
            if (rawData is Map) {
              return Map<String, dynamic>.from(rawData as Map);
            } else {
              throw Exception("Invalid data format in Hive for key $key");
            }
          })
          .map((data) => GrowthMeasurement.fromMap(data))
          .toList();
      return localData;
    } catch (e) {
      logger.e("❌ Error retrieving local measurements: $e");
      return [];
    }
  }
}

List<GrowthMeasurement> parseMeasurements(List<Map<String, dynamic>> data) {
  return data.map((map) => GrowthMeasurement.fromMap(map)).toList();
}