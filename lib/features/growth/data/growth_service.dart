import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:littlesteps/features/growth/models/growth_model.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

final logger = Logger();

class GrowthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _pageSize = 20;

  Future<GrowthMeasurement> addMeasurement(
      String childId, GrowthMeasurement measurement) async {
    try {
      final docRef = await _firestore
          .collection('children')
          .doc(childId)
          .collection('growthMeasurements')
          .add(measurement.toMap()..remove('id'));

      final updatedMeasurement = measurement.copyWith(id: docRef.id);

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

      logger.i(
          "✅ Measurement $measurementId deleted from Firestore for child $childId");
    } catch (e) {
      logger.e("❌ Error deleting measurement: $e");
      rethrow;
    }
  }

  Stream<List<GrowthMeasurement>> getMeasurements(
      String childId, DocumentSnapshot? lastDocument) {
    try {
      Query query = _firestore
          .collection('children')
          .doc(childId)
          .collection('growthMeasurements')
          .orderBy('date', descending: true)
          .limit(_pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      return query.snapshots().asyncMap((snapshot) async {
        final data = snapshot.docs.map((doc) {
          final docData = doc.data() as Map<String, dynamic>;
          if (docData['date'] is Timestamp) {
            docData['date'] = (docData['date'] as Timestamp).toDate();
          }
          return {...docData, 'id': doc.id};
        }).toList();

        final measurements = await compute(parseMeasurementsIsolate, data);
        return measurements;
      }).handleError((error) {
        logger.e("❌ Error fetching measurements: $error");
        return <GrowthMeasurement>[];
      });
    } catch (e) {
      logger.e("❌ Unexpected error setting up stream: $e");
      return Stream.value(<GrowthMeasurement>[]);
    }
  }

  Future<void> exportToHealthRecords(
    String userId,
    String childId,
    List<GrowthMeasurement> measurements, {
    File? weightChartImage,
    File? heightChartImage,
    File? headChartImage,
  }) async {
    try {
      final pdfFile = await generatePDFLocally(
        measurements,
        weightChartImage: weightChartImage,
        heightChartImage: heightChartImage,
        headChartImage: headChartImage,
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'growth_report_$timestamp.pdf';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('healthRecords/$childId/$fileName');
      await storageRef.putFile(pdfFile);
      final attachmentUrl = await storageRef.getDownloadURL();

      final docId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('healthRecords')
          .doc(docId)
          .set({
        'id': docId,
        'childId': childId,
        'title': 'Growth Measurements',
        'description': 'Automatically exported child growth record',
        'fileName': fileName,
        'attachmentUrl': attachmentUrl,
        'date': Timestamp.now(),
      });

      await pdfFile.delete();

      logger.i("✅ Growth report exported to health records for child $childId");
    } catch (e) {
      logger.e("❌ Error exporting to health records: $e");
      rethrow;
    }
  }

  Future<File> generatePDFLocally(
    List<GrowthMeasurement> measurements, {
    File? weightChartImage,
    File? heightChartImage,
    File? headChartImage,
  }) async {
    final pdf = pw.Document();

    final headers = [
      'Date',
      'Age (Months)',
      'Weight (kg)',
      'Height (cm)',
      'Head Circumference (cm)'
    ];
    final data = measurements
        .map((m) => [
              m.date.toIso8601String().split('T').first,
              m.ageInMonths.toString(),
              m.weight.toString(),
              m.height.toString(),
              m.headCircumference.toString(),
            ])
        .toList();

    final weightChartImageBytes =
        weightChartImage != null ? await weightChartImage.readAsBytes() : null;
    final heightChartImageBytes =
        heightChartImage != null ? await heightChartImage.readAsBytes() : null;
    final headChartImageBytes =
        headChartImage != null ? await headChartImage.readAsBytes() : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Text('Child Growth Report',
              style:
                  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text('Growth Measurements Table',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: headers,
            data: data,
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center,
          ),
          pw.SizedBox(height: 20),
          if (weightChartImageBytes != null) ...[
            pw.Text('Weight vs Age Chart', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Image(pw.MemoryImage(weightChartImageBytes),
                width: 400, height: 200),
            pw.SizedBox(height: 20),
          ],
          if (heightChartImageBytes != null) ...[
            pw.Text('Height vs Age Chart', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Image(pw.MemoryImage(heightChartImageBytes),
                width: 400, height: 200),
            pw.SizedBox(height: 20),
          ],
          if (headChartImageBytes != null) ...[
            pw.Text('Head Circumference vs Age Chart',
                style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Image(pw.MemoryImage(headChartImageBytes),
                width: 400, height: 200),
          ],
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/growth_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static List<GrowthMeasurement> parseMeasurementsIsolate(
      List<Map<String, dynamic>> data) {
    return data.map((map) => GrowthMeasurement.fromMap(map)).toList();
  }
}
