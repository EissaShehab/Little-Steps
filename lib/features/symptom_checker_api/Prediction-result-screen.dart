// ✅ محدث بالكامل: PredictionResultScreen مع التصدير الحقيقي

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/features/symptom_checker_api/symptom_categories.dart';
import 'package:littlesteps/features/symptom_checker_api/symptom-export-service.dart';

class PredictionResultScreen extends StatelessWidget {
  final String predictedDisease;
  final Map<String, double> probabilities;
  final ChildProfile child;
  final Map<String, int>? selectedSymptoms;

  const PredictionResultScreen({
    super.key,
    required this.predictedDisease,
    required this.probabilities,
    required this.child,
    this.selectedSymptoms,
  });

  Color _getDiseaseColor(double probability) {
    if (probability > 0.8) return Colors.redAccent;
    if (probability > 0.5) return Colors.orangeAccent;
    return Colors.green;
  }

  IconData _getDiseaseIcon(String disease) {
    switch (disease.toLowerCase()) {
      case 'fever':
        return FontAwesomeIcons.temperatureHigh;
      case 'headache':
        return FontAwesomeIcons.headSideVirus;
      case 'cough':
        return FontAwesomeIcons.lungs;
      case 'rash':
        return FontAwesomeIcons.allergies;
      default:
        return FontAwesomeIcons.stethoscope;
    }
  }

  List<PieChartSectionData> _buildPieSections(BuildContext context) {
    final total = probabilities.values.fold(0.0, (a, b) => a + b);
    return probabilities.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 55,
        color: _getDiseaseColor(entry.value),
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final sorted = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: local.predictionResultTitle,
          showBackButton: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12),
                  child: Column(
                    children: [
                      Icon(
                        _getDiseaseIcon(predictedDisease),
                        size: 42,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        local.mostLikelyDisease,
                        style: AppTypography.captionStyle.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        local.translateDisease(predictedDisease),
                        style: AppTypography.headingStyle.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.3,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(context),
                        centerSpaceRadius: 36,
                        sectionsSpace: 3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Text(local.resultDetails,
                        style: AppTypography.subheadingStyle),
                    const SizedBox(height: 10),
                    ...sorted.map((entry) => ListTile(
                          leading: Icon(
                            Icons.bubble_chart,
                            color: _getDiseaseColor(entry.value),
                          ),
                          title: Text(local.translateDisease(entry.key)),
                          trailing:
                              Text('${(entry.value * 100).toStringAsFixed(1)}%'),
                        )),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        local.resultDisclaimer,
                        style: AppTypography.captionStyle.copyWith(
                          color: Colors.grey.shade400, // Lighter shade for dark mode
                          fontSize: 12, // Slightly larger for readability
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (selectedSymptoms != null)
                Expanded(
                  child: _buildGlassButton(
                    context: context,
                    icon: Icons.download,
                    label: local.exportToHealthRecords,
                    color: Colors.green.shade700,
                    onPressed: () async {
                      try {
                        await SymptomExportService.exportSymptomAnalysis(
                          child: child,
                          predictedDisease: predictedDisease,
                          probabilities: probabilities,
                          symptoms: selectedSymptoms!,
                          context: context,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(local.growthReportExportedToHealthRecords),
                            backgroundColor: Colors.green.shade700,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(local.errorExportingToHealthRecords(e.toString())),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    },
                  ),
                ),
              if (selectedSymptoms != null) const SizedBox(width: 12),
              Expanded(
                child: _buildGlassButton(
                  context: context,
                  icon: Icons.replay,
                  label: local.newAnalysis,
                  color: Colors.blue.shade700,
                  onPressed: () {
                    context.go('/symptoms', extra: {
                      'child': child,
                      'cameFromResultScreen': true,
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTypography.buttonStyle.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}