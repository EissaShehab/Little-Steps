import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/typography.dart';

final logger = Logger();

class SymptomsScreen extends StatefulWidget {
  const SymptomsScreen({super.key});

  @override
  _SymptomsScreenState createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final List<Map<String, dynamic>> _symptoms = [
    {'name': 'Fever', 'selected': false},
    {'name': 'Cough', 'selected': false},
    {'name': 'Rash', 'selected': false},
    {'name': 'Fatigue', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleSymptom(int index) {
    setState(() {
      _symptoms[index]['selected'] = !_symptoms[index]['selected'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Symptoms",
      ),
      body: GradientBackground(
        showPattern: false, // Consistent with other screens
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) => Opacity(
                          opacity: _fadeAnimation.value,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey[600]!
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.error.withOpacity(0.7),
                                    colorScheme.error,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.error.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.sick,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Symptoms Monitoring',
                                          style: AppTypography.headingStyle
                                              .copyWith(
                                            fontSize: 24,
                                            color: Colors.white,
                                          ),
                                          semanticsLabel:
                                              'Symptoms Monitoring Title',
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Track and manage your child’s symptoms with ease.',
                                          style:
                                              AppTypography.bodyStyle.copyWith(
                                            color: Colors.white70,
                                          ),
                                          semanticsLabel:
                                              'Symptoms monitoring description',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) => Opacity(
                          opacity: _fadeAnimation.value,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey[600]!
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.error.withOpacity(0.2),
                                  width: 1,
                                ),
                                color: isDark
                                    ? Colors.grey[800]
                                    : colorScheme.surface,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.error.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Symptoms',
                                    style:
                                        AppTypography.subheadingStyle.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ..._symptoms.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final symptom = entry.value;
                                    return CheckboxListTile(
                                      title: Text(
                                        symptom['name'],
                                        style: AppTypography.bodyStyle.copyWith(
                                          color: isDark
                                              ? Colors.white
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                      value: symptom['selected'],
                                      onChanged: (bool? value) =>
                                          _toggleSymptom(index),
                                      activeColor: colorScheme.error,
                                      checkColor: Colors.white,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    );
                                  }).toList(),
                                  const SizedBox(height: 16),
                                  AnimatedScaleButton(
                                    onPressed: () {
                                      final selectedSymptoms = _symptoms
                                          .where((s) => s['selected'])
                                          .map((s) => s['name'])
                                          .toList();
                                      logger.i(
                                          "Selected symptoms: $selectedSymptoms");
                                      // Add logic to save or process selected symptoms
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: colorScheme.error,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.error
                                                .withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Submit Symptoms',
                                          style: AppTypography.buttonStyle
                                              .copyWith(
                                            color: Colors.white,
                                          ),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
