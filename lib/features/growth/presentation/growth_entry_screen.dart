import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:littlesteps/features/growth/data/who_data_service.dart' as who;
import 'package:littlesteps/features/growth/models/growth_model.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:littlesteps/shared/widgets/growth_measurement_form.dart';
import 'package:littlesteps/features/growth/providers/growth_provider.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class GrowthEntryScreen extends ConsumerStatefulWidget {
  final String childId;
  final String gender;
  final DateTime birthDate;
  final bool cameFromChartScreen;

  const GrowthEntryScreen({
    super.key,
    required this.childId,
    required this.gender,
    required this.birthDate,
    this.cameFromChartScreen = false,
  });

  @override
  ConsumerState<GrowthEntryScreen> createState() => _GrowthEntryScreenState();
}

class _GrowthEntryScreenState extends ConsumerState<GrowthEntryScreen> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    logger.i("Navigated to GrowthEntryScreen for child ${widget.childId}");

    who.WHOService.initializeWithRetry().then((success) {
      if (!success && mounted) {
        final tr = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.errorLoadingWHOData("Check your connection.")),
            backgroundColor: Colors.red.shade700,
            action: SnackBarAction(
              label: tr.retry,
              textColor: Colors.white,
              onPressed: () {
                setState(() {});
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final measurements = ref.watch(growthProvider(widget.childId));
    final tr = AppLocalizations.of(context)!;

    final latestMeasurement = measurements.isNotEmpty
        ? (measurements.toList()..sort((a, b) => b.date.compareTo(a.date))).first
        : null;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: tr.enterGrowthMeasurements,
          cameFromChartScreen: widget.cameFromChartScreen,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MeasurementForm(
                      initialAge: _calculateAgeInMonths(widget.birthDate),
                      birthDate: widget.birthDate,
                      gender: widget.gender,
                      onSubmit: _handleSubmit,
                      semanticLabel: 'Form for entering child growth data',
                      initialValues: latestMeasurement != null
                          ? {
                              'weight': latestMeasurement.weight.toString(),
                              'height': latestMeasurement.height.toString(),
                              'head': latestMeasurement.headCircumference.toString(),
                            }
                          : null,
                    ),
                    const SizedBox(height: 24),
                    if (latestMeasurement != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              tr.latestMeasurement,
                              style: AppTypography.subheadingStyle,
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryCard(latestMeasurement, tr),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_isSubmitting)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    return (difference.inDays / 30).floor();
  }

  Future<void> _handleSubmit(Map<String, dynamic> data) async {
    if (!who.WHOService.isInitialized) {
      final tr = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr.errorLoadingWHOData('WHO data not initialized')),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ageInMonths = data['age'] as int;
      final weight = data['weight'] as double;
      final height = data['height'] as double;
      final headCircumference = data['head'] as double;

      final weightZ = who.WHOService.calculateZScore(
        measurementType: 'weight_for_age',
        gender: widget.gender,
        ageMonths: ageInMonths,
        measurement: weight,
      );
      final heightZ = who.WHOService.calculateZScore(
        measurementType: 'height_for_age',
        gender: widget.gender,
        ageMonths: ageInMonths,
        measurement: height,
      );
      final headZ = who.WHOService.calculateZScore(
        measurementType: 'head_circumference_for_age',
        gender: widget.gender,
        ageMonths: ageInMonths,
        measurement: headCircumference,
      );

      final measurement = GrowthMeasurement(
        id: null,
        date: DateTime.now(),
        weight: weight,
        height: height,
        headCircumference: headCircumference,
        ageInMonths: ageInMonths,
        weightZ: weightZ,
        heightZ: heightZ,
        headZ: headZ,
        photoUrl: null,
      );

      await ref
          .read(growthProvider(widget.childId).notifier)
          .addMeasurement(widget.childId, measurement);

      if (!mounted) return;
      final tr = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.measurementSavedSuccessfully)),
      );

      logger.i("Navigating to GrowthChartScreen after submission");
      await context.push(
        '/growthChart/${widget.childId}',
        extra: {
          'gender': widget.gender,
          'birthDate': widget.birthDate,
        },
      );
      if (mounted) {
        logger.i("Popping GrowthEntryScreen after pushing GrowthChartScreen");
        context.pop();
      }
    } catch (e) {
      logger.e("❌ Error submitting measurement: $e");
      if (!mounted) return;
      final tr = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.errorSavingMeasurement(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildSummaryCard(GrowthMeasurement m, AppLocalizations tr) {
    final weightStatus = who.WHOService.interpretZScore(m.weightZ, 'weight', context);
    final heightStatus = who.WHOService.interpretZScore(m.heightZ, 'height', context);
    final headStatus = who.WHOService.interpretZScore(m.headZ, 'head', context);
    final formattedDate = DateFormat('d MMMM yyyy, h:mm a').format(m.date);
    final relativeTime = _formatRelativeTime(m.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text('${tr.age}: ${m.ageInMonths} ${tr.months}',
            style: AppTypography.bodyStyle),
        subtitle: Text(
          '${tr.date}: $formattedDate ($relativeTime)\n'
          '${tr.weight}: ${m.weight} ${tr.kg} – $weightStatus\n'
          '${tr.height}: ${m.height} ${tr.cm} – $heightStatus\n'
          '${tr.headCircumference}: ${m.headCircumference} ${tr.cm} – $headStatus',
          style: AppTypography.captionStyle,
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    final tr = AppLocalizations.of(context)!;

    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return months == 1 ? tr.aMonthAgo : tr.monthsAgo(months);
    } else if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return weeks == 1 ? tr.aWeekAgo : tr.weeksAgo(weeks);
    } else if (diff.inDays >= 1) {
      return diff.inDays == 1 ? tr.aDayAgo : tr.daysAgo(diff.inDays);
    } else if (diff.inHours >= 1) {
      return diff.inHours == 1 ? tr.anHourAgo : tr.hoursAgo(diff.inHours);
    } else {
      return tr.justNow;
    }
  }
}
