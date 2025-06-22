import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:littlesteps/gen_l10n/app_localizations.dart';

class SymptomExportService {
  static Future<void> exportSymptomAnalysis({
    required BuildContext context,
    required ChildProfile child,
    required String predictedDisease,
    required Map<String, double> probabilities,
    required Map<String, int> symptoms,
  }) async {
    final pdf = pw.Document();
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';

    // 🇴🇲 Load Tajawal font for Arabic, or use a default font for English
    final fontData = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final tajawalFont = pw.Font.ttf(fontData);

    // 🧾 Prepare symptom table
    final symptomRows = symptoms.entries
        .map((entry) => [
              l10n.translate(entry.key),
              _severityLabel(entry.value, l10n),
            ])
        .toList();

    // 📊 Prepare probability table
    final probabilityRows = probabilities.entries
        .map((entry) => [
              l10n.translate(entry.key),
              '${(entry.value * 100).toStringAsFixed(1)}%',
            ])
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: tajawalFont),
        build: (pw.Context context) => [
          pw.Text(
            l10n.symptom_analysis_report,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            '${l10n.child_name}: ${child.name}',
          ),
          pw.Text(
            '${l10n.date}: ${DateTime.now()}',
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            '${l10n.likely_disease}: ${l10n.translate(predictedDisease)}',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            l10n.symptom_details,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Table.fromTextArray(
            headers: [
              l10n.symptom,
              l10n.severity,
            ],
            data: symptomRows,
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            l10n.disease_probabilities,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Table.fromTextArray(
            headers: [
              l10n.disease,
              l10n.probability,
            ],
            data: probabilityRows,
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${l10n.file_name}');
    await file.writeAsBytes(await pdf.save());

    final storageRef = FirebaseStorage.instance.ref().child(
        'healthRecords/${child.id}/symptom_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await storageRef.putFile(file);
    final url = await storageRef.getDownloadURL();

    final recordId = const Uuid().v4();
    await FirebaseFirestore.instance
        .collection('healthRecords')
        .doc(recordId)
        .set({
      'id': recordId,
      'childId': child.id,
      'title': l10n.health_record_title,
      'description': l10n.health_record_description,
      'fileName': l10n.file_name,
      'attachmentUrl': url,
      'date': Timestamp.now(),
    });

    await file.delete();
  }

  static String _severityLabel(int severity, AppLocalizations l10n) {
    switch (severity) {
      case 1:
        return l10n.severity_mild;
      case 2:
        return l10n.severity_moderate;
      case 3:
        return l10n.severity_severe;
      case 4:
        return l10n.severity_very_severe;
      default:
        return l10n.severity_unknown;
    }
  }
}

// Extension to handle dynamic translation of symptom and disease keys
extension AppLocalizationsExtension on AppLocalizations {
  String translate(String key) {
    // Map known symptom and disease keys to their translations
    switch (key) {
      // Symptoms
      case 'symptomFever':
        return symptomFever;
      case 'symptomCough':
        return symptomCough;
      // Add other symptom keys as needed
      // Diseases
      case 'diseaseAsthma':
        return diseaseAsthma;
      case 'diseaseFlu':
        return diseaseFlu;
      // Add other disease keys as needed
      default:
        return key; // Fallback to key if no translation exists
    }
  }
}
