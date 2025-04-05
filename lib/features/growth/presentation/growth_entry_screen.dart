import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:littlesteps/features/growth/data/who_data_service.dart';
import 'package:littlesteps/features/growth/models/growth_model.dart';
import 'package:littlesteps/shared/widgets/growth_measurement_form.dart';
import 'package:littlesteps/features/growth/providers/growth_provider.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class GrowthEntryScreen extends ConsumerStatefulWidget {
  final String childId;
  final String gender;
  final DateTime birthDate;

  const GrowthEntryScreen({
    super.key,
    required this.childId,
    required this.gender,
    required this.birthDate,
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
    WHOService.initialize().catchError((e) {
      logger.e("❌ Failed to initialize WHOService: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تهيئة بيانات WHO: $e')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(growthProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال قياسات النمو'),
        backgroundColor: Colors.blue[700],
      ),
      body: Stack(
        children: [
          MeasurementForm(
            initialAge: _calculateAgeInMonths(widget.birthDate),
            birthDate: widget.birthDate,
            onSubmit: _handleSubmit,
            semanticLabel: 'Form for entering growth measurements',
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
    );
  }

  int _calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    return (difference.inDays / 30).floor();
  }

  Future<void> _handleSubmit(Map<String, dynamic> data) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final ageInMonths = data['age'] as int;
      final weight = data['weight'] as double;
      final height = data['height'] as double;
      final headCircumference = data['head'] as double;

      final weightZ = WHOService.calculateZScore(
        measurementType: 'weight_for_age',
        gender: widget.gender,
        ageMonths: ageInMonths,
        measurement: weight,
      );
      final heightZ = WHOService.calculateZScore(
        measurementType: 'height_for_age',
        gender: widget.gender,
        ageMonths: ageInMonths,
        measurement: height,
      );
      final headZ = WHOService.calculateZScore(
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

      await ref.read(growthProvider(widget.childId).notifier).addMeasurement(
            widget.childId,
            measurement,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ القياس بنجاح')),
      );

      if (mounted) {
        logger.i("Navigating to GrowthChartScreen for child ${widget.childId}");
        // الانتقال إلى GrowthChartScreen
        await context.push(
          '/growthChart/${widget.childId}',
          extra: {
            'gender': widget.gender,
            'birthDate': widget.birthDate,
          },
        );
        // إزالة GrowthEntryScreen من مكدس التنقل
        if (mounted) {
          logger.i("Removing GrowthEntryScreen from navigation stack");
          context.pop();
        }
      }
    } catch (e) {
      logger.e("❌ Error submitting measurement: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء حفظ القياس: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}