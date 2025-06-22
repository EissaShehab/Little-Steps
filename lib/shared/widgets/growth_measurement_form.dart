// 🔥 MeasurementForm widget with WHO smart validation integrated

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:littlesteps/shared/widgets/typography.dart';
import 'package:littlesteps/features/growth/data/who_data_service.dart' as who;

final logger = Logger();

class MeasurementForm extends StatefulWidget {
  final int initialAge;
  final DateTime birthDate;
  final String gender;
  final Function(Map<String, dynamic>) onSubmit;
  final String? semanticLabel;
  final Map<String, String>? initialValues;

  const MeasurementForm({
    super.key,
    required this.initialAge,
    required this.birthDate,
    required this.gender,
    required this.onSubmit,
    this.semanticLabel,
    this.initialValues,
  });

  @override
  State<MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends State<MeasurementForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ageController;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  bool _useManualAge = false;
  late AnimationController _animationController;
  Timer? _debounce;

  String? _weightStatus;
  String? _heightStatus;
  String? _headStatus;

  double? _weightZ;
  double? _heightZ;
  double? _headZ;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.initialAge.toString());
    if (widget.initialValues != null) {
      _weightController.text = widget.initialValues!['weight'] ?? '';
      _heightController.text = widget.initialValues!['height'] ?? '';
      _headController.text = widget.initialValues!['head'] ?? '';
    }
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _weightController.addListener(_debouncedValidate);
    _heightController.addListener(_debouncedValidate);
    _headController.addListener(_debouncedValidate);
    _ageController.addListener(_debouncedValidate);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    _animationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _debouncedValidate() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final age = int.tryParse(_ageController.text);
      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);
      final head = double.tryParse(_headController.text);

      if (age != null && weight != null) {
        _weightZ = who.WHOService.calculateZScore(
          measurementType: 'weight_for_age',
          gender: widget.gender,
          ageMonths: age,
          measurement: weight,
        );
        _weightStatus =
            who.WHOService.interpretZScoreForForm(_weightZ!, 'weight', context);
      }
      if (age != null && height != null) {
        _heightZ = who.WHOService.calculateZScore(
          measurementType: 'height_for_age',
          gender: widget.gender,
          ageMonths: age,
          measurement: height,
        );
        _heightStatus =
            who.WHOService.interpretZScoreForForm(_heightZ!, 'height', context);
      }
      if (age != null && head != null) {
        _headZ = who.WHOService.calculateZScore(
          measurementType: 'head_circumference_for_age',
          gender: widget.gender,
          ageMonths: age,
          measurement: head,
        );
        _headStatus =
            who.WHOService.interpretZScoreForForm(_headZ!, 'head', context);
      }
      setState(() {});
      _formKey.currentState?.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = AppLocalizations.of(context)!;

    return Semantics(
      label: widget.semanticLabel ?? tr.enterGrowthMeasurements,
      child: FadeTransition(
        opacity: _animationController,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    title: Text(
                      tr.enterAgeManually,
                      style: AppTypography.bodyStyle.copyWith(
                        color: isDark ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                    value: _useManualAge,
                    onChanged: (value) => setState(() {
                      _useManualAge = value;
                      if (!value) {
                        _ageController.text = widget.initialAge.toString();
                      }
                    }),
                    activeColor: colorScheme.secondary,
                  ),
                  if (_useManualAge)
                    _buildTextField(
                      controller: _ageController,
                      label: tr.ageMonths,
                      suffix: tr.months,
                      validator: _validateAge,
                      keyboardType: TextInputType.number,
                    ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _weightController,
                    label: tr.weightKg,
                    suffix: tr.kg,
                    validator: (value) =>
                        _validateMeasurement(value, tr.weight, 1, 30),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    statusMessage: _weightStatus,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _heightController,
                    label: tr.heightCm,
                    suffix: tr.cm,
                    validator: (value) =>
                        _validateMeasurement(value, tr.height, 40, 120),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    statusMessage: _heightStatus,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _headController,
                    label: tr.headCircumferenceCm,
                    suffix: tr.cm,
                    validator: (value) => _validateMeasurement(
                        value, tr.headCircumference, 30, 60),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    statusMessage: _headStatus,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      tr.saveMeasurement,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
    String? statusMessage,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[850] : colorScheme.surface,
          ),
          style:
              TextStyle(color: isDark ? Colors.white : colorScheme.onSurface),
          validator: validator,
        ),
        if (statusMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              statusMessage,
              style: TextStyle(
                fontSize: 12,
                color: statusMessage.contains('طبيعي')
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ),
      ],
    );
  }

  void _submitForm() {
    final tr = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if ((_weightZ != null && (_weightZ! < -5 || _weightZ! > 5)) ||
          (_heightZ != null && (_heightZ! < -5 || _heightZ! > 5)) ||
          (_headZ != null && (_headZ! < -5 || _headZ! > 5))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.invalidMeasurementOutlier),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }
      widget.onSubmit({
        'age': int.parse(_ageController.text),
        'weight': double.parse(_weightController.text),
        'height': double.parse(_heightController.text),
        'head': double.parse(_headController.text),
      });
    }
  }

  String? _validateAge(String? value) {
    final tr = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return tr.pleaseEnterAge;
    final age = int.tryParse(value);
    if (age == null || age < 0 || age > 60) {
      return tr.ageRangeError;
    }
    return null;
  }

  String? _validateMeasurement(
      String? value, String field, double min, double max) {
    final tr = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return tr.pleaseEnterField(field);
    }
    final measurement = double.tryParse(value);
    if (measurement == null || measurement < min || measurement > max) {
      return tr.fieldRangeError(field, min.toString(), max.toString());
    }
    return null;
  }
}
