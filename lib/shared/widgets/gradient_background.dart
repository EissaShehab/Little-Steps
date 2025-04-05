import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;
  final bool showPattern;
  final String? patternImage; // Optional pattern overlay (e.g., stars, clouds)

  const GradientBackground({
    super.key,
    required this.child,
    this.colors = const [],
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.showPattern = false,
    this.patternImage,
  });

  GradientBackground.defaultGradient({
    super.key,
    required this.child,
    this.showPattern = false,
    this.patternImage,
  })  : colors = const [],
        begin = Alignment.topCenter,
        end = Alignment.bottomCenter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default gradient colors with feature-specific overrides
    final gradientColors = colors.isNotEmpty
        ? colors
        : isDark
            ? [const Color(0xFF0D47A1), const Color(0xFF1976D2)] // Darker, richer blue for dark mode
            : [const Color(0xFF42A5F5), const Color(0xFFE3F2FD)]; // Lighter blue to off-white for light mode

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: gradientColors,
        ),
        image: showPattern && patternImage != null
            ? DecorationImage(
                image: AssetImage(patternImage!),
                fit: BoxFit.cover,
                opacity: 0.1, // Subtle overlay
              )
            : null,
      ),
      child: child,
    );
  }
}