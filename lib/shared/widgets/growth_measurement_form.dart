
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:littlesteps/shared/widgets/typography.dart';

final logger = Logger();

class MeasurementForm extends StatefulWidget {
  final int initialAge;
  final DateTime birthDate;
  final Function(Map<String, dynamic>) onSubmit;
  final String? semanticLabel;

  const MeasurementForm({
    super.key,
    required this.initialAge,
    required this.birthDate,
    required this.onSubmit,
    this.semanticLabel,
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

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.initialAge.toString());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: widget.semanticLabel,
      child: FadeTransition(
        opacity: _animationController,
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height, // Ensure full height
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    title: Text(
                      'Manual Age Input',
                      style: AppTypography.bodyStyle.copyWith(
                        color: isDark ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                    value: _useManualAge,
                    onChanged: (value) => setState(() {
                      _useManualAge = value;
                      if (!value) _ageController.text = widget.initialAge.toString();
                    }),
                    activeColor: colorScheme.secondary,
                  ),
                  if (_useManualAge)
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age (months)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        labelStyle: AppTypography.bodyStyle.copyWith(
                          color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : colorScheme.surface,
                      ),
                      style: AppTypography.bodyStyle.copyWith(
                        color: isDark ? Colors.white : colorScheme.onSurface,
                      ),
                      validator: (value) => _validateAge(value),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      suffixText: 'kg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      labelStyle: AppTypography.bodyStyle.copyWith(
                        color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : colorScheme.surface,
                    ),
                    style: AppTypography.bodyStyle.copyWith(
                      color: isDark ? Colors.white : colorScheme.onSurface,
                    ),
                    validator: (value) => _validateMeasurement(value, 'Weight', 2, 40),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      suffixText: 'cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      labelStyle: AppTypography.bodyStyle.copyWith(
                        color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : colorScheme.surface,
                    ),
                    style: AppTypography.bodyStyle.copyWith(
                      color: isDark ? Colors.white : colorScheme.onSurface,
                    ),
                    validator: (value) => _validateMeasurement(value, 'Height', 40, 120),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _headController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Head Circumference (cm)',
                      suffixText: 'cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      labelStyle: AppTypography.bodyStyle.copyWith(
                        color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : colorScheme.surface,
                    ),
                    style: AppTypography.bodyStyle.copyWith(
                      color: isDark ? Colors.white : colorScheme.onSurface,
                    ),
                    validator: (value) => _validateMeasurement(value, 'Head Circumference', 30, 60),
                  ),
                  const SizedBox(height: 24),
                  AnimatedScaleButton(
                    onPressed: _submitForm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary, // Growth accent color
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.secondary.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Save Measurement',
                        style: AppTypography.buttonStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'age': int.parse(_ageController.text),
        'weight': double.parse(_weightController.text),
        'height': double.parse(_heightController.text),
        'head': double.parse(_headController.text),
      });
    }
  }

  String? _validateAge(String? value) {
    final age = int.tryParse(value ?? '');
    if (age == null || age < 0 || age > 60) return 'Age must be 0-60 months';
    return null;
  }

  String? _validateMeasurement(String? value, String field, double min, double max) {
    final measurement = double.tryParse(value ?? '');
    if (measurement == null || measurement < min || measurement > max) {
      return '$field must be between $min and $max';
    }
    return null;
  }
}

class AnimatedScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AnimatedScaleButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  _AnimatedScaleButtonState createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

